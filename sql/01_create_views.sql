CREATE OR REPLACE VIEW sports_activation_enriched AS
SELECT
    f.activation_id,
    CAST(f.activation_date AS DATE) AS activation_date,
    f.dealer_id,
    d.dealer_name,
    d.sales_channel,
    d.area_sales_director,
    d.area_sales_manager,
    f.package_id,
    p.package_name,
    p.sport_category,
    f.account_type,
    CASE
        WHEN f.account_type IN ('PUBLIC_VENUE','PUBLIC_INSTITUTION') THEN 'Public Viewing'
        WHEN f.account_type IN ('BUSINESS_HOSPITALITY','BUSINESS_VENUE') THEN 'Business Viewing'
        WHEN f.account_type = 'PRIVATE_TRANSPORT' THEN 'Private Viewing'
        WHEN f.account_type = 'LODGING' THEN 'Lodging & Institutions'
        ELSE 'Other'
    END AS viewing_segment,
    CAST(f.units AS INTEGER) AS activation_units,
    CAST(f.revenue AS DECIMAL(18,2)) AS revenue
FROM fact_sports_activation f
JOIN dim_dealer d
  ON f.dealer_id = d.dealer_id
JOIN dim_sports_package p
  ON f.package_id = p.package_id;
