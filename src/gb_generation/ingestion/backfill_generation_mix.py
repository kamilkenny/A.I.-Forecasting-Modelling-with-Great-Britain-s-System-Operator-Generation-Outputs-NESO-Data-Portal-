import argparse
from datetime import datetime

import psycopg

from gb_generation.ingestion.load_generation_mix import (
    RESOURCE_ID,
    fetch_records_after,
    get_connection,
    load_records,
    mark_failure,
    mark_success,
    validate_configuration,
)


PIPELINE_NAME = "neso_generation_mix_backfill"


def get_backfill_watermark(
    connection: psycopg.Connection,
) -> datetime | None:
    with connection.cursor() as cursor:
        cursor.execute(
            """
            SELECT last_successful_datetime
            FROM governance.pipeline_watermark
            WHERE pipeline_name = %s;
            """,
            (PIPELINE_NAME,),
        )

        row = cursor.fetchone()

    return row[0] if row else None


def create_backfill_run(
    connection: psycopg.Connection,
    requested: int,
) -> int:
    with connection.cursor() as cursor:
        cursor.execute(
            """
            INSERT INTO governance.pipeline_runs (
                pipeline_name,
                source_resource_id,
                records_requested,
                status
            )
            VALUES (
                %s,
                %s,
                %s,
                'RUNNING'
            )
            RETURNING run_id;
            """,
            (
                PIPELINE_NAME,
                RESOURCE_ID,
                requested,
            ),
        )

        run_id = cursor.fetchone()[0]

    connection.commit()

    return run_id


def begin_backfill_state(
    connection: psycopg.Connection,
) -> None:
    with connection.cursor() as cursor:
        cursor.execute(
            """
            INSERT INTO governance.pipeline_watermark (
                pipeline_name,
                source_resource_id,
                last_run_started_at_utc,
                last_status,
                rows_received,
                rows_inserted,
                rows_updated
            )
            VALUES (
                %s,
                %s,
                CURRENT_TIMESTAMP,
                'RUNNING',
                0,
                0,
                0
            )
            ON CONFLICT (pipeline_name)
            DO UPDATE SET
                source_resource_id = EXCLUDED.source_resource_id,
                last_run_started_at_utc = CURRENT_TIMESTAMP,
                last_run_completed_at_utc = NULL,
                last_status = 'RUNNING',
                rows_received = 0,
                rows_inserted = 0,
                rows_updated = 0,
                updated_at_utc = CURRENT_TIMESTAMP;
            """,
            (
                PIPELINE_NAME,
                RESOURCE_ID,
            ),
        )

    connection.commit()


def update_backfill_state(
    connection: psycopg.Connection,
    watermark: datetime,
    received: int,
    inserted: int,
    updated: int,
) -> None:
    with connection.cursor() as cursor:
        cursor.execute(
            """
            UPDATE governance.pipeline_watermark
            SET
                last_successful_datetime = %s,
                last_status = 'RUNNING',
                rows_received = %s,
                rows_inserted = %s,
                rows_updated = %s,
                updated_at_utc = CURRENT_TIMESTAMP
            WHERE pipeline_name = %s;
            """,
            (
                watermark,
                received,
                inserted,
                updated,
                PIPELINE_NAME,
            ),
        )


def finish_backfill_state(
    connection: psycopg.Connection,
    status: str,
    received: int,
    inserted: int,
    updated: int,
) -> None:
    with connection.cursor() as cursor:
        cursor.execute(
            """
            UPDATE governance.pipeline_watermark
            SET
                last_run_completed_at_utc = CURRENT_TIMESTAMP,
                last_status = %s,
                rows_received = %s,
                rows_inserted = %s,
                rows_updated = %s,
                updated_at_utc = CURRENT_TIMESTAMP
            WHERE pipeline_name = %s;
            """,
            (
                status,
                received,
                inserted,
                updated,
                PIPELINE_NAME,
            ),
        )


def main() -> None:
    parser = argparse.ArgumentParser(
        description=(
            "Backfill historic NESO GB generation mix "
            "data into PostgreSQL."
        )
    )

    parser.add_argument(
        "--batch-size",
        type=int,
        default=1000,
        help="Number of NESO observations per batch.",
    )

    parser.add_argument(
        "--max-batches",
        type=int,
        default=None,
        help=(
            "Optional maximum number of batches. "
            "Useful for controlled testing."
        ),
    )

    args = parser.parse_args()

    if args.batch_size < 1 or args.batch_size > 1000:
        raise ValueError(
            "--batch-size must be between 1 and 1000."
        )

    if (
        args.max_batches is not None
        and args.max_batches < 1
    ):
        raise ValueError(
            "--max-batches must be at least 1."
        )

    validate_configuration()

    connection = get_connection()

    watermark = get_backfill_watermark(connection)

    begin_backfill_state(connection)

    requested = (
        args.batch_size * args.max_batches
        if args.max_batches is not None
        else 0
    )

    run_id = create_backfill_run(
        connection,
        requested,
    )

    total_received = 0
    total_inserted = 0
    total_updated = 0
    batch_number = 0
    latest_datetime = watermark

    try:
        if watermark is None:
            print(
                "Starting historical backfill "
                "from beginning of NESO source."
            )
        else:
            print(
                "Resuming historical backfill after "
                f"{watermark}."
            )

        while True:
            records = fetch_records_after(
                watermark,
                args.batch_size,
            )

            if not records:
                final_status = "SUCCESS"
                break

            inserted, updated, latest_datetime = (
                load_records(
                    connection,
                    records,
                )
            )

            if latest_datetime is None:
                raise RuntimeError(
                    "Batch returned no valid DATETIME watermark."
                )

            total_received += len(records)
            total_inserted += inserted
            total_updated += updated
            batch_number += 1

            update_backfill_state(
                connection=connection,
                watermark=latest_datetime,
                received=total_received,
                inserted=total_inserted,
                updated=total_updated,
            )

            connection.commit()

            watermark = latest_datetime

            print(
                f"Batch {batch_number}: "
                f"received={len(records)}, "
                f"inserted={inserted}, "
                f"updated={updated}, "
                f"watermark={watermark}"
            )

            if (
                args.max_batches is not None
                and batch_number >= args.max_batches
            ):
                final_status = "PARTIAL"
                break

        finish_backfill_state(
            connection=connection,
            status=final_status,
            received=total_received,
            inserted=total_inserted,
            updated=total_updated,
        )

        connection.commit()

        mark_success(
            connection=connection,
            run_id=run_id,
            received=total_received,
            inserted=total_inserted,
            updated=total_updated,
            latest_datetime=latest_datetime,
        )

        print()
        print("Backfill run completed successfully.")
        print(f"Status:   {final_status}")
        print(f"Batches:  {batch_number}")
        print(f"Received: {total_received}")
        print(f"Inserted: {total_inserted}")
        print(f"Updated:  {total_updated}")
        print(f"Latest:   {latest_datetime}")

    except Exception as error:
        connection.rollback()

        finish_backfill_state(
            connection=connection,
            status="FAILED",
            received=total_received,
            inserted=total_inserted,
            updated=total_updated,
        )

        connection.commit()

        mark_failure(
            connection=connection,
            run_id=run_id,
            error=error,
        )

        raise

    finally:
        connection.close()


if __name__ == "__main__":
    main()
