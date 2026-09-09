CREATE OR REPLACE VIEW staging.neso_generation_mix_clean AS

WITH profiled AS (
    SELECT
        r.*,

        (
            COALESCE(gas, 0)
            + COALESCE(coal, 0)
            + COALESCE(nuclear, 0)
            + COALESCE(wind, 0)
            + COALESCE(wind_emb, 0)
            + COALESCE(hydro, 0)
            + COALESCE(imports, 0)
            + COALESCE(biomass, 0)
            + COALESCE(other, 0)
            + COALESCE(solar, 0)
            + COALESCE(storage, 0)
        ) AS component_total_mw

    FROM raw.neso_generation_mix AS r
),

quality AS (
    SELECT
        p.*,

        generation - component_total_mw
            AS generation_difference_mw,

        CASE
            WHEN
                datetime IS NULL
                OR generation IS NULL
                OR carbon_intensity IS NULL
                OR source_id IS NULL
                OR generation < 0
                OR gas < 0
                OR coal < 0
                OR nuclear < 0
                OR wind < 0
                OR solar < 0
                OR carbon_intensity < 0
                OR ABS(
                    generation - component_total_mw
                ) > 3
            THEN 'FAIL'

            WHEN
                zero_carbon_perc < 0
                OR zero_carbon_perc > 100
                OR ABS(
                    generation - component_total_mw
                ) > 1
            THEN 'WARNING'

            ELSE 'PASS'
        END AS data_quality_status,

        CONCAT_WS(
            '; ',

            CASE
                WHEN zero_carbon_perc < 0
                     OR zero_carbon_perc > 100
                THEN 'ZERO_CARBON_PERCENT_OUT_OF_RANGE'
            END,

            CASE
                WHEN ABS(
                    generation - component_total_mw
                ) > 1
                THEN 'GENERATION_COMPONENT_MISMATCH'
            END,

            CASE
                WHEN datetime IS NULL
                     OR generation IS NULL
                     OR carbon_intensity IS NULL
                     OR source_id IS NULL
                THEN 'CRITICAL_NULL'
            END,

            CASE
                WHEN generation < 0
                     OR gas < 0
                     OR coal < 0
                     OR nuclear < 0
                     OR wind < 0
                     OR solar < 0
                     OR carbon_intensity < 0
                THEN 'NEGATIVE_CORE_VALUE'
            END

        ) AS data_quality_issues

    FROM profiled AS p
)

SELECT
    datetime,

    CAST(datetime AS DATE) AS generation_date,
    EXTRACT(YEAR FROM datetime)::INTEGER AS generation_year,
    EXTRACT(QUARTER FROM datetime)::INTEGER AS generation_quarter,
    EXTRACT(MONTH FROM datetime)::INTEGER AS generation_month,
    EXTRACT(DAY FROM datetime)::INTEGER AS generation_day,
    EXTRACT(HOUR FROM datetime)::INTEGER AS generation_hour,
    EXTRACT(MINUTE FROM datetime)::INTEGER AS generation_minute,

    (
        EXTRACT(HOUR FROM datetime)::INTEGER * 2
        + CASE
            WHEN EXTRACT(MINUTE FROM datetime) = 30
            THEN 2
            ELSE 1
          END
    ) AS half_hour_slot,

    source_id,

    gas,
    coal,
    nuclear,
    wind,
    wind_emb,
    hydro,
    imports,
    biomass,
    other,
    solar,
    storage,

    generation,
    carbon_intensity,
    low_carbon,
    zero_carbon,
    renewable,
    fossil,

    gas_perc,
    coal_perc,
    nuclear_perc,
    wind_perc,
    wind_emb_perc,
    hydro_perc,
    imports_perc,
    biomass_perc,
    other_perc,
    solar_perc,
    storage_perc,
    generation_perc,
    low_carbon_perc,
    zero_carbon_perc,
    renewable_perc,
    fossil_perc,

    component_total_mw,
    generation_difference_mw,

    data_quality_status,
    NULLIF(data_quality_issues, '')
        AS data_quality_issues,

    source_resource_id,
    ingested_at,
    updated_at

FROM quality;
