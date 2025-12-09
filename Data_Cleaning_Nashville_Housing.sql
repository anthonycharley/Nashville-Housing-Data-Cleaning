USE PortfolioProject;


-- DATA CLEANING PROJECT


SELECT *
FROM dbo.NashvilleHousing;


-- Standardize Date Format with CONVERT()


SELECT SaleDate, CONVERT(Date, SaleDate), SaleDateConverted
FROM dbo.NashvilleHousing;


ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;


UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate);


-- Populate Property Address Data


SELECT PropertyAddress
FROM dbo.NashvilleHousing
WHERE PropertyAddress IS NULL;


SELECT NHA.ParcelID, NHA.PropertyAddress,
	   NHB.ParcelID, NHB.PropertyAddress, ISNULL(NHA.PropertyAddress, NHB.PropertyAddress) -- IS NULL checking first value for NULL values and populating second value in its place
FROM dbo.NashvilleHousing AS NHA
	INNER JOIN dbo.NashvilleHousing AS NHB
		ON NHA.ParcelID = NHB.ParcelID
		AND NHA.[UniqueID ] != NHB.[UniqueID ]
WHERE NHA.PropertyAddress IS NULL; -- shows where NULL property addresses are hiding


UPDATE NHA
SET PropertyAddress = ISNULL(NHA.PropertyAddress, NHB.PropertyAddress)
	FROM dbo.NashvilleHousing AS NHA
	INNER JOIN dbo.NashvilleHousing AS NHB
		ON NHA.ParcelID = NHB.ParcelID
WHERE NHA.PropertyAddress IS NULL -- updating table to fix null property addresses
	

-- Breaking out Address into Individual Columns (Address, City, State) by Delimiters


SELECT PropertyAddress
FROM dbo.NashvilleHousing;


SELECT 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address, -- finding delimiter and printing output before it
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS Address -- + 1 removes comma from output
FROM dbo.NashvilleHousing;


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255); -- adding new column 'PropertySplitAddress'


UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);


ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);


UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));


SELECT OwnerAddress
FROM dbo.NashvilleHousing;


SELECT 
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM dbo.NashvilleHousing; -- Replaces comma delimiter with a period that PARSENAME looks for


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);


UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);


UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);


ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);


UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);


-- Change Y and N to Yes and No in "Sold as Vacant" field (Using a CASE statement)


SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;


SELECT SoldAsVacant,
	   CASE	
			WHEN SoldAsVacant = 'Y' THEN 'Yes'
			WHEN SoldAsVacant = 'N' THEN 'No'
			ELSE SoldAsVacant
	   END
FROM dbo.NashvilleHousing;


UPDATE NashvilleHousing
SET SoldAsVacant = CASE	
						WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
				   END;


-- Remove Duplicates (Using Window Functions and a CTE)

;WITH RowNumCTE AS (
SELECT *,
	   ROW_NUMBER() OVER (
	   PARTITION BY ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
		ORDER BY UniqueID
		) AS row_num

FROM dbo.NashvilleHousing
--ORDER BY ParcelID;
)

--DELETE (deleting duplicate rows with DELETE)
SELECT *
FROM RowNumCTE
WHERE row_num > 1;


-- Remove Unused/Unnecessary Columns

SELECT *
FROM dbo.NashvilleHousing;

ALTER TABLE dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate