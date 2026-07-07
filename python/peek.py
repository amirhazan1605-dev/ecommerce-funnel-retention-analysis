import csv

path = r"C:\Users\amirh\OneDrive\Desktop\Product Funnel & Retention Analysis\events.csv"   # <-- put your real path here

with open(path, newline="", encoding="utf-8") as f:
    reader = csv.reader(f)
    header = next(reader)
    print("COLUMNS:", header)

    et = header.index("event_type") if "event_type" in header else None
    tm = header.index("event_time") if "event_time" in header else None
    types, lo, hi, sample, count = set(), None, None, [], 0

    for i, row in enumerate(reader):
        count += 1
        if i < 3:
            sample.append(row)
        if et is not None:
            types.add(row[et])
        if tm is not None:
            t = row[tm]
            lo = t if lo is None or t < lo else lo
            hi = t if hi is None or t > hi else hi

print("ROW COUNT:", count)
print("FIRST 3 ROWS:")
for r in sample: print(r)
print("UNIQUE event_type:", types)
print("EARLIEST:", lo)
print("LATEST:", hi)