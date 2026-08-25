"""
acquisition_analysis.py

Combines SEO (organic) and Google Ads (paid) performance to compare the two
acquisition motions on the same terms: sessions/clicks, revenue, and
efficiency. This is the script version of notebooks/seo_vs_sea_analysis.ipynb,
useful for a scheduled report instead of an interactive notebook.

Usage:
    python python/acquisition_analysis.py
"""

import os
import pandas as pd

DATA_DIR = os.path.join(os.path.dirname(__file__), "..", "data")


def load():
    seo = pd.read_csv(os.path.join(DATA_DIR, "seo_performance.csv"), parse_dates=["date"])
    ads = pd.read_csv(os.path.join(DATA_DIR, "google_ads.csv"), parse_dates=["date"])
    return seo, ads


def seo_summary(seo: pd.DataFrame) -> dict:
    return {
        "impressions": int(seo["impressions"].sum()),
        "clicks": int(seo["clicks"].sum()),
        "avg_ctr_pct": round(100 * seo["clicks"].sum() / seo["impressions"].sum(), 2),
        "avg_position": round(seo["position"].mean(), 1),
        "organic_sessions": int(seo["organic_sessions"].sum()),
        "organic_revenue": round(seo["organic_revenue"].sum(), 2),
    }


def ctr_by_position_bucket(seo: pd.DataFrame) -> pd.DataFrame:
    bins = [0, 3, 10, 20, 100]
    labels = ["1-3", "4-10", "11-20", "21+"]
    seo = seo.copy()
    seo["position_bucket"] = pd.cut(seo["position"], bins=bins, labels=labels)
    out = seo.groupby("position_bucket", observed=True).agg(
        keyword_months=("keyword", "count"),
        impressions=("impressions", "sum"),
        clicks=("clicks", "sum"),
    )
    out["ctr_pct"] = round(100 * out["clicks"] / out["impressions"], 2)
    return out


def ads_summary(ads: pd.DataFrame) -> dict:
    cost = ads["cost"].sum()
    conv_value = ads["conversion_value"].sum()
    return {
        "campaigns": ads["campaign"].nunique(),
        "cost": round(cost, 2),
        "conversions": int(ads["conversions"].sum()),
        "conversion_value": round(conv_value, 2),
        "roas": round(conv_value / cost, 2),
    }


def roas_by_campaign_type(ads: pd.DataFrame) -> pd.DataFrame:
    ads = ads.copy()
    ads["campaign_type"] = ads["campaign"].str.rsplit(" - ", n=1).str[0]
    out = ads.groupby("campaign_type").agg(
        cost=("cost", "sum"), conversion_value=("conversion_value", "sum"), conversions=("conversions", "sum")
    )
    out["roas"] = round(out["conversion_value"] / out["cost"], 2)
    return out.sort_values("roas", ascending=False)


def organic_vs_paid(seo: pd.DataFrame, ads: pd.DataFrame) -> pd.DataFrame:
    organic = seo_summary(seo)
    paid = ads_summary(ads)
    return pd.DataFrame({
        "organic (SEO)": {"sessions_or_clicks": organic["organic_sessions"], "revenue": organic["organic_revenue"], "spend": 0},
        "paid (SEA)": {"sessions_or_clicks": paid["conversions"], "revenue": paid["conversion_value"], "spend": paid["cost"]},
    }).T


def main():
    seo, ads = load()
    print("=== SEO summary ===")
    for k, v in seo_summary(seo).items():
        print(f"{k}: {v}")

    print("\n=== CTR by position bucket ===")
    print(ctr_by_position_bucket(seo))

    print("\n=== Ads summary ===")
    for k, v in ads_summary(ads).items():
        print(f"{k}: {v}")

    print("\n=== ROAS by campaign type ===")
    print(roas_by_campaign_type(ads))

    print("\n=== Organic vs paid, side by side ===")
    print(organic_vs_paid(seo, ads))


if __name__ == "__main__":
    main()
