CREATE OR REPLACE VIEW analytics.generation_fuel_long AS

SELECT
    g.datetime,
    g.generation_date,
    g.generation_year,
    g.generation_quarter,
    g.generation_month,
    g.generation_month_name,
    g.month_start_date,
    g.generation_day,
    g.day_of_week_number,
    g.day_of_week_name,
    g.generation_hour,
    g.generation_minute,
    g.half_hour_slot,

    fuel.fuel_type,
    fuel.fuel_group,
    fuel.fuel_sort_order,
    fuel.generation_mw,
    fuel.generation_percentage,

    g.total_generation_mw,
    g.carbon_intensity,

    g.data_quality_status,
    g.data_quality_issues

FROM analytics.generation_mix_powerbi AS g

CROSS JOIN LATERAL (
    VALUES
        (
            'Gas',
            'Fossil',
            1,
            g.gas,
            g.gas_perc
        ),
        (
            'Coal',
            'Fossil',
            2,
            g.coal,
            g.coal_perc
        ),
        (
            'Nuclear',
            'Low Carbon',
            3,
            g.nuclear,
            g.nuclear_perc
        ),
        (
            'Wind',
            'Renewable',
            4,
            g.wind,
            g.wind_perc
        ),
        (
            'Embedded Wind',
            'Renewable',
            5,
            g.wind_emb,
            g.wind_emb_perc
        ),
        (
            'Hydro',
            'Renewable',
            6,
            g.hydro,
            g.hydro_perc
        ),
        (
            'Biomass',
            'Renewable',
            7,
            g.biomass,
            g.biomass_perc
        ),
        (
            'Solar',
            'Renewable',
            8,
            g.solar,
            g.solar_perc
        ),
        (
            'Imports',
            'Imports',
            9,
            g.imports,
            g.imports_perc
        ),
        (
            'Storage',
            'Storage',
            10,
            g.storage,
            g.storage_perc
        ),
        (
            'Other',
            'Other',
            11,
            g.other,
            g.other_perc
        )
) AS fuel (
    fuel_type,
    fuel_group,
    fuel_sort_order,
    generation_mw,
    generation_percentage
);
