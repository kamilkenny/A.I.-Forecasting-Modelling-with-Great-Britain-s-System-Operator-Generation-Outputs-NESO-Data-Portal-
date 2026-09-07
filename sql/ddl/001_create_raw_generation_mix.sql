CREATE TABLE IF NOT EXISTS raw.neso_generation_mix (
    datetime                TIMESTAMP WITHOUT TIME ZONE PRIMARY KEY,
    source_id               BIGINT,

    gas                     NUMERIC,
    coal                    NUMERIC,
    nuclear                 NUMERIC,
    wind                    NUMERIC,
    wind_emb                NUMERIC,
    hydro                   NUMERIC,
    imports                 NUMERIC,
    biomass                 NUMERIC,
    other                   NUMERIC,
    solar                   NUMERIC,
    storage                 NUMERIC,
    generation              NUMERIC,
    carbon_intensity        NUMERIC,
    low_carbon              NUMERIC,
    zero_carbon             NUMERIC,
    renewable               NUMERIC,
    fossil                  NUMERIC,

    gas_perc                NUMERIC,
    coal_perc               NUMERIC,
    nuclear_perc            NUMERIC,
    wind_perc               NUMERIC,
    wind_emb_perc           NUMERIC,
    hydro_perc              NUMERIC,
    imports_perc            NUMERIC,
    biomass_perc            NUMERIC,
    other_perc              NUMERIC,
    solar_perc              NUMERIC,
    storage_perc            NUMERIC,
    generation_perc         NUMERIC,
    low_carbon_perc         NUMERIC,
    zero_carbon_perc        NUMERIC,
    renewable_perc          NUMERIC,
    fossil_perc             NUMERIC,

    source_resource_id      TEXT NOT NULL,
    ingested_at             TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_neso_generation_mix_source_id
    ON raw.neso_generation_mix (source_id);

CREATE INDEX IF NOT EXISTS idx_neso_generation_mix_ingested_at
    ON raw.neso_generation_mix (ingested_at);

CREATE INDEX IF NOT EXISTS idx_neso_generation_mix_updated_at
    ON raw.neso_generation_mix (updated_at);
