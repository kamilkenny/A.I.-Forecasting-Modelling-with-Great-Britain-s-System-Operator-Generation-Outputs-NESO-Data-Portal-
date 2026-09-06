CREATE TABLE IF NOT EXISTS governance.pipeline_runs (
    run_id                  BIGSERIAL PRIMARY KEY,
    pipeline_name           TEXT NOT NULL,
    started_at              TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at            TIMESTAMPTZ,
    status                  TEXT NOT NULL DEFAULT 'RUNNING',

    source_resource_id      TEXT,
    source_latest_datetime  TIMESTAMP WITHOUT TIME ZONE,

    records_requested       INTEGER DEFAULT 0,
    records_received        INTEGER DEFAULT 0,
    records_inserted        INTEGER DEFAULT 0,
    records_updated         INTEGER DEFAULT 0,
    records_rejected        INTEGER DEFAULT 0,

    error_message           TEXT,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_pipeline_status
        CHECK (status IN ('RUNNING', 'SUCCESS', 'FAILED'))
);
