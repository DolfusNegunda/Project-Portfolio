-- Data cleaning

Select *
From NashvilleHousing

-- 1. Optimising date ==================================================
Select SaleDate, Convert(date, saledate), Cast(saledate as date)
From NashvilleHousing

Update NashvilleHousing
Set SaleDate = Convert(date, SaleDate)

-- Alternative if Update doesnt work
Alter Table NashvilleHousing
Add SaleDateDay date;

Update NashvilleHousing
Set SaleDateDay = Convert(date, SaleDate)

Select SaleDate, SaleDateDay
From NashvilleHousing
--======================================================================

-- 2. Populating Null values using Self join ===========================
Select * 
From NashvilleHousing
Where PropertyAddress is Null
Order by ParcelID
-- Displaying Null values

Select house1.ParcelID, house1.PropertyAddress, house2.ParcelID, house2.PropertyAddress, ISNULL(house1.PropertyAddress, house2.PropertyAddress)
From NashvilleHousing house1
Join NashvilleHousing house2
on house1.ParcelID = house2.ParcelID and house1.UniqueID <> house2.UniqueID
Where house1.PropertyAddress is Null

Update house1
Set PropertyAddress = ISNULL(house1.PropertyAddress, house2.PropertyAddress)
From NashvilleHousing house1
Join NashvilleHousing house2
on house1.ParcelID = house2.ParcelID and house1.UniqueID <> house2.UniqueID
Where house1.PropertyAddress is Null

Select ParcelID, PropertyAddress
From NashvilleHousing
Where PropertyAddress is Null
-- Above query should have no results as all blanks have been removed ===============

-- 3. Excel's "Text to columns" query to seperate grouped data into different columns
-- Starting with property address
-- One deliminator (Seperate into two columns) using substring
Select PropertyAddress,
Substring(PropertyAddress, 1, CHARINDEX(',',Propertyaddress) - 1) PropertyAddressSplit,
Substring(PropertyAddress,  CHARINDEX(',',Propertyaddress) + 1, LEN(PropertyAddress)) PropertyCitySplit,
From NashvilleHousing

Alter Table NashvilleHousing
Add PropertyAddressSplit nvarchar(250);

Update NashvilleHousing
Set PropertyAddressSplit = Substring(PropertyAddress, 1, CHARINDEX(',',Propertyaddress) - 1)

Alter Table NashvilleHousing
Add PropertyCitySplit nvarchar(250);

Update NashvilleHousing
Set PropertyCitySplit = Substring(PropertyAddress,  CHARINDEX(',',Propertyaddress) + 1, LEN(PropertyAddress))

Select PropertyAddress, PropertyAddressSplit, PropertyCitySplit
From NashvilleHousing

-- 2 deliminators using ParseName
-- Parsename uses periods "." so replace "," with "."
-- Parsename starts from the back
Select OwnerAddress,
--Parsename(OwnerAddress,1)
Parsename(Replace(OwnerAddress,',','.'),3) OwnerAddressSplit,
Parsename(Replace(OwnerAddress,',','.'),2) OwnerCitySplit,
Parsename(Replace(OwnerAddress,',','.'),1) OwnerProvince
From NashvilleHousing

Alter Table NashvilleHousing
Add OwnerAddressSplit nvarchar(250);

Update NashvilleHousing
Set OwnerAddressSplit = Parsename(Replace(OwnerAddress,',','.'),3)

Alter Table NashvilleHousing
Add OwnerCitySplit nvarchar(250);

Update NashvilleHousing
Set OwnerCitySplit = Parsename(Replace(OwnerAddress,',','.'),2)

Alter Table NashvilleHousing
Add OwnerProvince nvarchar(250);

Update NashvilleHousing
Set OwnerProvince = Parsename(Replace(OwnerAddress,',','.'),1)

Select OwnerAddress, OwnerAddressSplit, OwnerCitySplit, OwnerProvince
From NashvilleHousing
-- ========================================================================
-- 4. Standardising Columns ===============================================
-- Changing Y and N to Yes or No (Current output Yes, No, Y, N)
Select SoldAsVacant,
Case
When SoldAsVacant = 'Y' Then 'Yes'
When SoldAsVacant = 'N' Then 'No'
Else SoldAsVacant
End
From NashvilleHousing
Where SoldAsVacant = 'Y' or SoldAsVacant = 'N'

Update NashvilleHousing
Set SoldAsVacant = Case
When SoldAsVacant = 'Y' Then 'Yes'
When SoldAsVacant = 'N' Then 'No'
Else SoldAsVacant
End

Select Distinct(SoldAsVacant)
From NashvilleHousing
-- ================================================================================
-- 5. Removing duplicates
With Duplicates AS
(Select *, Row_Number() Over (Partition By ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference, OwnerName order by UniqueID) AS RowNum
From NashvilleHousing
)
Select *
From Duplicates 
Where RowNum > 1
-- Display to check duplicates

With Duplicates AS
(Select *, Row_Number() Over (Partition By ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference, OwnerName order by UniqueID) AS RowNum
From NashvilleHousing
)
Delete
From Duplicates
Where RowNum > 1
--=============================================================================================================

-- 6. Deleting columns ========================================================================================
Select *
From NashvilleHousing

Alter Table NashvilleHousing
Drop Column OwnerPovince
