import argparse
import os
import re
from datetime import datetime
from decimal import Decimal
from typing import Any

import psycopg
import requests


NESO_API_URL = (
    "https://api.neso.energy/api/3/action/datastore_search_sql"
)

RESOURCE_ID = os.environ.get("NESO_RESOURCE_ID", "")


FIELD_MAP = [
    ("GAS", "gas"),
    ("COAL", "coal"),
    ("NUCLEAR", "nuclear"),
    ("WIND", "wind"),
    ("WIND_EMB", "wind_emb"),
    ("HYDRO", "hydro"),
    ("IMPORTS", "imports"),
    ("BIOMASS", "biomass"),
    ("OTHER", "other"),
    ("SOLAR", "solar"),
    ("STORAGE", "storage"),
    ("GENERATION", "generation"),
    ("CARBON_INTENSITY", "carbon_intensity"),
    ("LOW_CARBON", "low_carbon"),
    ("ZERO_CARBON", "zero_carbon"),
    ("RENEWABLE", "renewable"),
    ("FOSSIL", "fossil"),
    ("GAS_perc", "gas_perc"),
    ("COAL_perc", "coal_perc"),
    ("NUCLEAR_perc", "nuclear_perc"),
    ("WIND_perc", "wind_perc"),
    ("WIND_EMB_perc", "wind_emb_perc"),
    ("HYDRO_perc", "hydro_perc"),
    ("IMPORTS_perc", "imports_perc"),
    ("BIOMASS_perc", "biomass_perc"),
    ("OTHER_perc", "other_perc"),
    ("SOLAR_perc", "solar_perc"),
    ("STORAGE_perc", "storage_perc"),
    ("GENERATION_perc", "generation_perc"),
    ("LOW_CARBON_perc", "low_carbon_perc"),
    ("ZERO_CARBON_perc", "zero_carbon_perc"),
    ("RENEWABLE_perc", "renewable_perc"),
    ("FOSSIL_perc", "fossil_perc"),
]


DB_COLUMNS = (
    ["datetime", "source_id"]
    + [db_name for _, db_name in FIELD_MAP]
    + ["source_resource_id"]
)


def validate_configuration() -> None:
    required = [
        "PGHOST",
        "PGPORT",
        "PGDATABASE",
        "PGUSER",
        "PGPASSWORD",
        "NESO_RESOURCE_ID",
    ]

    missing = [
        name
        for name in required
        if not os.environ.get(name)
    ]

    if missing:
        raise RuntimeError(
            "Missing environment variables: "
            + ", ".join(missing)
        )

    if not re.fullmatch(
        r"[0-9a-fA-F-]{36}",
        RESOURCE_ID,
    ):
        raise RuntimeError(
            "NESO_RESOURCE_ID is not a valid resource identifier."
        )


def get_connection() -> psycopg.Connection:
    return psycopg.connect(
        host=os.environ["PGHOST"],
        port=os.environ["PGPORT"],
        dbname=os.environ["PGDATABASE"],
        user=os.environ["PGUSER"],
        password=os.environ["PGPASSWORD"],
        sslmode=os.environ.get("PGSSLMODE", "require"),
    )


def to_decimal(value: Any) -> Decimal | None:
    if value is None or value == "":
        return None

    return Decimal(str(value))


def transform_record(record: dict[str, Any]) -> tuple:
    timestamp = record.get("DATETIME")

    if not timestamp:
        raise ValueError(
            "NESO record contains no DATETIME value."
        )

    parsed_datetime = datetime.fromisoformat(timestamp)

    values = [
        parsed_datetime,
        int(record["_id"])
        if record.get("_id") is not None
        else None,
    ]

    for source_name, _ in FIELD_MAP:
        values.append(
            to_decimal(record.get(source_name))
        )

    values.append(RESOURCE_ID)

    return tuple(values)


def fetch_latest_records(limit: int) -> list[dict]:
    sql = (
        f'SELECT * FROM "{RESOURCE_ID}" '
        f'ORDER BY "DATETIME" DESC '
        f"LIMIT {int(limit)}"
    )

    response = requests.get(
        NESO_API_URL,
        params={"sql": sql},
        timeout=60,
    )

    response.raise_for_status()

    payload = response.json()

    if payload.get("success") is not True:
        raise RuntimeError(
            f"NESO API request failed: {payload}"
        )

    return payload["result"]["records"]


