-- ============================================================
-- SEO Performance Analysis
-- Dataset: seo_performance.csv (synthetic, Search Console/GA4-style)
-- Grain: 1 row per keyword per month
-- ============================================================

-- 1. Overall SEO KPIs
SELECT
    SUM(impressions)                                      AS impressions,
    SUM(clicks)                                            AS clicks,
    ROUND(100.0 * SUM(clicks) / NULLIF(SUM(impressions), 0), 2) AS avg_ctr_pct,
    ROUND(AVG(position), 1)                                AS avg_position,
    SUM(organic_sessions)                                  AS organic_sessions,
    ROUND(SUM(organic_revenue), 2)                         AS organic_revenue
FROM seo_performance;

-- 2. CTR by position bucket — the classic "does rank actually matter" check
SELECT
    CASE
        WHEN position <= 3  THEN '1-3'
        WHEN position <= 10 THEN '4-10'
        WHEN position <= 20 THEN '11-20'
        ELSE '21+'
    END AS position_bucket,
    COUNT(*)                                               AS keyword_months,
    ROUND(100.0 * SUM(clicks) / NULLIF(SUM(impressions), 0), 2) AS avg_ctr_pct
FROM seo_performance
GROUP BY 1
ORDER BY 1;

-- 3. Revenue and traffic by landing page
SELECT
    landing_page,
    SUM(clicks)                     AS clicks,
    ROUND(AVG(position), 1)         AS avg_position,
    SUM(organic_sessions)           AS organic_sessions,
    ROUND(SUM(organic_revenue), 2)  AS organic_revenue,
    ROUND(SUM(organic_revenue) / NULLIF(SUM(organic_sessions), 0), 2) AS revenue_per_session
FROM seo_performance
GROUP BY landing_page
ORDER BY organic_revenue DESC;

-- 4. Top and bottom keywords by revenue
SELECT keyword, SUM(clicks) AS clicks, ROUND(SUM(organic_revenue),2) AS organic_revenue
FROM seo_performance
GROUP BY keyword
ORDER BY organic_revenue DESC
LIMIT 10;

-- 5. Keywords with rising or falling position over time (trend)
-- (Compares first vs. last month on record per keyword)
WITH bounds AS (
    SELECT keyword, MIN(date) AS first_month, MAX(date) AS last_month
    FROM seo_performance
    GROUP BY keyword
),
first_pos AS (
    SELECT s.keyword, s.position AS first_position
    FROM seo_performance s JOIN bounds b ON s.keyword = b.keyword AND s.date = b.first_month
),
last_pos AS (
    SELECT s.keyword, s.position AS last_position
    FROM seo_performance s JOIN bounds b ON s.keyword = b.keyword AND s.date = b.last_month
)
SELECT
    f.keyword,
    f.first_position,
    l.last_position,
    ROUND(f.first_position - l.last_position, 1) AS position_improvement
FROM first_pos f
JOIN last_pos l ON l.keyword = f.keyword
ORDER BY position_improvement DESC;

-- 6. Monthly organic trend
SELECT date, SUM(clicks) AS clicks, SUM(organic_sessions) AS organic_sessions, ROUND(SUM(organic_revenue),2) AS organic_revenue
FROM seo_performance
GROUP BY date
ORDER BY date;
