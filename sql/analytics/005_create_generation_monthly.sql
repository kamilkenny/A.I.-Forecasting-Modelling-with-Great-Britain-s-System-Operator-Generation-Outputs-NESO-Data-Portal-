CREATE OR REPLACE VIEW analytics.generation_monthly AS

WITH monthly AS (
    SELECT
        DATE_TRUNC(
            'month',
            generation_date
        )::DATE AS month_start_date,

        COUNT(*) AS half_hour_periods,

        COUNT(
            DISTINCT generation_date
        ) AS observed_days,

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
        ) AS pass_periods

    FROM analytics.generation_mix_powerbi

    GROUP BY
        DATE_TRUNC(
            'month',
            generation_date
        )::DATE
),

profiled AS (
    SELECT
        m.*,

        EXTRACT(
            YEAR FROM month_start_date
        )::INTEGER AS generation_year,

        EXTRACT(
            MONTH FROM month_start_date
        )::INTEGER AS generation_month,

        TO_CHAR(
            month_start_date,
            'FMMonth'
        ) AS generation_month_name,

        (
            DATE_PART(
                'day',
                (
                    month_start_date
                    + INTERVAL '1 month'
                    - INTERVAL '1 day'
                )
            )::INTEGER * 48
        ) AS expected_half_hour_periods

    FROM monthly AS m
)

SELECT
    month_start_date,

    generation_year,
    generation_month,
    generation_month_name,

    observed_days,
    half_hour_periods,
    expected_half_hour_periods,

    (
        half_hour_periods
        = expected_half_hour_periods
    ) AS is_complete_month,

    ROUND(
        half_hour_periods
        * 100.0
        / expected_half_hour_periods,
        2
    ) AS data_completeness_pct,

    total_generation_mwh,

    total_generation_mwh
        / 1000.0 AS total_generation_gwh,

    renewable_generation_mwh,

    renewable_generation_mwh
        / 1000.0 AS renewable_generation_gwh,

    fossil_generation_mwh,

    fossil_generation_mwh
        / 1000.0 AS fossil_generation_gwh,

    low_carbon_generation_mwh,

    low_carbon_generation_mwh
        / 1000.0 AS low_carbon_generation_gwh,

    zero_carbon_generation_mwh,

    zero_carbon_generation_mwh
        / 1000.0 AS zero_carbon_generation_gwh,

    average_generation_mw,
    peak_generation_mw,
    minimum_generation_mw,

    average_carbon_intensity,

    renewable_penetration_pct,
    fossil_penetration_pct,
    low_carbon_penetration_pct,

    warning_periods,
    pass_periods

FROM profiled;
