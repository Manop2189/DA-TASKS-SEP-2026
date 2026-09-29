# Day 4 - Pandas Fundamentals
# Beginner-friendly solution for a Data Analyst training assignment.
# Dataset used: day4_sales.csv
# MySQL is NOT involved here; this assignment uses Python + Pandas.

import pandas as pd
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent

# ============================================================
# 1. WHAT IS PANDAS?
# ============================================================
# Pandas is a Python library used to work with tabular data.
# A DataFrame is like an Excel table: rows + columns.
# A Series is like one column of a table.

# Example Series
numbers = pd.Series([10, 20, 30])
print("Example Series:")
print(numbers)

# ============================================================
# 2. LOAD THE CSV DATASET
# ============================================================
df = pd.read_csv(BASE_DIR / "day4_sales.csv")

# Convert Order_Date from text to a real date
df["Order_Date"] = pd.to_datetime(df["Order_Date"])

print("\nFirst 5 rows:")
print(df.head())

# ============================================================
# 3. BASIC DATA EXPLORATION
# ============================================================
print("\nLast 5 rows:")
print(df.tail())

print("\nShape (rows, columns):")
print(df.shape)

print("\nColumn names:")
print(df.columns.tolist())

print("\nData types and non-null values:")
df.info()

print("\nSummary statistics:")
print(df.describe())

# ============================================================
# 4. SELECT COLUMNS - [] / LOC / ILOC
# ============================================================
print("\nSelected columns:")
print(df[["Order_ID", "Category", "Sales"]].head())

print("\nLOC - rows with label/index 0 to 2:")
print(df.loc[0:2, ["Order_ID", "Sales"]])

print("\nILOC - first 3 rows and first 3 columns:")
print(df.iloc[0:3, 0:3])

# ============================================================
# 5. IDENTIFY AND COUNT MISSING VALUES
# ============================================================
print("\nMissing values in each column:")
print(df.isnull().sum())

# Fill missing Profit using the median Profit.
# Median is used because it is less affected by very high/low values.
profit_median = df["Profit"].median()
df["Profit"] = df["Profit"].fillna(profit_median)

print("\nProfit median used for filling missing Profit:")
print(profit_median)

# Fill missing Region with "Unknown"
df["Region"] = df["Region"].fillna("Unknown")

print("\nMissing values after fillna:")
print(df.isnull().sum())

# ============================================================
# 6. FILTER DATA USING CONDITIONS
# ============================================================
print("\nCondition 1 - Sales greater than 500:")
print(df[df["Sales"] > 500][["Order_ID", "Sales"]])

print("\nCondition 2 - Profit greater than 100:")
print(df[df["Profit"] > 100][["Order_ID", "Profit"]])

print("\nCondition 3 - Technology category:")
print(df[df["Category"] == "Technology"][["Order_ID", "Category", "Sales"]])

# Multiple conditions use & and each condition needs parentheses.
print("\nCondition 4 - Technology AND Sales greater than 900:")
print(
    df[(df["Category"] == "Technology") & (df["Sales"] > 900)]
    [["Order_ID", "Category", "Sales"]]
)

# ============================================================
# 7. SORT DATA
# ============================================================
print("\nSales sorted highest to lowest:")
print(df.sort_values("Sales", ascending=False)[["Order_ID", "Sales"]])

print("\nSales sorted lowest to highest:")
print(df.sort_values("Sales", ascending=True)[["Order_ID", "Sales"]])

# ============================================================
# 8. SUMMARY STATISTICS
# ============================================================
print("\nSales summary:")
print("Mean   :", df["Sales"].mean())
print("Median :", df["Sales"].median())
print("Minimum:", df["Sales"].min())
print("Maximum:", df["Sales"].max())

# ============================================================
# 9. VALUE COUNTS
# ============================================================
print("\nNumber of orders in each category:")
print(df["Category"].value_counts())

print("\nNumber of orders in each region:")
print(df["Region"].value_counts())

# ============================================================
# 10. GROUPBY AND AGGREGATION
# ============================================================
category_summary = (
    df.groupby("Category")
      .agg(
          Total_Sales=("Sales", "sum"),
          Average_Sales=("Sales", "mean"),
          Total_Profit=("Profit", "sum"),
          Number_of_Orders=("Order_ID", "count")
      )
      .round(2)
)

print("\nCategory summary:")
print(category_summary)

# ============================================================
# 11. CALCULATED COLUMN
# ============================================================
# Sales per unit = Sales / Quantity
df["Sales_per_Unit"] = df["Sales"] / df["Quantity"]

print("\nCalculated Sales_per_Unit column:")
print(df[["Order_ID", "Sales", "Quantity", "Sales_per_Unit"]])

# ============================================================
# 12. SUPPORTING EXERCISES
# ============================================================

# Exercise 1 - Load dataset and display selected columns
print("\nExercise 1:")
print(df[["Order_ID", "Category", "Sales"]].head())

# Exercise 2 - Find total number of rows and columns
print("\nExercise 2 - rows and columns:", df.shape)

# Exercise 3 - Find duplicate records
print("\nExercise 3 - duplicate row count:", df.duplicated().sum())

# Remove duplicate rows if any exist
df_no_duplicates = df.drop_duplicates()
print("Rows after removing duplicates:", len(df_no_duplicates))

# Exercise 4 - Filter records where Sales exceeds a threshold
threshold = 500
print(f"\nExercise 4 - Sales > {threshold}:")
print(df[df["Sales"] > threshold][["Order_ID", "Sales"]])

# Exercise 5 - Top 10 highest sales
print("\nExercise 5 - Top 10 Sales:")
print(df.nlargest(10, "Sales")[["Order_ID", "Sales"]])

# Exercise 6 - Count categorical values
print("\nExercise 6 - Category counts:")
print(df["Category"].value_counts())

# Exercise 7 - Create a new calculated column
df["Profit_Margin_Per_Order"] = (df["Profit"] / df["Sales"]) * 100
print("\nExercise 7 - Profit margin:")
print(df[["Order_ID", "Sales", "Profit", "Profit_Margin_Per_Order"]].round(2))

# Exercise 8 - Group by category and calculate aggregate statistics
print("\nExercise 8 - Group by Category:")
print(
    df.groupby("Category")
      .agg(
          Total_Sales=("Sales", "sum"),
          Average_Profit=("Profit", "mean"),
          Total_Quantity=("Quantity", "sum")
      )
      .round(2)
)

# Exercise 9 - Handle missing values using fillna()
# Already demonstrated above for Profit and Region.
print("\nExercise 9 - Missing values after fillna:")
print(df.isnull().sum())

# Exercise 10 - Export cleaned dataset to a new CSV file
output_file = "day4_sales_cleaned.csv"
df.to_csv(BASE_DIR / output_file, index=False)
print(f"\nExercise 10 - Exported cleaned data to: {output_file}")

# ============================================================
# FINAL BUSINESS INSIGHTS
# ============================================================
print("\nFINAL BUSINESS INSIGHTS")
print("- Technology has the highest total sales in this sample.")
print("- The highest individual order is O1007.")
print("- One Profit value and one Region value were missing initially.")
print("- Missing Profit was filled with the median Profit.")
print("- Groupby helps compare sales/profit across categories.")
