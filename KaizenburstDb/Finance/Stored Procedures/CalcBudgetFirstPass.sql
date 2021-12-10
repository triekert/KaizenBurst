CREATE PROC [Finance].[CalcBudgetFirstPass](@name nvarchar(50) = NULL) AS
/*
Stored proc CalcBudgetFirstPass
This stored proc will use historical transactions to create a budget that has been configured on the FinBudget table.

Paameter @Name, name of budget that has been configured

The budget can be configured for any period, and history for the same period a year earlier will be used to populate the budget detail.
The budget can be modified prior to approval, and actual financial performance can be tracked against multiple budgets and versions (for example a rolling 12 month budget can be set up for 
monthly management whilst bi-annual and or annual budgets can be used to provide perfomance feedback to selected stakeholdrs.

Created : 2018
Modified: 29/12/2018 by TRiekert
*/

BEGIN  
--select * from[Finance].[FinBudget]  UPDATE [Finance].[FinBudget] set  description = 'Annual budget 201805/201904'
--truncate table [Finance].[FinBudget]
DECLARE @monthbeg int,@monthend int,@budgetID uniqueidentifier,@month int--,@name nvarchar(20)

DELETE FROM [Finance].[FinBudgetDetail]
FROM  [Finance].[FinBudgetDetail] fd  (nolock)
INNER JOIN [Finance].[FinBudget] fb (nolock)
ON fb.kBudgetID = fd.fBudgetID
WHERE fb.name = @name

	IF @name IS Null
		BEGIN

		
			SET @monthbeg = YEAR(GETDATE())* 100 -100  + MONTH(GETDATE())
			PRINT CONVERT (nvarchar,@monthbeg)
			SET @monthend = @monthbeg +99
			SET @name = 'Ann B ' + CONVERT(varchar(6),@monthbeg+100) + '/' +CONVERT(varchar(6),@monthend+100)
			PRINT @name
			IF NOT EXISTS (Select * from [Finance].[FinBudget] (nolock) where name = @name)
		 INSERT INTO [Finance].[FinBudget] VALUES (@monthbeg+ 100,@monthend+100,NULL,NULL,'Annual Budget '+ RIGHT(@name,13),@name,NEWID(),NULL)
		END
	ELSE IF NOT EXISTS (Select * from [Finance].[FinBudget] (nolock) where name = @name)
		BEGIN
			PRINT 'Budget with that name has not been configured yet'

			INSERT INTO [Finance].[FinBudget] 
			VALUES(0,0,NULL,NULL,@name,@name,NEWID(),NULL)
			--RETURN
		END

	SELECT  @budgetID =kBudgetID,@monthbeg =[MonthStart]-100, @monthend=[MonthEnd]-100   FROM [Finance].[FinBudget] (nolock) where name = @name

	--DECLARE @budgetID int= 1,@monthBeg int =201705,@monthEnd int =201804	
	--DECLARE @month int
	SET @month = @monthbeg

	WHILE @month < @monthend + 1
	BEGIN
				INSERT INTO [Finance].[FinBudgetDetail]	
				Select @month +100,0,NULL,fh.kCategoryID,NULL,NULL,@budgetID 
				FROM [Finance].[FinancialHierarchy] (nolock) fh
				IF RIGHT(CONVERT(varchar,@month),2)= '12'
				SET @month = @month +89
				ELSE
				SET @month +=1
	END


--DECLARE @budgetID int= 1,@monthBeg int =201705,@monthEnd int =201804	
	UPDATE [Finance].[FinBudgetDetail]	

	SET [BudgetAmount] = COALESCE(fa.ActualAmount,0) + COALESCE(agg.ActualAmount,0) 
	--select fbd.*,fa.ActualAmount
		FROM [Finance].[FinBudgetDetail] fbd	 (nolock)
		LEFT OUTER JOIN 
		(

--DECLARE @budgetID int= 1,@monthBeg int =201705,@monthEnd int =201804	
		SELECT fa.kCategoryID,SUM(fa.ActualAmount)/12 as ActualAmount
--DECLARE @budgetID int= 1,@monthBeg int =201705,@monthEnd int =201804
	FROM (
		select  distinct  fc.kCategoryId,fa.*	
		--FROM [Finance].[FinBudgetDetail]fbd	 (nolock)
		--LEFT OUTER JOIN 
		--(
		--SELECT DISTINCT 
		FROM [Finance].[FinBudgetDetail] fbd(nolock)
		LEFT OUTER JOIN [Finance].[FinancialHierarchy] (nolock) fc
		ON fbd.fCategoryID = fc.kCategoryID	
		LEFT OUTER JOIN [Finance].[FinancialHierarchy] (nolock) fh
		ON (fh.FinHierarchyID.IsDescendantOf(fc.FinHierarchyID)) = 1 	
		INNER JOIN [Finance].[FinActual] (nolock) fa
		on fh.kCategoryID = fa.fCategoryID
		and fa.Month = fbd.Month - 100
		WHERE 
		fbd.fBudgetID =  @budgetID
		AND 
		fa.month between @monthbeg and @monthend
		AND 
		COALESCE(fa.Frequency,0)=0
		--AND COALESCE(fa.[fProjectID],0) =0
		--)


		--O
		) as fa
		GROUP by kCategoryID
		
		) as fa 
		ON fa.kCategoryID = fbd.fCategoryID




		LEFT OUTER JOIN 
--DECLARE @budgetID int= 1,@monthBeg int =201705,@monthEnd int =201804
		(SELECT agg.kCategoryID,agg.Month,SUM(agg.ActualAmount) as ActualAmount
		FROM
		(
--DECLARE @budgetID int= 1,@monthBeg int =201705,@monthEnd int =201804
		SELECT distinct  fc.kCategoryId,fa.*
		FROM [Finance].[FinBudgetDetail] fbd(nolock)
		LEFT OUTER JOIN [Finance].[FinancialHierarchy] (nolock) fc
		ON fbd.fCategoryID = fc.kCategoryID	
		LEFT OUTER JOIN [Finance].[FinancialHierarchy] (nolock) fh
		ON (fh.FinHierarchyID.IsDescendantOf(fc.FinHierarchyID)) = 1 	
		INNER JOIN [Finance].[FinActual] (nolock) fa
		on fh.kCategoryID = fa.fCategoryID
		and fa.Month = fbd.Month - 100
		WHERE 
		fbd.fBudgetID =  @budgetID
		AND 
		fa.month between @monthbeg and @monthend
		AND 
		COALESCE(fa.Frequency,0)<>0
		--AND COALESCE(fa.[fProjectID],0) =0
		) AS agg
		GROUP by kCategoryID,month
		) AS agg

		on fbd.fCategoryId = agg.kCategoryID
		AND agg.Month = fbd.Month - 100
		--order by fl.kCategoryID,fl.Month 
		

END 

--TRUNCATE TABLE [Finance].[FinBudgetDetail]	
--TRUNCATE TABLE [Finance].[FinBudget]	
--SELECT * FROM [Finance].[FinBudget]
--SELECT * FROM [Finance].[FinBudgetDetail] order by fCategoryID,Month
