"""Generate 7 days of deliberately messy smoothie shop sales CSVs."""
import random
from datetime import date, timedelta
from pathlib import Path

import pandas as pd
from faker import Faker

fake = Faker()
random.seed(42)
Faker.seed(42)

OUT_DIR = Path("data/raw")
OUT_DIR.mkdir(parents=True, exist_ok=True)

PRODUCTS = {
    "Berry Blast": 45.0,
    "Mango Tango": 48.0,
    "Green Machine": 52.0,
    "Banana Bliss": 40.0,
    "Tropical Sunrise": 50.0,
}
# Common misspellings the cleaning layer will need to fix
TYPOS = {
    "Berry Blast": ["Bery Blast", "berry blast", "BERRY BLAST"],
    "Mango Tango": ["Mango Tanggo", "mango tango", "Mango  Tango"],
    "Green Machine": ["Gren Machine", "green machine", "Green Machin"],
    "Banana Bliss": ["Banna Bliss", "banana bliss", "Banana Blis"],
    "Tropical Sunrise": ["Tropical Sunrize", "tropical sunrise", "Tropicl Sunrise"],
}
STORES = ["Soweto", "Sandton", "Randburg", "Roodepoort"]
ORDERS_PER_DAY = 500


def messy_date(d: date) -> str:
    """Return the date in one of several inconsistent formats."""
    fmt = random.choice(["%Y-%m-%d", "%d/%m/%Y", "%m-%d-%Y", "%d %b %Y"])
    return d.strftime(fmt)


def make_day(day: date, day_number: int) -> pd.DataFrame:
    rows = []
    for i in range(ORDERS_PER_DAY):
        product = random.choice(list(PRODUCTS))
        price = PRODUCTS[product]
        quantity = random.randint(1, 4)

        # Plant problems
        if random.random() < 0.08:
            product = random.choice(TYPOS[product])
        if random.random() < 0.05:
            price = None  # missing price
        if random.random() < 0.03:
            quantity = -quantity  # negative quantity
        if random.random() < 0.02:
            quantity = None  # missing quantity

        rows.append(
            {
                "order_id": f"ORD-{day_number}{i:04d}",
                "order_date": messy_date(day),
                "store": random.choice(STORES),
                "customer_name": fake.name(),
                "customer_email": fake.email(),
                "product": product,
                "quantity": quantity,
                "unit_price": price,
            }
        )

    df = pd.DataFrame(rows)

    # Duplicate about 4% of orders
    dupes = df.sample(frac=0.04, random_state=day_number)
    return pd.concat([df, dupes], ignore_index=True).sample(frac=1).reset_index(drop=True)


if __name__ == "__main__":
    start = date.today() - timedelta(days=7)
    for n in range(7):
        day = start + timedelta(days=n)
        df = make_day(day, n + 1)
        path = OUT_DIR / f"sales_{day.isoformat()}.csv"
        df.to_csv(path, index=False)
        print(f"Wrote {len(df)} rows to {path}")