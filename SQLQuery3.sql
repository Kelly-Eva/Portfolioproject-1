
-- Cleaning Data in Queries

SELECT *
FROM PortfolioProject1.dbo.NashvilleHousing


-- Standardise Sales Format

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM PortfolioProject1.dbo.NashvilleHousing


UPDATE PortfolioProject1.dbo.NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)


ALTER TABLE PortfolioProject1.dbo.NashvilleHousing
Add SaleDateConverted Date;


Update PortfolioProject1.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM PortfolioProject1.dbo.NashvilleHousing


--------------------------------------------------------------------------------
-- Populate Property Address data

SELECT *
FROM PortfolioProject1.dbo.NashvilleHousing
-- where PropertyAddress is null
ORDER BY ParcelID

-- SELF JOINING TABLES where the parcelid is the same but not same uniqueid

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyAddress, b.PropertyAddress)
FROM PortfolioProject1.dbo.NashvilleHousing a
JOIN PortfolioProject1.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


UPDATE a
SET PropertyAddress = ISNULL(a.propertyAddress, b.PropertyAddress)
FROM PortfolioProject1.dbo.NashvilleHousing a
JOIN PortfolioProject1.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyAddress, b.PropertyAddress)
FROM PortfolioProject1.dbo.NashvilleHousing a
JOIN PortfolioProject1.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject1.dbo.NashvilleHousing


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as Address
FROM PortfolioProject1.dbo.NashvilleHousing

-- Removing comma at every Address

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN (PropertyAddress)) as Address
FROM PortfolioProject1.dbo.NashvilleHousing


ALTER TABLE PortfolioProject1.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);


Update PortfolioProject1.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE PortfolioProject1.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);


Update PortfolioProject1.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN (PropertyAddress)) as Address


SELECT OwnerAddress
FROM PortfolioProject1.dbo.NashvilleHousing

-- Separating the Address, City and State in OwnerAddress
-- Using PARSENAME.
Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject1.dbo.NashvilleHousing


ALTER TABLE PortfolioProject1.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject1.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE PortfolioProject1.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject1.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE PortfolioProject1.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject1.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


Select *
From PortfolioProject1.dbo.NashvilleHousing

----------------------------------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject1.dbo.NashvilleHousing
Group by SoldAsVacant
order by SoldAsVacant

--- Using CASE STATEMENT
Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject1.dbo.NashvilleHousing


Update PortfolioProject1.dbo.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


-- HOW TO REMOVE DUPLICATES Using Row numbers

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num

From PortfolioProject1.dbo.NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

-- TO DELETE DUPLICATES,

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num

From PortfolioProject1.dbo.NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
-- ORDER BY PropertyAddress

-- CONFIRM THERE NO DUPLICATES

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num

From PortfolioProject1.dbo.NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1


--- DELETE UNUSED COLUMNS
-- (Get confirmation before deleting any data)

SELECT *
From PortfolioProject1.dbo.NashvilleHousing

ALTER TABLE PortfolioProject1.dbo.NashvilleHousing
DROP COLUMN SaleDate










