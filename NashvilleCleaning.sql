/* SQL Data Cleaning Project
Author: Auntiewhnor Kpolie
Date: 01/18/2022

*/

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

-- Standardize Date Format

-- see different date values
SELECT SaleDate, CONVERT(Date, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

--UPDATE PortfolioProject.dbo.NashvilleHousing
--SET SaleDate = CONVERT(Date, SaleDate)

-- change datetime format to date
ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate Date


-- NULL Property Address

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress is NULL
ORDER BY ParcelID

-- Replace the NULL addresses of duplicate ParcelIDs
SELECT N1.ParcelID, N1.PropertyAddress, N2.ParcelID, N2.PropertyAddress, ISNULL(N1.PropertyAddress, N2.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing N1
JOIN PortfolioProject.dbo.NashvilleHousing N2
ON N1.ParcelID = N2.ParcelID AND N1.[UniqueID ] <> N2.[UniqueID ]
WHERE N1.PropertyAddress is NULL

UPDATE N1
SET PropertyAddress = ISNULL(N1.PropertyAddress, N2.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing N1
JOIN PortfolioProject.dbo.NashvilleHousing N2
ON N1.ParcelID = N2.ParcelID AND N1.[UniqueID ] <> N2.[UniqueID ]


-- Separating Property Address into Individual Columns

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing

-- Substring for address and city
SELECT PropertyAddress, SUBSTRING(PropertyAddress,1, CHARINDEX(', ',PropertyAddress) - 1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
FROM PortfolioProject.dbo.NashvilleHousing

-- Create new columns and update

ALTER TABLE NashvilleHousing
ADD Address nvarchar(255),
	City nvarchar(255)

UPDATE NashvilleHousing
SET Address = SUBSTRING(PropertyAddress,1, CHARINDEX(', ',PropertyAddress) - 1),
	City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


-- Separating Owner Address (address, city, state)

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM PortfolioProject.dbo.NashvilleHousing


-- Add Columns and update

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255),
	OwnerCity nvarchar(255),
	OwnerState nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
	OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
	OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)


-- Make data in "Sold as Vacant" Consistent 

-- There's 'N', 'No', 'Y' and 'Yes'
-- Replace 'N' and 'Y' with 'No', 'Yes'
SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY COUNT(SoldAsVacant)

SELECT SoldAsVacant, 
CASE WHEN SoldAsVacant = 'N' THEN 'No'
	 WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 ELSE SoldAsVacant
END
FROM PortfolioProject.dbo.NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'N' THEN 'No'
						WHEN SoldAsVacant = 'Y' THEN 'Yes'
						ELSE SoldAsVacant
						END


-- Remove Duplicates

-- Identify With Row_Number()
WITH Duplicate AS (
SELECT *, ROW_NUMBER() OVER (PARTITION BY ParcelID,
PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) row_num
FROM PortfolioProject.dbo.NashvilleHousing)

DELETE
FROM Duplicate
WHERE row_num > 1
--ORDER BY PropertyAddress


-- Remove Unused Columns

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE Portfolio.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress