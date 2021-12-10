CREATE PROC [Finance].[DisplayFinancialHierarchyChildren](@name nvarchar(20))
 AS
 BEGIN
		SELECT ch.[kCategoryID],  ch.[ShortName], COALESCE( ch.[Description], ch.[ShortName])[Description], ch.[Card],
		 ch.[Frequency]FROM [dbo].[FinancialHierarchy] ph (NOLOCK)
		INNER JOIN [dbo].[FinancialHierarchy] ch (NOLOCK)
		ON ch. [FinHierarchyID].GetAncestor(1) = ph.[FinHierarchyID]
		WHERE ph.ShortName = @name
		ORDER BY ch.[ShortName]


END ;  

