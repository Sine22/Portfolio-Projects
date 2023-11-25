Select * 
From PorifolioProject..NashvilleHousing

--Standardize Date Format

Select SaleDateConverted, CONVERT(Date,saledate)
From PorifolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted =CONVERT(Date,saledate)
-----------------------------

--Populate Property Address data

 Select * 
 From PorifolioProject.dbo.NashvilleHousing
 --where PropertyAddress is null
 order by ParcelID

 Select a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
 From PorifolioProject.dbo.NashvilleHousing a
 join PorifolioProject.dbo.NashvilleHousing b
 on a.ParcelID=b.ParcelID
 AND a.[UniqueID ]<> b.[UniqueID ]
 where a.PropertyAddress is null


 Update a
 Set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
 From PorifolioProject.dbo.NashvilleHousing a
 join PorifolioProject.dbo.NashvilleHousing b
 on a.ParcelID=b.ParcelID
 AND a.[UniqueID ]<> b.[UniqueID ]
 where a.PropertyAddress is null
------------------------------------

--Breaking out Adress into individual column ( Address, city , State)

 Select PropertyAddress
 from PorifolioProject.dbo.NashvilleHousing
 -- Where propertyaddress is null
 --order by ParcelID

 Select 
 SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
 SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as Address

  from PorifolioProject.dbo.NashvilleHousing
  
AlTER TABLE NashvilleHousing
add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

AlTER TABLE NashvilleHousing
add PropertySplitCity nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity =  SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))



--More powerful method

Select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From PorifolioProject..NashvilleHousing

AlTER TABLE NashvilleHousing
add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

AlTER TABLE NashvilleHousing
add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

AlTER TABLE NashvilleHousing
add OwnerSplitState nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

Select * 
From PorifolioProject..NashvilleHousing 
-----------------------------------------
-- Change Y into yes and N into NO.

Select Distinct(SoldAsVacant),Count(SoldAsVacant)
From PorifolioProject.dbo.NashvilleHousing 
Group by SoldAsVacant
order by 2

Select SoldAsVacant,
Case when SoldAsVacant='Y' then 'Yes'
	when SoldAsVacant='N' then 'No'
	else SoldAsVacant
	End
From PorifolioProject.dbo.NashvilleHousing 

Update NashvilleHousing 
Set SoldAsVacant =Case when SoldAsVacant='Y' then 'Yes'
	when SoldAsVacant='N' then 'No'
	else SoldAsVacant
	End
--------------------------------

--Remove Duplicates
Select *,
ROW_NUMBER() over(partition by 
ParcelID,Propertyaddress, saledate,saleprice, legalreference order by UniqueId) row_num

From PorifolioProject..NashvilleHousing 

With RowNumberCTE as(
Select *,
ROW_NUMBER() over(partition by 
ParcelID,Propertyaddress, saledate,saleprice, legalreference order by UniqueId) row_num

From PorifolioProject..NashvilleHousing )

Select* 
from RowNumberCTE
Where row_num >1
-----------------------------------

--Delete Unused column

Select *

From PorifolioProject..NashvilleHousing 

Alter Table PorifolioProject..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress,saledate