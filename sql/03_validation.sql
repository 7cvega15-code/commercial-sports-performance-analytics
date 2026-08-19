-- Validation queries should return zero rows when the model is healthy.

-- 1. Every raw activation must map to a dealer.
SELECT f.activation_id
FROM fact_sports_activation f
LEFT JOIN dim_dealer d
  ON f.dealer_id = d.dealer_id
WHERE d.dealer_id IS NULL;

-- 2. Every raw activation must map to a sports package.
SELECT f.activation_id
FROM fact_sports_activation f
LEFT JOIN dim_sports_package p
  ON f.package_id = p.package_id
WHERE p.package_id IS NULL;

-- 3. Activation units cannot be negative.
SELECT activation_id
FROM fact_sports_activation
WHERE units < 0;

-- 4. Revenue cannot be negative.
SELECT activation_id
FROM fact_sports_activation
WHERE revenue < 0;

-- 5. Activation IDs must be unique.
SELECT activation_id
FROM fact_sports_activation
GROUP BY activation_id
HAVING COUNT(*) > 1;
