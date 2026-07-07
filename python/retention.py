import pandas as pd
import numpy as np

# 1. Load the SQL result
folder = r"C:\Users\amirh\OneDrive\Desktop\Product Funnel & Retention Analysis"          
df = pd.read_csv(folder + r"\cohort_data.csv")

# 2. Name the columns (in case the CSV headers are messy)
df.columns = ["cohort_week", "week_number", "unique_users"]

# 3. Reshape the tall list into a grid
grid = df.pivot_table(index="cohort_week",
                      columns="week_number",
                      values="unique_users")

# 4. Turn counts into retention % (divide each row by its week-0 value)
week0 = grid[0]                                        # each cohort's starting size
retention = grid.divide(week0, axis=0) * 100          # row-wise division, ×100
retention = retention.round(1)                         # 1 decimal place

# 5. Show it and save it for Power BI
print(retention)
retention.to_csv(folder + r"\retention_matrix.csv")
print("\nSaved retention_matrix.csv")