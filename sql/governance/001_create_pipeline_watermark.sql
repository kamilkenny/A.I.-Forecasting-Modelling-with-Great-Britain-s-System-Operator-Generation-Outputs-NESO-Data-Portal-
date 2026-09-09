CREATE TABLE IF NOT EXISTS governance.pipeline_watermark (
    pipeline_name               TEXT PRIMARY KEY,
    source_resource_id          TEXT NOT NULL,
    last_successful_datetime    TIMESTAMP WITHOUT TIME ZONE,
    last_run_started_at_utc     TIMESTAMPTZ,
    last_run_completed_at_utc   TIMESTAMPTZ,
    last_status                 TEXT,
    rows_received               INTEGER NOT NULL DEFAULT 0,
    rows_inserted               INTEGER NOT NULL DEFAULT 0,
    rows_updated                INTEGER NOT NULL DEFAULT 0,
    updated_at_utc              TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);
