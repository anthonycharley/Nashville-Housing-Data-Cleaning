# Data Cleaning in SQL: Nashville Housing Dataset

## Project Overview
This project demonstrates the use of SQL to perform essential data cleaning and manipulation tasks on a raw housing dataset. The goal was to transform raw, messy real estate data into a structured, usable format for analysis.

Data cleaning is a critical step in the data analytics pipeline, ensuring accuracy and reliability in downstream visualizations and models.


## Technologies Used
Language: SQL

Environment: SQL Server Management Studio (SSMS)

Skills: Joins, CTEs, Window Functions, String Manipulation, Data Type Conversion


## Key Data Cleaning Steps
### 1. Standardizing Date Formats
The original SaleDate column contained unnecessary time stamps.

Action: Converted the column to a standard Date format to ensure consistency.

SQL Command: CONVERT(Date, SaleDate)


### 2. Populating Missing Property Address Data
Upon inspection, several rows had NULL values for PropertyAddress. However, the ParcelID was consistent for properties.

Logic: If a specific ParcelID has an address in one row, it should hold the same address in other rows.

Action: Performed a Self-Join on the table to match identical ParcelIDs and populated the missing addresses using ISNULL.


### 3. Breaking Out Address Columns (Granularity)
The PropertyAddress and OwnerAddress columns contained the City and State combined in a single text string (e.g., "123 Main St, Nashville, TN").

Goal: Separate these into individual columns (Address, City, State) for better filtering and aggregation.


## Methods Used:

SUBSTRING & CHARINDEX: Used to locate the comma delimiter and split the PropertyAddress.

PARSENAME: Used to split OwnerAddress. By replacing commas with periods, PARSENAME allowed for extraction of the  string segments.


### 4. Normalizing "Sold As Vacant" Field
The SoldAsVacant column contained inconsistent values: 'Y', 'N', 'Yes', and 'No'.

Action: Used a CASE statement to standardize all entries to 'Yes' and 'No' for better readability and accurate counting.


### 5. Removing Duplicates
Duplicate records can skew analysis results.

Action: Created a CTE (Common Table Expression) and used the ROW_NUMBER() window function.

Logic: Partitioned the data by unique identifiers (ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference). Any row with a row_num > 1 was identified as a duplicate and deleted.


### 6. Removing Unused Columns
To optimize the dataset for final export and storage.

Action: Dropped columns that were no longer needed after the splitting and cleaning process (e.g., raw Address columns, TaxDistrict).

## Impact & Results
The final dataset is now fully cleaned, normalized, and ready for exploratory data analysis (EDA). This process reduced data redundancy and corrected formatting errors that would have otherwise prevented accurate visualizations.
