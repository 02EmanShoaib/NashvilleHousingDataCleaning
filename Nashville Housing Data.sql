Select *
From Nashville..NashvilleHousing

--Standardize Date Formmat
Alter Table  NashvilleHousing
Add SaleDateConverted Date;



Update  NashvilleHousing
Set SaleDateConverted = CONVERT(Date, SaleDate)

Select SaleDateConverted , CONVERT(Date, SaleDate)
From Nashville..NashvilleHousing


-- Populate Property Address if it is null
Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From Nashville..NashvilleHousing a
Join Nashville..NashvilleHousing b
 on a.ParcelID =b. ParcelID
 and a.[UniqueID ]<>b.[UniqueID ]
 where a.PropertyAddress is null

 Update a
 Set a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From Nashville..NashvilleHousing a
 Join Nashville..NashvilleHousing b
   on a.ParcelID =b. ParcelID
   and a.[UniqueID ]<>b.[UniqueID ]
 where a.PropertyAddress is null

 --Breaking the thhe Address into columns

Select Substring (propertyAddress ,1 ,(CharIndex(',',PropertyAddress)-1)),Substring (propertyAddress ,
(CharIndex(',',PropertyAddress)+1),LEN(PropertyAddress))
From Nashville..NashvilleHousing


Alter Table  NashvilleHousing
Add PropertySplitAddress nvarchar(255)


Update  NashvilleHousing
Set PropertySplitAddress = Substring (propertyAddress ,1 ,(CharIndex(',',PropertyAddress)-1))

Alter Table  NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update  NashvilleHousing
Set PropertySplitCity = Substring (propertyAddress ,(CharIndex(',',PropertyAddress)+1),LEN(PropertyAddress))

Select *
From Nashville..NashvilleHousing



select 
Parsename(Replace(OwnerAddress,',','.'),3),
Parsename(Replace(OwnerAddress,',','.'),2),
Parsename(Replace(OwnerAddress,',','.'),1)
From Nashville..NashvilleHousing

Alter Table  NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update  NashvilleHousing
Set OwnerSplitAddress = Parsename(Replace(OwnerAddress,',','.'),3)

Alter Table  NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update  NashvilleHousing
Set OwnerSplitCity = Parsename(Replace(OwnerAddress,',','.'),2)

Alter Table  NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update  NashvilleHousing
Set OwnerSplitState = Parsename(Replace(OwnerAddress,',','.'),1)


Select *
From Nashville..NashvilleHousing

--Change Y and  N to Yes and No in "Sold as Vacant"
--using Case statement
Select  Distinct(SoldAsVacant), count(SoldAsVacant)
From Nashville..NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant
,Case  When SoldAsVacant = 'Y' Then 'Yes'
       When SoldAsVacant = 'N' Then 'No'
 Else SoldAsVacant
 End
From Nashville..NashvilleHousing


Update  NashvilleHousing
Set SoldAsVacant = Case  When SoldAsVacant = 'Y' Then 'Yes'
       When SoldAsVacant = 'N' Then 'No'
 Else SoldAsVacant
 End



 -- Remmove Duplicates
With  RowNumCTE as (
Select *,
ROW_NUMBER() over (
     Partition by ParcelID  ,
	              PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  Order by 
				    UniqueId
	 )Row_num
From Nashville..NashvilleHousing
)
Select *  
From RowNumCTE
where Row_num>1
order by PropertySplitAddress

--Delete Unused column

Alter Table  Nashville..NashvilleHousing
Drop COLUMN OwnerAddress , TaxDistrict , PropertyAddress

Select *
From Nashville..NashvilleHousing

