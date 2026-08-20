# Commercial Sports Performance Analytics

[![SQL tests](https://github.com/7cvega15-code/commercial-sports-performance-analytics/actions/workflows/test.yml/badge.svg)](https://github.com/7cvega15-code/commercial-sports-performance-analytics/actions/workflows/test.yml)

A sanitized, synthetic portfolio reconstruction demonstrating a commercial sports-performance analytics pattern: normalize activation activity, join it to a sales hierarchy and product reference, classify customer/viewing segments, calculate period-over-period KPIs, validate the model, and publish dashboard-ready output.

> **Portfolio reconstruction:** This repository is independently created with synthetic data and generalized business rules. It does not contain employer production data, source code, proprietary table names, historical package/service codes, real customer or dealer identifiers, or production SQL.

## Why a hiring manager should care

This project demonstrates more than writing a query. It shows how a business question becomes a governed analytical capability:

**Business Questions → Data Model → Segmentation Rules → KPI Definitions → Period Comparisons → Validation → Dashboard-Ready Mart**

It complements my [Cross-Platform Audience Measurement](https://github.com/7cvega15-code/cross-platform-audience-measurement-sql) project while proving a different media-analytics skill set:

- **Audience Measurement:** reconcile heterogeneous viewing/delivery signals and preserve measurement semantics.
- **Sports Performance Analytics:** measure activations, revenue, sales hierarchy, segmentation, and performance trends.

## Business questions modeled

- How many activations occurred on the reporting day, month-to-date, and year-to-date?
- How is performance changing versus the prior week, comparable prior-month period, and prior year?
- Which channels, managers, dealers, and sports categories are driving results?
- How does performance differ across generalized viewing/customer segments?
- Do source facts map completely to governed dimensions?
- Are KPI calculations internally consistent and safe when prior-period values are zero?

## What this demonstrates

- Dimensional modeling for activation/performance analytics
- Sales-hierarchy joins and drill-down structure
- Generalized customer/viewing segmentation
- Sports-product normalization
- Daily, MTD, and YTD measures
- WoW, MoM, and YoY comparisons
- Revenue and activation KPIs
- Guarded division and null handling
- Referential-integrity and reconciliation controls
- Automated pytest validation with GitHub Actions
- Dashboard-ready analytical mart design

## Architecture

```text
Synthetic Activation Facts
          +
Synthetic Dealer / Sales Hierarchy
          +
Synthetic Sports Product Reference
          ↓
Governed Enriched Activation View
          ↓
Viewing / Customer Segment Classification
          ↓
Daily + MTD + YTD Measures
          ↓
WoW + MoM + YoY Comparisons
          ↓
Dashboard-Ready Performance Mart
          ↓
Automated Data-Quality & KPI Tests
```

## Data model

### `dim_dealer`
Synthetic dealer and sales hierarchy used to support channel → director → manager → dealer analysis.

### `dim_sports_package`
Generalized product reference such as `Pro Football Premium` and `Pro Basketball Premium`; no historical employer package names or service codes are used.

### `fact_sports_activation`
Synthetic activation events with reporting date, dealer, package, generalized account type, units, and revenue.

## KPI definitions

For each reporting grain, sales channel, director, manager, dealer, viewing segment, package, and sport category, the mart calculates:

- **Current Day Activations:** activation units on the deterministic report date
- **Month-to-Date Activations:** units from the first day of the month through the report date
- **Year-to-Date Activations:** units from January 1 through the report date
- **Same Day Prior Week:** units seven days before the report date
- **Comparable Prior-Month MTD:** prior-month activity through the same day-of-month
- **Comparable Prior-Year YTD:** prior-year activity through the comparable date
- **Current Day / MTD / YTD Revenue**
- **WoW / MoM / YoY Change:** percentage changes with guarded division; a zero prior-period denominator returns `NULL` rather than an infinite or misleading value

The demo uses a fixed synthetic report date so results remain deterministic and reproducible.

## Quality controls

The test suite validates that:

- every raw activation fact maps to both required dimensions;
- activation IDs are unique;
- units and revenue are non-negative;
- expected viewing segments are produced;
- current-day and prior-week control totals reconcile;
- a representative dealer/package WoW KPI is calculated correctly.

A key design choice is that **referential-integrity checks operate against raw facts and dimensions**, rather than checking only an already-inner-joined output where orphan records could disappear undetected.

## Repository structure

```text
.
├── .github/workflows/test.yml
├── data/
│   ├── dim_dealer.csv
│   ├── dim_sports_package.csv
│   └── fact_sports_activation.csv
├── sql/
│   ├── 01_create_views.sql
│   ├── 02_performance_mart.sql
│   └── 03_validation.sql
├── tests/
│   └── test_sports_analytics.py
├── PRIVACY.md
├── requirements.txt
└── README.md
```

## Run locally

Requires Python 3.11+.

```bash
python -m pip install -r requirements.txt
pytest -q
```

Tests build an in-memory DuckDB database, load the synthetic fixtures, execute the SQL model, and validate the core data-quality and KPI rules. GitHub Actions runs the same test suite on pushes and pull requests.

## Portfolio context

This project demonstrates the business-to-analytics pattern behind commercial media and sports performance reporting: define the decision questions, establish governed dimensions and segmentation, encode comparable KPI periods, validate the data, and provide leadership-ready performance output.

For the broader business and leadership context behind my work, see my [Notion portfolio](https://honey-safflower-f72.notion.site/Chris-Vega-3ad07c414a9980588154d596b27ac369).

See [PRIVACY.md](PRIVACY.md) for publication boundaries.