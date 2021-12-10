CREATE PROC [Finance].[CalculateShareholdingValue] ( @Account nvarchar(10) NULL,@fAspNetUserID nvarchar(20) NULL,@EvaluationDate  date NULL) AS

/*
Stored proc ProcessShareholding Change
This procedure is used for managing shareholder contributions to a specified portfolio
The monetary contribution is converted to a portion of the portfolio as at a particular date
Any payments made to a shareholder are in turn converted to cash at the date of transaction and the portion of the portfolio attributed to the 
shareholder is similarly reduced.

Created : 2021

*/
BEGIN 

	BEGIN TRY
		IF @EvaluationDate IS NULL
		SET @EvaluationDate = GETDATE()
			--------------------------------------
			/*calculation of Shareholder portion of account portfolio on a given date

			*/
			--caclulate portfolio value each date a capital adjustment has taken place
			--First calculate market value of instruments on date of adjustment
			;WITH CapitalMovement_CTE AS
			(   SELECT
					t1.[fAccountID], t1.[DateOfTransaction],iip.[DateOfRecord],t1.[fInstrumentID],t1.Total,t1.qty, iip.[CurrentUnitCost],
					ROW_NUMBER() OVER
					(
						PARTITION BY t1.[DateOfTransaction],t1.[fInstrumentID]
						ORDER BY iip.[DateOfRecord] DESC,iip.fInstrumentCodeID
					) AS RowNum
					FROM
			--INstruments held
			(SELECT it.fAccountID,it.Total, it.DateOfTransaction,it2.fInstrumentID,SUM(it2.Quantity) qty
			FROM [Finance].[InvestmentTransactions] it (NOLOCK)
			LEFT OUTER JOIN  [Finance].[InvestmentTransactions] it2 (NOLOCK)
			ON it2.DateOfTransaction <= it.DateOfTransaction
			AND it2.Quantity<>0
			WHERE it.[fInvestmentTransactionTypeID] in ('Investment','Withdrawal')
			AND it.DateOfTransaction <= @EvaluationDate 
			AND it2.fInvestmentTransactionTypeID IN ('Instrument','Capital Repayment','Cash Reinvest','Take Up')

			GROUP BY it.fAccountID,it.Total,it.DateOfTransaction,it2.fInstrumentID
			HAVING SUM(it2.Quantity) <>0) t1
			LEFT OUTER JOIN [Finance].[InvestmentInstrumentPricing]iip (NOLOCK)
			ON t1.DateOfTransaction >= iip.[DateOfRecord]
			AND iip.fInstrumentCodeID = t1.fInstrumentID),
			--Tehn calculate cash balance on date of adjustment
			CapitalMovement_Csh_CTE AS

			(SELECT it.fAccountID, it.DateOfTransaction,SUM(it2.Total) cash
			FROM [Finance].[InvestmentTransactions] it (NOLOCK)
			LEFT OUTER JOIN  [Finance].[InvestmentTransactions] it2 (NOLOCK)
			ON it2.DateOfTransaction <= it.DateOfTransaction
			WHERE  it2.DateOfTransaction <= it.DateOfTransaction
			AND it.[fInvestmentTransactionTypeID] in ('Investment','Withdrawal')
			GROUP BY it.fAccountID,it.DateOfTransaction)
			,

			CurrentPortfolio_CTE AS
			(   SELECT
					t1.[fAccountID],t1.fASPNetUserID, t1.DateOfTransaction,t1.Amount,iip.[DateOfRecord],t1.[fInstrumentID],t1.qty, iip.[CurrentUnitCost],
					ROW_NUMBER() OVER
					(
						PARTITION BY t1.[DateOfTransaction],t1.[fInstrumentID]
						ORDER BY iip.[DateOfRecord] DESC,iip.fInstrumentCodeID
					) AS RowNum3
					FROM
			--INstruments held

			(SELECT it.fAccountID,ist.[fASPNetUserID],ist.DateOfTransaction,ist.Amount,it.fInstrumentID,SUM(it.Quantity) qty
			FROM [Finance].[InvestmentAccountShareholderTransactions](NOLOCK)ist
			LEFT OUTER JOIN [Finance].[InvestmentTransactions] it (NOLOCK)
			ON it.DateOfTransaction <= ist.DateOfTransaction
			AND it.fAccountID = ist.fAccountID
			WHERE it.fInvestmentTransactionTypeID IN ('Instrument','Capital Repayment','Cash Reinvest','Take Up')

			GROUP BY it.fAccountID,ist.[fASPNetUserID],ist.DateOfTransaction,ist.Amount,it.fInstrumentID
			HAVING SUM(it.Quantity) <>0) t1
			LEFT OUTER JOIN [Finance].[InvestmentInstrumentPricing]iip (NOLOCK)
			ON t1.DateOfTransaction >= iip.[DateOfRecord]
			AND iip.fInstrumentCodeID = t1.fInstrumentID),

			Portfolio_CTE AS
			(
				SELECT
					t1.[fAccountID], t1.[fASPNetUserID],t1.[DateOfTransaction],t1.[Amount], t2.[Portfolio Value],
					ROW_NUMBER() OVER
					(
						PARTITION BY t1.[DateOfTransaction]
						ORDER BY t2.[DateOfREcord] DESC
					) AS RowNum1
				FROM [Finance].[InvestmentAccountShareholderTransactions] (NOLOCK) t1
				INNER JOIN (select [fAccountID],DateOfRecord,sum(CurrentValue)[Portfolio Value]
			FROM [Finance].[InvestmentHoldings](NOLOCK) 
			GROUP BY [fAccountID],[DateOfRecord])
			 t2
					ON t2.[DateOfREcord] <= t1.[DateOfTransaction]
			),

			CurrentPortfolioTotl_CTE AS
			(SELECT fAccountID,fASPNetUserID,DateOfTransaction,Amount,SUM(Totl) Totl FROM
			--Calculate cash balance on date of transaction
			(
			SELECT ist.[fAccountID],ist.fASPNetUserID,ist.DateOfTransaction,ist.Amount,SUM(Total)Totl 
			FROM [Finance].[InvestmentAccountShareholderTransactions] (NOLOCK) ist
			LEFT OUTER JOIN [Finance].[InvestmentTransactions](NOLOCK) it 
			ON it.DateOfTransaction <= ist.DateOfTransaction
			AND it.fAccountID = ist.fAccountID 
			GROUP BY ist.[fAccountID],ist.[fASPNetUserID],ist.DateOfTransaction,ist.Amount

			UNION

			SELECT [fAccountID],[fASPNetUserID],DateOfTransaction,Amount,SUM(qty*CurrentUnitCost) Totl
			FROM CurrentPortfolio_CTE cm
			WHERE RowNum3 = 1
			GROUP BY [fAccountID],[fASPNetUserID],DateOfTransaction,Amount
			) t
			GROUP BY [fAccountID],[fASPNetUserID],DateOfTransaction,Amount
			),


			PortfolioValueAtTargetDate_CTE  AS
			(   SELECT
					t1.[fAccountID], t1.[DateOfTransaction],iip.[DateOfRecord],t1.[fInstrumentID],t1.qty, iip.[CurrentUnitCost],
					ROW_NUMBER() OVER
					(
						PARTITION BY t1.[DateOfTransaction],t1.[fInstrumentID]
						ORDER BY iip.[DateOfRecord] DESC,iip.fInstrumentCodeID
					) AS RowNum4
					FROM
			--INstruments held
			(SELECT  @EvaluationDate DateOfTransaction, * FROM 
			(SELECT it.fAccountID,it.fInstrumentID,SUM(it.Quantity) qty
			FROM  [Finance].[InvestmentTransactions] it (NOLOCK)
			WHERE it.DateOfTransaction <=  @EvaluationDate
			AND it.Quantity<>0
			AND it.fInvestmentTransactionTypeID IN ('Instrument','Capital Repayment','Cash Reinvest','Take Up')

			GROUP BY 
			it.fAccountID,it.fInstrumentID
			HAVING SUM(it.Quantity) <>0) t1
			) t1
			LEFT OUTER JOIN [Finance].[InvestmentInstrumentPricing]iip (NOLOCK)
			ON t1.DateOfTransaction >= iip.[DateOfRecord]
			AND iip.fInstrumentCodeID = t1.fInstrumentID),


			PortfolioValueAtTargetDateTotl_CTE AS
			(SELECT fAccountID,SUM(Totl) Totl FROM
			--Calculate cash balance on date of transaction
			(
			SELECT it.[fAccountID],SUM(Total)Totl 
			FROM [Finance].[InvestmentTransactions](NOLOCK) it 
			WHERE it.DateOfTransaction <=  @EvaluationDate
			GROUP BY it.[fAccountID]

			UNION

			SELECT [fAccountID],SUM(qty*CurrentUnitCost) Totl
			FROM PortfolioValueAtTargetDate_CTE  cm
			WHERE RowNum4 = 1
			GROUP BY [fAccountID]
			) t
			GROUP BY [fAccountID]
			)



			SELECT fAccountID,fASPNetUserID,SUM(Tot) FROM
			(SELECT st.fAccountID,st.fASPNetUserID,st.DateOfTransaction,st.ratio *exp(SUM(log(cr.ratio))) shareportion,st.ratio *exp(SUM(log(cr.ratio)))* pft.Totl Tot FROM 
			(SELECT fAccountID,fASPNetUserID,DateOfTransaction,amount/Totl ratio FROM CurrentPortfolioTotl_CTE) st
			LEFT OUTER JOIN

			(
			SELECT csh.fAccountID,csh.DateOfTransaction,(cash + COALESCE(Sec,0)  -COALESCE(total,cash))/(cash + COALESCE(Sec,0)) ratio
			FROM
			CapitalMovement_Csh_CTE csh
			LEFT OUTER JOIN
			(SELECT fAccountID,DateOfTransaction,Total,SUM(CurrentUnitCost*qty) Sec 
			FROM CapitalMovement_CTE cm
			WHERE RowNum = 1
			GROUP BY fAccountID,DateOfTransaction,Total) cm
			ON cm.fAccountID = csh.fAccountID
			AND cm.DateOfTransaction = csh.DateOfTransaction
			) cr
			ON cr.fAccountID = st.fAccountID
			AND cr.DateOfTransaction BETWEEN st.DateOfTransaction AND @EvaluationDate
			LEFT OUTER JOIN PortfolioValueAtTargetDateTotl_CTE pft
			ON st.fAccountID = pft.fAccountID
			GROUP BY  st.fAccountID,st.fASPNetUserID,st.DateOfTransaction,st.ratio,pft.Totl) tmp
			GROUP BY fAccountID,fASPNetUserID
			
	END TRY
	BEGIN CATCH
		INSERT INTO [DataIntegration].[DB_Errors]
		VALUES
		(SUSER_SNAME(),
		ERROR_NUMBER(),
		ERROR_STATE(),
		ERROR_SEVERITY(),
		ERROR_LINE(),
		ERROR_PROCEDURE(),
		ERROR_MESSAGE(),
		GETDATE(),
			COALESCE((OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)),'Custom Script'),
			'Shareholding')

			RETURN 1
	---- Transaction uncommittable
	--	IF (XACT_STATE()) = -1
	--	  ROLLBACK TRANSACTION
 
	---- Transaction committable
	--	IF (XACT_STATE()) = 1
	--	  COMMIT TRANSACTION
	END CATCH 	
	RETURN 0
END
