CREATE PROC [dbo].[CalculateElectrical](@MonthStart int,@MonthEnd int) AS
BEGIN  

/*
Stored proc CalculateElectrical
This stored proc will use historical transactions to create a budget (or overwrite one that has been populated previously). The stored proc first checks whether the budget already exists on the FinBudget table, and will create a new entry if not found.
Alternatively, the user can leave out the @name parameter and a default budget will be created for the next 12 months

Parameters: @MonthStart, start month (inclusive) to be processed
			@MonthEnd, last month (inclusive) to be processed

This is a specialised stored procedure that applies legally prescribed tariffs to electricity purchases in order to validate that the consumer is not being overcharged.

Created : 2018
Modified: 01/01/2019 by TRiekert
*/
UPDATE [dbo].[FinActualDetail]
SET [AmountAllowed] = 
/*
 
DECLARE @MonthStart int  =201805,@MonthEnd int=201805
SELECT 
--*/
fad.qty * coalesce(t.Tariff,0)/100 , [AmountAllowedExcl] =fad.qty * coalesce(t.TariffExcl,0)/100 
from [dbo].[FinActual]fa
INNER JOIN [dbo].[FinActualDetail]fad
on fa.kFinActualID = fad.fFinActualID
INNER JOIN FinTran ft
on fa.fFinTranID = ft.kFinTranID
INNER JOIN [dbo].[FinancialHierarchy]fh
on fh.kCategoryID = fa.[fCategoryID]
LEFT OUTER JOIN [dbo].[NersaTariff] t
ON fad.shortname = t.shortname
AND ft.[Transaction Date] BETWEEN t.dateStart and t.dateend
and fad.qty between thresholdlower and thresholdUpper

where fh.ShortName  = 'Electricity'
and fa.month between @MonthStart and @MonthEnd
--order by fad.ShortName,fa.month
---------------------------------------------------------------
---------------  Edit actuals where multiple monthly purchases
---------------------------------------------------------------
--DECLARE @MonthStart int  =201801,@MonthEnd int=201805
SELECT fad.kFinActualDetailID ,fad.ShortName, fad.Month,fad.qty,ndx, ft.[Posted Date] 
INTO #tarCompl
from [dbo].[FinActual]fa
INNER JOIN [dbo].[FinActualDetail]fad
on fa.kFinActualID = fad.fFinActualID
INNER JOIN FinTran ft
on fa.fFinTranID = ft.kFinTranID
INNER JOIN
(SELECT  (convert(varchar, DATEPART(yyyy,ft.[Transaction Date])) + convert(varchar,  DATEPART(m,ft.[Transaction Date]))) as ndx,fad.shortname,fad.month,count(fad.qty) count

 --select * 
from [dbo].[FinActual]fa
INNER JOIN [dbo].[FinActualDetail]fad
on fa.kFinActualID = fad.fFinActualID
INNER JOIN FinTran ft
on fa.fFinTranID = ft.kFinTranID
INNER JOIN [dbo].[FinancialHierarchy]fh
on fh.kCategoryID = fa.[fCategoryID]

WHERE 
fad.ShortName = 'voucher'
and 
fh.ShortName  = 'Electricity'
and fa.month between @MonthStart and @MonthEnd
--and (convert(varchar, DATEPART(yyyy,ft.[Transaction Date])) + convert(varchar,  DATEPART(m,ft.[Transaction Date]))) ='20164'
GROUP BY (convert(varchar, DATEPART(yyyy,ft.[Transaction Date])) + convert(varchar,  DATEPART(m,ft.[Transaction Date]))),fad.shortname,fad.month
HAVING  COUNT(fad.qtY) > 1) as flt
on fad.ShortName = flt.ShortName
and ndx = convert(varchar, DATEPART(yyyy,ft.[Transaction Date])) + convert(varchar,  DATEPART(m,ft.[Transaction Date]))



--select fad.* from #tarCompl l LEFT OUTER JOIN [dbo].[FinActualDetail]fad on fad.kFinActualDetailId = l.kFinActualDetailId

