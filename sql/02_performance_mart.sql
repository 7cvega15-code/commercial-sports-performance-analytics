CREATE OR REPLACE VIEW sports_performance_mart AS
WITH params AS (
    SELECT DATE '2024-08-14' AS report_date
),
base AS (
    SELECT e.*, p.report_date
    FROM sports_activation_enriched e
    CROSS JOIN params p
),
agg AS (
    SELECT
        sales_channel,
        area_sales_director,
        area_sales_manager,
        dealer_id,
        dealer_name,
        viewing_segment,
        package_name,
        sport_category,
        SUM(CASE WHEN activation_date = report_date THEN activation_units ELSE 0 END) AS current_day_activations,
        SUM(CASE WHEN activation_date = report_date - INTERVAL '7 day' THEN activation_units ELSE 0 END) AS prior_week_same_day_activations,
        SUM(CASE WHEN activation_date BETWEEN DATE_TRUNC('month', report_date) AND report_date THEN activation_units ELSE 0 END) AS mtd_activations,
        SUM(CASE WHEN activation_date BETWEEN DATE_TRUNC('month', report_date - INTERVAL '1 month')
                 AND DATE_TRUNC('month', report_date - INTERVAL '1 month') + (EXTRACT(day FROM report_date)::INTEGER - 1) * INTERVAL '1 day'
                 THEN activation_units ELSE 0 END) AS prior_month_comparable_mtd_activations,
        SUM(CASE WHEN activation_date BETWEEN DATE_TRUNC('year', report_date) AND report_date THEN activation_units ELSE 0 END) AS ytd_activations,
        SUM(CASE WHEN activation_date BETWEEN DATE_TRUNC('year', report_date - INTERVAL '1 year') AND report_date - INTERVAL '1 year'
                 THEN activation_units ELSE 0 END) AS prior_year_comparable_ytd_activations,
        SUM(CASE WHEN activation_date = report_date THEN revenue ELSE 0 END) AS current_day_revenue,
        SUM(CASE WHEN activation_date BETWEEN DATE_TRUNC('month', report_date) AND report_date THEN revenue ELSE 0 END) AS mtd_revenue,
        SUM(CASE WHEN activation_date BETWEEN DATE_TRUNC('year', report_date) AND report_date THEN revenue ELSE 0 END) AS ytd_revenue
    FROM base
    GROUP BY ALL
)
SELECT
    *,
    CASE WHEN prior_week_same_day_activations = 0 THEN NULL
         ELSE ROUND((current_day_activations - prior_week_same_day_activations) * 1.0 / prior_week_same_day_activations, 4)
    END AS wow_activation_change_pct,
    CASE WHEN prior_month_comparable_mtd_activations = 0 THEN NULL
         ELSE ROUND((mtd_activations - prior_month_comparable_mtd_activations) * 1.0 / prior_month_comparable_mtd_activations, 4)
    END AS mom_mtd_activation_change_pct,
    CASE WHEN prior_year_comparable_ytd_activations = 0 THEN NULL
         ELSE ROUND((ytd_activations - prior_year_comparable_ytd_activations) * 1.0 / prior_year_comparable_ytd_activations, 4)
    END AS yoy_ytd_activation_change_pct
FROM agg;
