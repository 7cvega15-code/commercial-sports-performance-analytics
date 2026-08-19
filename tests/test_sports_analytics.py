from pathlib import Path
import duckdb
import pandas as pd

ROOT = Path(__file__).resolve().parents[1]


def build_db():
    con = duckdb.connect(database=':memory:')
    for table, filename in {
        'dim_dealer': 'dim_dealer.csv',
        'dim_sports_package': 'dim_sports_package.csv',
        'fact_sports_activation': 'fact_sports_activation.csv',
    }.items():
        path = ROOT / 'data' / filename
        df = pd.read_csv(path)
        con.register(f'{table}_df', df)
        con.execute(f'CREATE TABLE {table} AS SELECT * FROM {table}_df')

    con.execute((ROOT / 'sql' / '01_create_views.sql').read_text())
    con.execute((ROOT / 'sql' / '02_performance_mart.sql').read_text())
    return con


def test_no_duplicate_activation_ids():
    con = build_db()
    dupes = con.execute('''
        SELECT COUNT(*)
        FROM (
            SELECT activation_id
            FROM fact_sports_activation
            GROUP BY activation_id
            HAVING COUNT(*) > 1
        )
    ''').fetchone()[0]
    assert dupes == 0


def test_all_facts_map_to_dimensions():
    con = build_db()
    missing = con.execute('''
        SELECT COUNT(*)
        FROM fact_sports_activation f
        LEFT JOIN dim_dealer d ON f.dealer_id = d.dealer_id
        LEFT JOIN dim_sports_package p ON f.package_id = p.package_id
        WHERE d.dealer_id IS NULL OR p.package_id IS NULL
    ''').fetchone()[0]
    assert missing == 0


def test_current_day_total_units():
    con = build_db()
    total = con.execute('''
        SELECT SUM(current_day_activations)
        FROM sports_performance_mart
    ''').fetchone()[0]
    assert total == 12


def test_prior_week_same_day_total_units():
    con = build_db()
    total = con.execute('''
        SELECT SUM(prior_week_same_day_activations)
        FROM sports_performance_mart
    ''').fetchone()[0]
    assert total == 9


def test_viewing_segment_classification():
    con = build_db()
    segments = {
        row[0]
        for row in con.execute('''
            SELECT DISTINCT viewing_segment
            FROM sports_activation_enriched
        ''').fetchall()
    }
    assert {'Public Viewing', 'Business Viewing', 'Private Viewing', 'Lodging & Institutions'} <= segments


def test_wow_calculation_for_northstar_football():
    con = build_db()
    row = con.execute('''
        SELECT current_day_activations,
               prior_week_same_day_activations,
               wow_activation_change_pct
        FROM sports_performance_mart
        WHERE dealer_id = 'D001'
          AND package_name = 'Pro Football Premium'
    ''').fetchone()
    assert row[0] == 3
    assert row[1] == 2
    assert float(row[2]) == 0.5


def test_no_negative_units_or_revenue():
    con = build_db()
    bad = con.execute('''
        SELECT COUNT(*)
        FROM fact_sports_activation
        WHERE units < 0 OR revenue < 0
    ''').fetchone()[0]
    assert bad == 0
