CREATE OR REPLACE VIEW analytics.generation_daily AS

SELECT
    generation_date,

    COUNT(*) AS half_hour_periods,

    SUM(
        total_generation_mw * 0.5
    ) AS total_generation_mwh,

    SUM(
        renewable_generation_mw * 0.5
    ) AS renewable_generation_mwh,

    SUM(
        fossil_generation_mw * 0.5
    ) AS fossil_generation_mwh,

    SUM(
        low_carbon_generation_mw * 0.5
    ) AS low_carbon_generation_mwh,

    SUM(
        zero_carbon_generation_mw * 0.5
    ) AS zero_carbon_generation_mwh,

    AVG(
        total_generation_mw
    ) AS average_generation_mw,

    MAX(
        total_generation_mw
    ) AS peak_generation_mw,

    MIN(
        total_generation_mw
    ) AS minimum_generation_mw,

    AVG(
        carbon_intensity
    ) AS average_carbon_intensity,

    CASE
        WHEN SUM(total_generation_mw) > 0
        THEN
            SUM(renewable_generation_mw)
            * 100.0
            / SUM(total_generation_mw)
    END AS renewable_penetration_pct,

    CASE
        WHEN SUM(total_generation_mw) > 0
        THEN
            SUM(fossil_generation_mw)
            * 100.0
            / SUM(total_generation_mw)
    END AS fossil_penetration_pct,

    CASE
        WHEN SUM(total_generation_mw) > 0
        THEN
            SUM(low_carbon_generation_mw)
            * 100.0
            / SUM(total_generation_mw)
    END AS low_carbon_penetration_pct,

    COUNT(*) FILTER (
        WHERE data_quality_status = 'WARNING'
    ) AS warning_periods,

    COUNT(*) FILTER (
        WHERE data_quality_status = 'PASS'
    ) AS pass_periods,

    (COUNT(*) = 48) AS is_complete_day,

    ROUND(
        COUNT(*) * 100.0 / 48,
        2
    ) AS data_completeness_pct

FROM analytics.generation_mix_powerbi

GROUP BY generation_date;