Declare @qtyagg decimal(10,4) = 0, @tarPer varchar(254) ='',@kFinActualDetailId uniqueidentifier, @ShortName varchar(20),
@Month1 int,@qty decimal(10,4),@ndx int

			DECLARE tarComplic CURSOR FOR
			------------------
			SELECT   
			--top 60  
			kFinActualDetailId,ShortName,Month,qty,ndx
	
			-----------------------
			FROM #tarCompl ORDER BY Shortname,ndx,month, [Posted Date]

			OPEN tarComplic
				FETCH tarComplic INTO @kFinActualDetailId,@ShortName,@Month1,@qty,@ndx
				WHILE @@FETCH_STATUS = 0
				BEGIN
				IF @tarPer <> (@ShortName+convert(varchar,@ndx) + convert(varchar,@Month1))
				BEGIN 


					SET @qtyagg =0
					SET @tarPer = (@ShortName+convert(varchar,@ndx) + convert(varchar,@Month1))
					UPDATE  [dbo].[FinActualDetail]

					SET [AmountAllowed] = 
					(SELECT (@qty * Tariff/100)
					
					FROM [dbo].[FinActualDetail]fad
					INNER JOIN [dbo].[FinActual]fa
					on fa.kFinActualID = fad.fFinActualID
					INNER JOIN FinTran ft
					on fa.fFinTranID = ft.kFinTranID
					INNER JOIN [dbo].[NersaTariff] t
					ON fad.shortname = t.shortname
					AND ft.[Transaction Date] BETWEEN t.dateStart and t.dateend
					WHERE fad.kFinActualDetailID =  @kFinActualDetailId
					AND   (@qtyagg + @qty <= ThresholdUpper AND @qtyagg + @qty >= ThresholdLower) )
					--where kFinActualDetailID =  @kFinActualDetailId
					--SET @qtyagg += @qty
					,[AmountAllowedExcl] =
					(SELECT (@qty * TariffExcl/100)
					
					FROM [dbo].[FinActualDetail]fad
					INNER JOIN [dbo].[FinActual]fa
					on fa.kFinActualID = fad.fFinActualID
					INNER JOIN FinTran ft
					on fa.fFinTranID = ft.kFinTranID
					INNER JOIN [dbo].[NersaTariff] t
					ON fad.shortname = t.shortname
					AND ft.[Transaction Date] BETWEEN t.dateStart and t.dateend
					WHERE fad.kFinActualDetailID =  @kFinActualDetailId
					AND   (@qtyagg + @qty <= ThresholdUpper AND @qtyagg + @qty >= ThresholdLower) )
					where kFinActualDetailID =  @kFinActualDetailId
					SET @qtyagg += @qty
				END
				ELSE
				BEGIN
					SET @tarPer = (@ShortName+convert(varchar,@ndx) + convert(varchar,@Month1))
					UPDATE [dbo].[FinActualDetail] 
					SET [AmountAllowed] = (SELECT (@qty * Tariff/100)
					FROM [dbo].[FinActualDetail]fad
					INNER JOIN [dbo].[FinActual]fa
					on fa.kFinActualID = fad.fFinActualID
					INNER JOIN FinTran ft
					on fa.fFinTranID = ft.kFinTranID
					INNER JOIN [dbo].[NersaTariff] t
					ON fad.shortname = t.shortname
					AND ft.[Transaction Date] BETWEEN t.dateStart and t.dateend
					WHERE fad.kFinActualDetailID =  @kFinActualDetailId
					AND   (@qtyagg + @qty <= ThresholdUpper AND @qtyagg + @qty >= ThresholdLower)  )
					,[AmountAllowedExcl] =
					(SELECT (@qty * TariffExcl/100)
					
					FROM [dbo].[FinActualDetail]fad
					INNER JOIN [dbo].[FinActual]fa
					on fa.kFinActualID = fad.fFinActualID
					INNER JOIN FinTran ft
					on fa.fFinTranID = ft.kFinTranID
					INNER JOIN [dbo].[NersaTariff] t
					ON fad.shortname = t.shortname
					AND ft.[Transaction Date] BETWEEN t.dateStart and t.dateend
					WHERE fad.kFinActualDetailID =  @kFinActualDetailId
					AND   (@qtyagg + @qty <= ThresholdUpper AND @qtyagg + @qty >= ThresholdLower) )

					where kFinActualDetailID =  @kFinActualDetailId
										SET @qtyagg += @qty
				END

				FETCH tarComplic INTO @kFinActualDetailId,@ShortName,@Month1,@qty,@ndx
				END
			CLOSE tarComplic
			DEALLOCATE tarComplic
			DROP TABLE #tarCompl
---------------------------------------------------------------
---------------  Edit actuals where multiple monthly purchases
---------------------------------------------------------------
END ;  

