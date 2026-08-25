# SEO & Acquisition Analytics

Organic (SEO) and paid (Google Ads) acquisition analysed side by side —
Search Console/GA4-style and Google Ads-style synthetic data — to answer the
question that usually gets asked in two separate meetings: where should the
next euro of acquisition effort go, content or ads?

> This project uses synthetic/anonymised data inspired by real-world SEO and
> paid acquisition scenarios. No confidential company data is included. See
> [docs/methodology.md](docs/methodology.md).

## Business Problem

SEO and SEA are usually reported separately, by different people, in
different tools. That makes it hard to answer a simple question: given a
fixed amount of time or budget, does it go to content/technical SEO or to
paid campaigns? This project puts both funnels on the same metrics so that
call can be made with numbers.

## Objectives

- Measure organic performance by keyword, position and landing page.
- Measure paid performance by campaign type, language/market and time.
- Compare organic and paid on the same terms: volume, revenue, efficiency.
- Identify concrete budget and content reallocation opportunities.

## Dataset

| Table | Rows | Grain |
|---|---|---|
| `data/seo_performance.csv` | 360 | keyword x month |
| `data/google_ads.csv` | 276 | campaign x month |

Full detail: [docs/methodology.md](docs/methodology.md).

## Methodology

1. SEO: CTR by position bucket, revenue by landing page, top/bottom keywords, position trend.
2. Paid: blended and per-campaign-type ROAS, performance by market, underperforming campaigns.
3. Organic vs. paid comparison on volume, revenue and efficiency.

## Data Architecture

```text
Search Console / GA4 (synthetic)          Google Ads (synthetic)
   keyword, position, CTR                    campaign, cost, conversions
        │                                          │
        ▼                                          ▼
   organic_sessions, organic_revenue         conversion_value, ROAS
        └──────────────────┬───────────────────────┘
                             ▼
                 Combined acquisition view
                             │
                             ▼
                 Budget & content recommendations
```

## Tools

SQL (SQLite/PostgreSQL-compatible), Python (pandas), Jupyter, Google Search
Console, GA4, Google Ads, Merchant Center, SEMrush (professional experience —
see [profile](https://github.com/felix4000)).

## Analysis

| Area | File |
|---|---|
| SEO SQL | [`sql/seo_performance.sql`](sql/seo_performance.sql) |
| Paid SQL | [`sql/paid_acquisition.sql`](sql/paid_acquisition.sql) |
| Combined Python | [`python/acquisition_analysis.py`](python/acquisition_analysis.py) |
| Full walkthrough notebook | [`notebooks/seo_vs_sea_analysis.ipynb`](notebooks/seo_vs_sea_analysis.ipynb) |

Example — ROAS by campaign type (`sql/paid_acquisition.sql`):

```sql
SELECT
    SUBSTR(campaign, 1, LENGTH(campaign) - 5) AS campaign_type,
    ROUND(SUM(cost), 2)                                    AS cost,
    ROUND(SUM(conversion_value), 2)                        AS conversion_value,
    ROUND(SUM(conversion_value) / NULLIF(SUM(cost), 0), 2) AS roas
FROM google_ads
GROUP BY 1
ORDER BY roas DESC;
```

## Key Findings

1. **CTR drops sharply outside the top 10**: 12.3% average CTR for
   positions 4-10, versus 5.2% for 11-20 and 3.4% for 21+.
2. **Landing pages vary a lot in revenue per session**, not just traffic —
   some high-click category pages under-monetise relative to lower-traffic
   ones, pointing at on-page conversion rather than a visibility problem.
3. **Search - Brand ROAS (30.7x) dwarfs Search - Generic (6.5x)** and
   Shopping (8.5x) — brand budget is close to riskless, generic/shopping is
   where testing budget belongs.
4. **Organic revenue is ~1.7x paid revenue** in this dataset at zero
   marginal media cost, while paid still reaches demand SEO can't
   (new/competitor keywords, remarketing).

## Recommendations

| Finding | Recommendation |
|---|---|
| CTR falls off outside top 10 | Prioritise keywords currently ranking 11-20 — the highest-leverage zone to push into the top 10 |
| Some pages under-monetise relative to traffic | Audit on-page conversion (content, internal linking, CTAs) on high-click/low-revenue-per-session pages first |
| Brand ROAS >> Generic/Shopping ROAS | Protect brand budget, shift testing budget toward generic and shopping |
| Organic > paid revenue at zero spend | Treat SEO as a budget line with a return, not a "nice to have" next to paid |

## Project Structure

```text
seo-acquisition-analytics/
├── README.md
├── data/
│   ├── seo_performance.csv
│   └── google_ads.csv
├── sql/
│   ├── seo_performance.sql
│   └── paid_acquisition.sql
├── python/
│   └── acquisition_analysis.py
├── notebooks/
│   └── seo_vs_sea_analysis.ipynb
└── docs/
    └── methodology.md
```

## How to Run

```bash
pip install pandas
python python/acquisition_analysis.py
jupyter notebook notebooks/seo_vs_sea_analysis.ipynb
```

## Limitations

Synthetic data at a smaller scale than a real account — see
[docs/methodology.md](docs/methodology.md) for what a real Search Console/Ads
extract would add (query-level long tail, auction signals).

## About the Author

**Felix Ibeh** — Data Analyst, SEO/SEA across e-commerce catalogues.
Professional experience: 30+ campaigns across 7 languages, ~€20K monthly
budget, ~19x average ROAS (my actual work, not this synthetic dataset).

[LinkedIn](https://www.linkedin.com/in/felix-ibeh-data-analyst/) ·
[CV](https://felix4000.github.io/felix-ibeh-cv/) ·
[GitHub](https://github.com/felix4000)
# seo-acquisition-analytics
Organic vs paid acquisition analysis: SEO, Google Ads, ROAS (synthetic data)
