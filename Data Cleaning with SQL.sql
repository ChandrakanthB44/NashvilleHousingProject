-- Data Cleaning in SQL

select * 
from PortfolioProject..NashvilleHousing

-- standardize date format
select SaleDate, CONVERT(date,SaleDate)
from PortfolioProject..NashvilleHousing
as saledateconverted

alter table NashvilleHousing
add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted = convert(date,SaleDate)

select SaleDateConverted
from PortfolioProject..NashvilleHousing

-- Populate property address data

select *
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

--Join
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

--Breaking out address into individual coloumns (Address, City, State)

select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as address
from PortfolioProject.dbo.NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress Nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

alter table NashvilleHousing
add PropertySplitCity Nvarchar(255);

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


Select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing

Select 
PARSENAME(Replace(OwnerAddress,',','.'),3)
,PARSENAME(Replace(OwnerAddress,',','.'),2)
,PARSENAME(Replace(OwnerAddress,',','.'),1)
from PortfolioProject.dbo.NashvilleHousing

alter table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)

alter table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

update NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2)


alter table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

update NashvilleHousing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'),1)

-- Change Y and N to Yes and No in "Sold as Vacant" field

select Distinct(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing

select Distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   ELSE SoldAsVacant
	   End
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
Set SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   ELSE SoldAsVacant
	   End

-- REMOVE DUPLICATES

WITH RowNumCTE as (
select *,
	ROW_NUMBER() over(
	Partition by ParcelID,
			     PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by 
				     UniqueID
					 ) row_num

from PortfolioProject.dbo.NashvilleHousing
)
Select *
From RowNumCTE
where row_num > 1
order by PropertyAddress

-- To DELETE DUPLICATES
WITH RowNumCTE as (
select *,
	ROW_NUMBER() over(
	Partition by ParcelID,
			     PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by 
				     UniqueID
					 ) row_num

from PortfolioProject.dbo.NashvilleHousing
)
Delete 
From RowNumCTE
where row_num > 1
--order by PropertyAddress


-- Delete Unused coloumns




Select *
from PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate