CREATE PROC [dbo].[RemRedundantSearches] AS
BEGIN  

--LOAD transactions from source

DELETE FROM [dbo].[FinCategorySearch]
--select * 
FROM [dbo].[FinCategorySearch] fs (nolock)
INNER JOIN 
(select fs1.kCatSrchID from [dbo].[FinCategorySearch] fs
INNER JOIN [dbo].[FinCategorySearch] fs1
ON patindex(fs.[DescrLookup],fs1.[DescrLookup])>0 
INNER JOIN [dbo].[FinancialHierarchy] fh (nolock)
on fs.fFinCategoryID = kCategoryID
where fs.kCatSrchID <> fs1.kCatSrchID) as f
on fs.kCatSrchID = f.kCatSrchID
----UPDATE 
--select * from [dbo].[FinActual] 
--select * from [dbo].[FinTran] 
--delete  from  [dbo].[FinCategorySearch] where descrlookup = 'VIDA'


END ;  
