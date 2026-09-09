CREATE OR REPLACE VIEW analytics.dim_date AS

WITH date_bounds AS (
    SELECT
        MIN(generation_date) AS min_date,
        MAX(generation_date) AS max_date
    FROM analytics.generation_mix_powerbi
),

calendar AS (
    SELECT
        GENERATE_SERIES(
            min_date,
            max_date,
            INTERVAL '1 day'
        )::DATE AS calendar_date
    FROM date_bounds
)

SELECT
    calendar_date,

    TO_CHAR(
        calendar_date,
        'YYYYMMDD'
    )::INTEGER AS date_key,

    EXTRACT(
        YEAR FROM calendar_date
    )::INTEGER AS calendar_year,

    EXTRACT(
        QUARTER FROM calendar_date
    )::INTEGER AS calendar_quarter,

    'Q' || EXTRACT(
        QUARTER FROM calendar_date
    )::INTEGER AS quarter_name,

    EXTRACT(
        MONTH FROM calendar_date
    )::INTEGER AS month_number,

    TO_CHAR(
        calendar_date,
        'FMMonth'
    ) AS month_name,

    TO_CHAR(
        calendar_date,
        'Mon'
    ) AS month_short_name,

    DATE_TRUNC(
        'month',
        calendar_date
    )::DATE AS month_start_date,

    EXTRACT(
        WEEK FROM calendar_date
    )::INTEGER AS iso_week_number,

    EXTRACT(
        ISODOW FROM calendar_date
    )::INTEGER AS day_of_week_number,

    TO_CHAR(
        calendar_date,
        'FMDay'
    ) AS day_of_week_name,

    EXTRACT(
        DAY FROM calendar_date
    )::INTEGER AS day_of_month,

    EXTRACT(
        DOY FROM calendar_date
    )::INTEGER AS day_of_year,

    CASE
        WHEN EXTRACT(
            ISODOW FROM calendar_date
        ) IN (6, 7)
        THEN TRUE
        ELSE FALSE
    END AS is_weekend,

    CASE
        WHEN EXTRACT(MONTH FROM calendar_date)
            IN (12, 1, 2)
        THEN 'Winter'

        WHEN EXTRACT(MONTH FROM calendar_date)
            IN (3, 4, 5)
        THEN 'Spring'

        WHEN EXTRACT(MONTH FROM calendar_date)
            IN (6, 7, 8)
        THEN 'Summer'

        ELSE 'Autumn'
    END AS season,

    CASE
        WHEN EXTRACT(MONTH FROM calendar_date)
            IN (12, 1, 2)
        THEN 1

        WHEN EXTRACT(MONTH FROM calendar_date)
            IN (3, 4, 5)
        THEN 2

        WHEN EXTRACT(MONTH FROM calendar_date)
            IN (6, 7, 8)
        THEN 3

        ELSE 4
    END AS season_sort_order

FROM calendar;
