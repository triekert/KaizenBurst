CREATE PROC [Finance].[AddFinHierarchyNodeFromTable] 
AS   
BEGIN  
	DECLARE @category int ,@descr varchar(50),@SQL1 as nvarchar(500)
	Declare unbound  cursor
	FOR 
		SELECT description,category FROM [Finance].[Unbound descriptions]

		LEFT OUTER JOIN [Finance].[FinCategorySearch] cs
		on PATINDEX('%'+description+'%',[DescrLookup])>0
		WHERE descrLookup is NULL
		AND NOT category is NULL
		OPEN unbound
			FETCH Unbound INTO @descr, @category 
			WHILE @@FETCH_STATUS = 0
			BEGIN
			--SET @SQL1 = 'Insert Into [Finance].[FinCategorySearch] VALUES ('+convert(varchar,@Category) +',''%' + @descr + '%'',''100'') '
			--exec sp_executesql @SQL1
			EXEC  [Finance].[AddFinHierarchySearch]  @category,@descr 
			FETCH Unbound INTO @descr, @category 

			END
		CLOSE Unbound
		DEALLOCATE Unbound


END ;  
--select * from [Finance].[Unbound descriptions]
--update  [Finance].[Unbound descriptions]
--set category = 47
