CREATE OR REPLACE VIEW analytics.generation_fuel_monthly AS

WITH monthly AS (
    SELECT
        DATE_TRUNC(
            'month',
            generation_date
        )::DATE AS month_start_date,

        fuel_type,
        fuel_group,
        fuel_sort_order,

        COUNT(*) AS half_hour_periods,

        COUNT(
            DISTINCT generation_date
        ) AS observed_days,

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
        END AS fuel_share_pct

    FROM analytics.generation_fuel_long

    GROUP BY
        DATE_TRUNC(
            'month',
            generation_date
        )::DATE,
        fuel_type,
        fuel_group,
        fuel_sort_order
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
                month_start_date
                + INTERVAL '1 month'
                - INTERVAL '1 day'
            )::INTEGER * 48
        ) AS expected_half_hour_periods

    FROM monthly AS m
)

SELECT
    month_start_date,

    generation_year,
    generation_month,
    generation_month_name,

    fuel_type,
    fuel_group,
    fuel_sort_order,

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

    generation_mwh,
    generation_gwh,

    average_generation_mw,
    peak_generation_mw,
    minimum_generation_mw,

    fuel_share_pct

FROM profiled;
