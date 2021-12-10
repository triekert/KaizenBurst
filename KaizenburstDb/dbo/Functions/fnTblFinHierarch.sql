

-- =============================================
-- Author:		Riekert Tim
-- Create date: 10/04/2013
-- Description:	<Description,,>
-- =============================================
Create FUNCTION [dbo].[fnTblFinHierarch]
()
RETURNS   @FinHierSettings TABLE 

(
[kCategoryID] uniqueidentifier,
[ShortName] varchar(20),
[Parent] varchar(20),
[GrandParent] varchar(20),
[GreatGrandParent] varchar(20),
[FinHierarchyID] hierarchyid,
[Card] nvarchar(50)
  )

AS
BEGIN
INSERT INTO @FinHierSettings


SELECT * FROM [dbo].[vwFinHierarchy] (nolock)





	
	RETURN 
END


