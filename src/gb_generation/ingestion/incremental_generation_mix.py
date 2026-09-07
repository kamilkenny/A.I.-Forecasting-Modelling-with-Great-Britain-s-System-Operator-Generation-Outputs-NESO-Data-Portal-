import argparse
from datetime import datetime, timedelta

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


PIPELINE_NAME = "neso_generation_mix_incremental"


def get_database_watermark(
    connection: psycopg.Connection,
) -> datetime | None:
    with connection.cursor() as cursor:
        cursor.execute(
            """
            SELECT MAX(datetime)
            FROM raw.neso_generation_mix;
            """
        )

        row = cursor.fetchone()

    return row[0] if row else None


def create_incremental_run(
    connection: psycopg.Connection,
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
                0,
                'RUNNING'
            )
            RETURNING run_id;
            """,
            (
                PIPELINE_NAME,
                RESOURCE_ID,
            ),
        )

        run_id = cursor.fetchone()[0]

    connection.commit()

    return run_id


def begin_incremental_state(
    connection: psycopg.Connection,
    current_watermark: datetime | None,
) -> None:
    with connection.cursor() as cursor:
        cursor.execute(
            """
            INSERT INTO governance.pipeline_watermark (
                pipeline_name,
                source_resource_id,
                last_successful_datetime,
                last_run_started_at_utc,
                last_status,
                rows_received,
                rows_inserted,
                rows_updated
            )
            VALUES (
                %s,
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
                current_watermark,
            ),
        )

    connection.commit()


def update_incremental_state(
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


def finish_incremental_state(
    connection: psycopg.Connection,
    watermark: datetime | None,
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
                last_successful_datetime = %s,
                last_run_completed_at_utc = CURRENT_TIMESTAMP,
                last_status = %s,
                rows_received = %s,
                rows_inserted = %s,
                rows_updated = %s,
                updated_at_utc = CURRENT_TIMESTAMP
            WHERE pipeline_name = %s;
            """,
            (
                watermark,
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
            "Incrementally ingest live NESO GB generation "
            "mix observations into PostgreSQL."
        )
    )

    parser.add_argument(
        "--batch-size",
        type=int,
        default=1000,
        help="Maximum observations fetched per API batch.",
    )

    parser.add_argument(
        "--lookback-hours",
        type=int,
        default=48,
        help=(
            "Recent period to re-read so NESO revisions "
            "can be captured."
        ),
    )

    args = parser.parse_args()

    if args.batch_size < 1 or args.batch_size > 1000:
        raise ValueError(
            "--batch-size must be between 1 and 1000."
        )

    if args.lookback_hours < 0:
        raise ValueError(
            "--lookback-hours cannot be negative."
        )

    validate_configuration()

    connection = get_connection()

    database_watermark = get_database_watermark(
        connection
    )

    if database_watermark is None:
        raise RuntimeError(
            "Raw generation table is empty. "
            "Run historical backfill first."
        )

    fetch_cursor = (
        database_watermark
        - timedelta(hours=args.lookback_hours)
    )

    begin_incremental_state(
        connection,
        database_watermark,
    )

    run_id = create_incremental_run(connection)

    total_received = 0
    total_inserted = 0
    total_updated = 0
    latest_datetime = database_watermark
    batch_number = 0

    try:
        print(
            f"Database watermark: {database_watermark}"
        )

        print(
            f"Re-reading NESO after: {fetch_cursor}"
        )

        while True:
            records = fetch_records_after(
                fetch_cursor,
                args.batch_size,
            )

            if not records:
                break

            inserted, updated, batch_latest = (
                load_records(
                    connection,
                    records,
                )
            )

            if batch_latest is None:
                break

            total_received += len(records)
            total_inserted += inserted
            total_updated += updated
            batch_number += 1

            if batch_latest > latest_datetime:
                latest_datetime = batch_latest

            update_incremental_state(
                connection=connection,
                watermark=latest_datetime,
                received=total_received,
                inserted=total_inserted,
                updated=total_updated,
            )

            connection.commit()

            fetch_cursor = batch_latest

            print(
                f"Batch {batch_number}: "
                f"received={len(records)}, "
                f"inserted={inserted}, "
                f"updated={updated}, "
                f"latest={batch_latest}"
            )

            if len(records) < args.batch_size:
                break

        finish_incremental_state(
            connection=connection,
            watermark=latest_datetime,
            status="SUCCESS",
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
        print("Incremental ingestion successful.")
        print(f"Batches:  {batch_number}")
        print(f"Received: {total_received}")
        print(f"Inserted: {total_inserted}")
        print(f"Updated:  {total_updated}")
        print(f"Latest:   {latest_datetime}")

    except Exception as error:
        connection.rollback()

        finish_incremental_state(
            connection=connection,
            watermark=latest_datetime,
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
