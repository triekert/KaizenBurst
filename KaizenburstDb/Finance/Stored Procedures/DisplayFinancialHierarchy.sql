CREATE PROC [Finance].[DisplayFinancialHierarchy]
 AS
 BEGIN
		SELECT * FROM [Finance].[vwFinHierarchy] (NOLOCK)
		ORDER BY GreatGrandParent,GrandParent,Parent,ShortName

END ;  

