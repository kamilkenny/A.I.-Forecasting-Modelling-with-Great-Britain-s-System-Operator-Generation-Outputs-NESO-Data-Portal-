CREATE OR REPLACE VIEW analytics.generation_fuel_daily AS

SELECT
    generation_date,

    fuel_type,
    fuel_group,
    fuel_sort_order,

    COUNT(*) AS half_hour_periods,

    SUM(
        generation_mw * 0.5
    ) AS generation_mwh,

    SUM(
        generation_mw * 0.5
    ) / 1000.0 AS generation_gwh,

    AVG(
        generation_mw
    ) AS average_generation_mw,

    MAX(
        generation_mw
    ) AS peak_generation_mw,

    MIN(
        generation_mw
    ) AS minimum_generation_mw,

    CASE
        WHEN SUM(total_generation_mw) > 0
        THEN
            SUM(generation_mw)
            * 100.0
            / SUM(total_generation_mw)
    END AS fuel_share_pct,

    COUNT(*) FILTER (
        WHERE data_quality_status = 'WARNING'
    ) AS warning_periods,

    COUNT(*) FILTER (
        WHERE data_quality_status = 'PASS'
    ) AS pass_periods,

    (
        COUNT(*) = 48
    ) AS is_complete_day,

    ROUND(
        COUNT(*) * 100.0 / 48,
        2
    ) AS data_completeness_pct

FROM analytics.generation_fuel_long

GROUP BY
    generation_date,
    fuel_type,
    fuel_group,
    fuel_sort_order;
