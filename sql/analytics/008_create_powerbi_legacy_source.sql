CREATE OR REPLACE VIEW analytics.powerbi_legacy_source AS

SELECT
    datetime AS "DATETIME",

    gas AS "GAS",
    coal AS "COAL",
    nuclear AS "NUCLEAR",
    wind AS "WIND",
    wind_emb AS "WIND_EMB",
    hydro AS "HYDRO",
    imports AS "IMPORTS",
    biomass AS "BIOMASS",
    other AS "OTHER",
    solar AS "SOLAR",
    storage AS "STORAGE",

    generation AS "GENERATION",
    carbon_intensity AS "CARBON_INTENSITY",
    low_carbon AS "LOW_CARBON",
    zero_carbon AS "ZERO_CARBON",
    renewable AS "RENEWABLE",
    fossil AS "FOSSIL",

    gas_perc AS "GAS_perc",
    coal_perc AS "COAL_perc",
    nuclear_perc AS "NUCLEAR_perc",
    wind_perc AS "WIND_perc",
    wind_emb_perc AS "WIND_EMB_perc",
    hydro_perc AS "HYDRO_perc",
    imports_perc AS "IMPORTS_perc",
    biomass_perc AS "BIOMASS_perc",
    other_perc AS "OTHER_perc",
    solar_perc AS "SOLAR_perc",
    storage_perc AS "STORAGE_perc",
    generation_perc AS "GENERATION_perc",
    low_carbon_perc AS "LOW_CARBON_perc",
    zero_carbon_perc AS "ZERO_CARBON_perc",
    renewable_perc AS "RENEWABLE_perc",
    fossil_perc AS "FOSSIL_perc"

FROM staging.neso_generation_mix_clean

WHERE data_quality_status <> 'FAIL';
