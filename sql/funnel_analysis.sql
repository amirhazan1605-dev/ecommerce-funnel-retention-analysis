-- Count unique users at each stage
SELECT
    event_type,
    COUNT(DISTINCT user_id) AS unique_users
FROM events
GROUP BY event_type
ORDER BY unique_users DESC;

-- The conversion rates in one query
WITH funnel AS (
    SELECT
        COUNT(DISTINCT user_id) FILTER (WHERE event_type = 'view')     AS viewers,
        COUNT(DISTINCT user_id) FILTER (WHERE event_type = 'cart')     AS carters,
        COUNT(DISTINCT user_id) FILTER (WHERE event_type = 'purchase') AS buyers
    FROM events
)
SELECT
    viewers,
    carters,
    buyers,
    ROUND(100.0 * carters / viewers, 2) AS view_to_cart_pct,
    ROUND(100.0 * buyers  / carters, 2) AS cart_to_purchase_pct,
    ROUND(100.0 * buyers  / viewers, 2) AS view_to_purchase_pct
FROM funnel;

-- Conversion by category
SELECT
    category_code,
    COUNT(DISTINCT user_id) FILTER (WHERE event_type = 'view')     AS viewers,
    COUNT(DISTINCT user_id) FILTER (WHERE event_type = 'cart')     AS carters,
    COUNT(DISTINCT user_id) FILTER (WHERE event_type = 'purchase') AS buyers,
    ROUND(100.0 * COUNT(DISTINCT user_id) FILTER (WHERE event_type = 'purchase')
                / NULLIF(COUNT(DISTINCT user_id) FILTER (WHERE event_type = 'view'), 0), 2)
        AS view_to_purchase_pct
FROM events
WHERE category_code IS NOT NULL
GROUP BY category_code
HAVING COUNT(DISTINCT user_id) FILTER (WHERE event_type = 'view') >= 500
ORDER BY view_to_purchase_pct DESC;

-- Conversion by brand
SELECT
    brand,
    COUNT(DISTINCT user_id) FILTER (WHERE event_type = 'view')     AS viewers,
    COUNT(DISTINCT user_id) FILTER (WHERE event_type = 'cart')     AS carters,
    COUNT(DISTINCT user_id) FILTER (WHERE event_type = 'purchase') AS buyers,
    ROUND(100.0 * COUNT(DISTINCT user_id) FILTER (WHERE event_type = 'purchase')
                / NULLIF(COUNT(DISTINCT user_id) FILTER (WHERE event_type = 'view'), 0), 2)
        AS view_to_purchase_pct
FROM events
WHERE brand IS NOT NULL
GROUP BY brand
HAVING COUNT(DISTINCT user_id) FILTER (WHERE event_type = 'view') >= 500
ORDER BY view_to_purchase_pct DESC;

-- Conversion by price range
SELECT
    CASE
        WHEN price < 20   THEN '1. Under 20'
        WHEN price < 50   THEN '2. 20 to 50'
        WHEN price < 100  THEN '3. 50 to 100'
        WHEN price < 200  THEN '4. 100 to 200'
        WHEN price < 500  THEN '5. 200 to 500'
        ELSE                   '6. 500 plus'
    END AS price_band,
    COUNT(DISTINCT user_id) FILTER (WHERE event_type = 'view')     AS viewers,
    COUNT(DISTINCT user_id) FILTER (WHERE event_type = 'cart')     AS carters,
    COUNT(DISTINCT user_id) FILTER (WHERE event_type = 'purchase') AS buyers,
    ROUND(100.0 * COUNT(DISTINCT user_id) FILTER (WHERE event_type = 'purchase')
                / NULLIF(COUNT(DISTINCT user_id) FILTER (WHERE event_type = 'view'), 0), 2)
        AS view_to_purchase_pct
FROM events
WHERE price IS NOT NULL
GROUP BY price_band
ORDER BY price_band;