def create_pipeline_run(
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
                'neso_generation_mix_ingestion',
                %s,
                %s,
                'RUNNING'
            )
            RETURNING run_id;
            """,
            (RESOURCE_ID, requested),
        )

        run_id = cursor.fetchone()[0]

    connection.commit()

    return run_id


def find_existing_datetimes(
    connection: psycopg.Connection,
    datetimes: list[datetime],
) -> set[datetime]:
    if not datetimes:
        return set()

    with connection.cursor() as cursor:
        cursor.execute(
            """
            SELECT datetime
            FROM raw.neso_generation_mix
            WHERE datetime = ANY(%s);
            """,
            (datetimes,),
        )

        return {
            row[0]
            for row in cursor.fetchall()
        }


def build_upsert_sql() -> str:
    columns = ", ".join(DB_COLUMNS)

    placeholders = ", ".join(
        ["%s"] * len(DB_COLUMNS)
    )

    update_columns = [
        column
        for column in DB_COLUMNS
        if column != "datetime"
    ]

    updates = ",\n".join(
        f"{column} = EXCLUDED.{column}"
        for column in update_columns
    )

    return f"""
        INSERT INTO raw.neso_generation_mix (
            {columns}
        )
        VALUES (
            {placeholders}
        )
        ON CONFLICT (datetime)
        DO UPDATE SET
            {updates},
            updated_at = CURRENT_TIMESTAMP;
    """


def load_records(
    connection: psycopg.Connection,
    records: list[dict],
) -> tuple[int, int, datetime | None]:

    transformed = [
        transform_record(record)
        for record in records
    ]

    datetimes = [
        row[0]
        for row in transformed
    ]

    existing = find_existing_datetimes(
        connection,
        datetimes,
    )

    inserted = sum(
        timestamp not in existing
        for timestamp in datetimes
    )

    updated = sum(
        timestamp in existing
        for timestamp in datetimes
    )

    sql = build_upsert_sql()

    with connection.cursor() as cursor:
        cursor.executemany(
            sql,
            transformed,
        )

    latest_datetime = (
        max(datetimes)
        if datetimes
        else None
    )

    return inserted, updated, latest_datetime


def mark_success(
    connection: psycopg.Connection,
    run_id: int,
    received: int,
    inserted: int,
    updated: int,
    latest_datetime: datetime | None,
) -> None:

    with connection.cursor() as cursor:
        cursor.execute(
            """
            UPDATE governance.pipeline_runs
            SET
                completed_at = CURRENT_TIMESTAMP,
                status = 'SUCCESS',
                source_latest_datetime = %s,
                records_received = %s,
                records_inserted = %s,
                records_updated = %s
            WHERE run_id = %s;
            """,
            (
                latest_datetime,
                received,
                inserted,
                updated,
                run_id,
            ),
        )

    connection.commit()


def mark_failure(
    connection: psycopg.Connection,
    run_id: int,
    error: Exception,
) -> None:

    connection.rollback()

    with connection.cursor() as cursor:
        cursor.execute(
            """
            UPDATE governance.pipeline_runs
            SET
                completed_at = CURRENT_TIMESTAMP,
                status = 'FAILED',
                error_message = %s
            WHERE run_id = %s;
            """,
            (
                str(error)[:2000],
                run_id,
            ),
        )

    connection.commit()


def main() -> None:
    parser = argparse.ArgumentParser(
        description=(
            "Load NESO GB generation mix data "
            "into PostgreSQL."
        )
    )

    parser.add_argument(
        "--limit",
        type=int,
        default=20,
        help="Number of latest records to ingest.",
    )

    args = parser.parse_args()

    if args.limit < 1 or args.limit > 1000:
        raise ValueError(
            "--limit must be between 1 and 1000."
        )

    validate_configuration()

    connection = get_connection()

    run_id = create_pipeline_run(
        connection,
        args.limit,
    )

    try:
        print(
            f"Fetching latest {args.limit} "
            "NESO observations..."
        )

        records = fetch_latest_records(
            args.limit
        )

        print(
            f"Received {len(records)} records."
        )

        inserted, updated, latest_datetime = (
            load_records(
                connection,
                records,
            )
        )

        mark_success(
            connection=connection,
            run_id=run_id,
            received=len(records),
            inserted=inserted,
            updated=updated,
            latest_datetime=latest_datetime,
        )

        print("Ingestion successful.")
        print(f"Inserted: {inserted}")
        print(f"Updated:  {updated}")
        print(
            f"Latest:   {latest_datetime}"
        )

    except Exception as error:
        mark_failure(
            connection,
            run_id,
            error,
        )

        raise

    finally:
        connection.close()


if __name__ == "__main__":
    main()
