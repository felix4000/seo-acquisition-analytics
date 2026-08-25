-- ============================================================
-- Paid Acquisition (Google Ads) Analysis
-- Dataset: google_ads.csv (synthetic)
-- Grain: 1 row per campaign per month
-- ============================================================

-- 1. Overall paid performance and blended ROAS
SELECT
    COUNT(DISTINCT campaign)                        AS campaigns,
    ROUND(SUM(cost), 2)                              AS cost,
    SUM(conversions)                                 AS conversions,
    ROUND(SUM(conversion_value), 2)                  AS conversion_value,
    ROUND(SUM(conversion_value) / NULLIF(SUM(cost), 0), 2) AS roas,
    ROUND(SUM(cost) / NULLIF(SUM(conversions), 0), 2) AS cpa
FROM google_ads;

-- 2. ROAS by campaign type (brand / generic / shopping / performance max)
-- campaign names follow the pattern "<Type> - <LANG>", language code is
-- always the last 2 characters, so strip the trailing " - XX" (5 chars).
SELECT
    SUBSTR(campaign, 1, LENGTH(campaign) - 5) AS campaign_type,
    ROUND(SUM(cost), 2)                                    AS cost,
    ROUND(SUM(conversion_value), 2)                        AS conversion_value,
    SUM(conversions)                                       AS conversions,
    ROUND(SUM(conversion_value) / NULLIF(SUM(cost), 0), 2) AS roas
FROM google_ads
GROUP BY 1
ORDER BY roas DESC;

-- 3. Performance by language / market
SELECT
    language,
    country,
    ROUND(SUM(cost), 2)                                    AS cost,
    ROUND(SUM(conversion_value), 2)                        AS conversion_value,
    ROUND(SUM(conversion_value) / NULLIF(SUM(cost), 0), 2) AS roas
FROM google_ads
GROUP BY language, country
ORDER BY roas DESC;

-- 4. Monthly cost, conversions and ROAS trend
SELECT
    date,
    ROUND(SUM(cost), 2)             AS cost,
    SUM(conversions)                AS conversions,
    ROUND(SUM(conversion_value),2)  AS conversion_value,
    ROUND(SUM(conversion_value) / NULLIF(SUM(cost), 0), 2) AS roas
FROM google_ads
GROUP BY date
ORDER BY date;

-- 5. Underperforming campaigns (ROAS below the account blended average)
WITH blended AS (
    SELECT SUM(conversion_value) / NULLIF(SUM(cost), 0) AS acct_roas FROM google_ads
),
by_campaign AS (
    SELECT campaign, ROUND(SUM(cost),2) AS cost, ROUND(SUM(conversion_value),2) AS conversion_value,
           ROUND(SUM(conversion_value)/NULLIF(SUM(cost),0), 2) AS roas
    FROM google_ads
    GROUP BY campaign
)
SELECT bc.*
FROM by_campaign bc, blended b
WHERE bc.roas < b.acct_roas
ORDER BY bc.cost DESC;
