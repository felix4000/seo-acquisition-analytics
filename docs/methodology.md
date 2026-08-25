# Methodology

## Data

Synthetic Search Console/GA4-style and Google Ads-style data, generated to
be internally consistent: organic and paid revenue are allocated from the
same total site revenue used in `ecommerce-performance-analytics`, split by
realistic channel shares, so the two projects can be read together.

> This project uses synthetic/anonymised data inspired by real-world SEO and
> paid acquisition scenarios. No confidential company data, real keyword
> rankings or real campaign data is included.

## Tables

| Table | Grain | Rows |
|---|---|---|
| `data/seo_performance.csv` | 1 row per keyword per month | 360 (30 keywords x 12 months) |
| `data/google_ads.csv` | 1 row per campaign per month | 276 (23 campaigns x 12 months) |

Campaigns follow the naming pattern `<Type> - <Language code>`
(e.g. `Search - Brand - FR`), covering 4 campaign types (Search - Brand,
Search - Generic, Shopping, Performance Max) across 7 languages/markets —
smaller in scale than my actual professional campaign management (see my
[GitHub profile](https://github.com/felix4000)), and deliberately so: this
is a demonstration dataset, not a re-creation of a real account.

## Approach

1. SEO: CTR by ranking position bucket, revenue by landing page, keyword-level
   revenue ranking, position trend over time.
2. Paid: blended and per-type ROAS, performance by language/market, monthly
   trend, campaigns underperforming the account average.
3. Combined: organic vs. paid on the same axes (sessions/clicks, revenue,
   spend, efficiency) to inform budget and content prioritisation together
   instead of as two separate reports.

## Tools

SQL (SQLite/PostgreSQL-compatible), Python (pandas), Jupyter.

## Limitations

- Real SEO analysis would use actual Search Console query-level data, which
  is noisier and includes far more long-tail queries than 30 head terms.
- Real Google Ads data includes auction-level signals (impression share,
  search lost IS, quality score) not reproduced here — this dataset focuses
  on the outcome metrics (cost, conversions, ROAS) rather than the auction
  mechanics.
- Figures are illustrative of method, not a claim about any real account's
  performance.
