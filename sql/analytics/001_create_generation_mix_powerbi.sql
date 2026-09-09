CREATE OR REPLACE VIEW analytics.generation_mix_powerbi AS

SELECT
    datetime,

    generation_date,
    generation_year,
    generation_quarter,
    generation_month,

    TO_CHAR(
        generation_date,
        'FMMonth'
    ) AS generation_month_name,

    DATE_TRUNC(
        'month',
        generation_date
    )::DATE AS month_start_date,

    generation_day,

    EXTRACT(
        ISODOW FROM generation_date
    )::INTEGER AS day_of_week_number,

    TO_CHAR(
        generation_date,
        'FMDay'
    ) AS day_of_week_name,

    generation_hour,
    generation_minute,
    half_hour_slot,

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

    generation AS total_generation_mw,

    renewable AS renewable_generation_mw,
    fossil AS fossil_generation_mw,
    low_carbon AS low_carbon_generation_mw,
    zero_carbon AS zero_carbon_generation_mw,

    carbon_intensity,

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

    renewable_perc,
    fossil_perc,
    low_carbon_perc,
    zero_carbon_perc,

    component_total_mw,
    generation_difference_mw,

    data_quality_status,
    data_quality_issues,

    source_id,
    source_resource_id,
    ingested_at,
    updated_at

FROM staging.neso_generation_mix_clean

WHERE data_quality_status <> 'FAIL';
