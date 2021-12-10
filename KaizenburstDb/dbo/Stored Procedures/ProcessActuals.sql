CREATE PROC [dbo].[ProcessActuals] ( @transitTable varchar(50) NULL,@Account varchar(50) NULL,@DateOfFile date NULL,@fileName varchar(1000) NULL) AS

/*
Stored proc ProcessActuals
This stored proc will process data contained in the transit table passed as a parameter and move such data to the relevant production tables



Created : 2020
Modified: 29/12/2020 by TRiekert
*/
BEGIN 

	BEGIN TRY
		IF @transitTable = '[Finance].[InvestmentHoldingsTransit]'
		BEGIN-- @Account is not NULL, add Account to [Finance].[InvestmentAccount] if not already loaded
			IF NOT @Account is NULL
			/*
			DECLARE @transitTable varchar(50) ,@Account varchar(50),@DateOfFile date
			SET @transitTable ='[Finance].[InvestmentHoldings]'
			SET @Account = '1614486'
			SET @DateOfFile ='2019/08/07'

			--*/
			BEGIN
				IF (SELECT COUNT (kAccountID) FROM [Finance].[InvestmentAccount] (NOLOCK) 
				WHERE kAccountID = @Account) = 0 
				INSERT INTO [Finance].[InvestmentAccount] 
				Values (@Account,NULL,NULL,NULL)
			END
			-- Load all asset types not already existing
				INSERT INTO [Finance].[AssetType]
				SELECT [_Asset_Type_],[_Asset_Type_]
				FROM (SELECT DISTINCT [_Asset_Type_]  FROM [Finance].[InvestmentHoldingsTransit] trns (NOLOCK)) as trns
				LEFT OUTER JOIN [Finance].[AssetType] sec (NOLOCK)
				ON[_Asset_Type_] =[kAssetTypeID]
				WHERE [kAssetTypeID] IS NULL
			-- Load all investmentCategories not already existing
				INSERT INTO [Finance].[InvestementCategory]
				SELECT [_Investment_Category_],[_Investment_Category_]
				FROM (SELECT DISTINCT [_Investment_Category_]  FROM [Finance].[InvestmentHoldingsTransit] trns (NOLOCK)) as trns
				LEFT OUTER JOIN [Finance].[InvestementCategory]sec (NOLOCK)
				ON[_Investment_Category_] =[kInvestmentCategoryID]
				WHERE [kInvestmentCategoryID] IS NULL
			-- Load all sectors not already existing
				INSERT INTO [Finance].[Sector] 
				SELECT [_Sector_],[_Sector_]
				FROM (SELECT DISTINCT _Sector_  FROM [Finance].[InvestmentHoldingsTransit] trns (NOLOCK)) as trns
				LEFT OUTER JOIN [Finance].[Sector] sec (NOLOCK)
				ON [_Sector_] =[kSectorID]
				WHERE [kSectorID] IS NULL
			--then add instrument codes not already existing
				INSERT INTO [Finance].[Instrument]
				SELECT [_Code_],NULL,[_Description_],[_Investment_Category_],[_Asset_Type_],[_Sector_],NULL
				FROM (SELECT DISTINCT [_Code_],[_Description_],[_Investment_Category_],[_Asset_Type_],[_Sector_] FROM [Finance].[InvestmentHoldingsTransit] trns (NOLOCK)) as trns
				LEFT OUTER JOIN [Finance].[Instrument] sec (NOLOCK)
				ON [_Code_] =[kInstrumentCodeID]
				WHERE [kInstrumentCodeID] IS NULL
			--then add records from transit table to production table if not already exising


					/*
			DECLARE @transitTable varchar(50) ,@Account varchar(50),@DateOfFile date
			SET @transitTable ='[Finance].[InvestmentHoldings]'
			SET @Account = '1614486'
			SET @DateOfFile ='2019/08/07'

			--*/
				INSERT INTO [Finance].[InvestmentInstrumentPricing]


				SELECT 
				@DateOfFile,
				kInstrumentCodeID,[_Reference_Currency_],
				CASE WHEN  kInstrumentCodeID like '%CSH%' THEN CONVERT(decimal(14,4),[_Reference_Value_])
				ELSE 
				CONVERT(decimal(14,4),[_Base_Price_])
				END,
				CONVERT(decimal(14,4),[_Exchange_Rate_])
				FROM (SELECT DISTINCT kInstrumentCodeID,[_Reference_Currency_],[_Base_Price_],[_Reference_Value_],[_Exchange_Rate_] FROM [Finance].[InvestmentHoldingsTransit] trns (NOLOCK)
				LEFT OUTER JOIN [Finance].[Instrument] sec (NOLOCK)
				ON [_Code_] =[kInstrumentCodeID]
				) as trans
				LEFT OUTER JOIN [Finance].[InvestmentInstrumentPricing] invp (NOLOCK)
				ON fInstrumentCodeID = kInstrumentCodeID			
				AND DateOfRecord = @DateOfFile

				WHERE fInstrumentCodeID is NULL 

				INSERT INTO [Finance].[InvestmentHoldings]
				SELECT 
				@DateOfFile,@Account,
				kInstrumentCodeID,CONVERT(decimal(10,3),[_Quantity_]),[_Reference_Currency_],[_Reference_Unit_Cost_],[_Reference_Cost_],[_Base_Currency_],[_Reference_Price_],[_Reference_Value_],[_Exchange_Rate_]
				FROM (SELECT DISTINCT kInstrumentCodeID,[_Quantity_],[_Reference_Currency_],[_Reference_Unit_Cost_],[_Reference_Cost_],[_Base_Currency_],[_Reference_Price_],[_Reference_Value_],[_Exchange_Rate_]  FROM [Finance].[InvestmentHoldingsTransit] trns (NOLOCK)
				LEFT OUTER JOIN [Finance].[Instrument] sec (NOLOCK)
				ON [_Code_] =[kInstrumentCodeID]
				) as trans
				LEFT OUTER JOIN [Finance].[InvestmentHoldings] invh (NOLOCK)
				ON fInstrumentCodeID = kInstrumentCodeID			
				AND DateOfRecord = @DateOfFile
				AND fAccountID = @Account

				WHERE fInstrumentCodeID is NULL
				--Then empty the transit table
				DELETE FROM [Finance].[InvestmentHoldingsTransit]
		END
		IF @transitTable = '[Finance].[InvestmentTransactionsTransit]'
--##########################################################################################
/*
An Account may have many investments linked to it.
Transactions linked at account level are:
-Adding of Capital 
-Extracting of Capital
-Puchase of investment/s
-Sale of Investments
-Partial Capital returned from investments
-Income from investments
--Dividends
--Interest
--Other Income
--Foreign Dividends
-Deductions
--Tax Witheld from Dividends
--Tax Witheld from Foreign Dividends

Every investment is in turn linked to an Instrument, and the investment has the following possible transactions
-Purchase of instrument
--Straight purchase
--Straighe sale
an Account and are 
*/
--##########################################################################################
		BEGIN

			SET @transitTable ='InvestmentTransactions'
			DELETE  FROM [Finance].[InvestmentTransactionsTransit] WHERE ISDATE([1614486_Laceya Susanna Riekert_JSE]) = 0 
			UPDATE [Finance].[InvestmentTransactionsTransit]
			SET F3 = REPLACE(F3,'SYGMSCIUS','SATRIXNDQ')
			UPDATE [Finance].[InvestmentTransactionsTransit]
			SET F5 = REPLACE(F5,'SYGMSCIUS','SATRIXNDQ')
			UPDATE [Finance].[InvestmentTransactionsTransit]
			SET F5 = REPLACE(F5,'NEWBELCO SA/NV','UNEWCO')
--ONLY PROCESS NEW TRANSACTIONS
			DELETE [Finance].[InvestmentTransactionsTransit] 
			--select  * --CONVERT(money, itt.F6 ),CONVERT(money, itp.F6 ),CONVERT(money, itt.F7 ),CONVERT(money, itp.F7 ),
			FROM  [Finance].[InvestmentTransactionsTransit] (NOLOCK)itt
			LEFT  JOIN [Finance].[InvestmentTransactionsProcessed] (NOLOCK)itp
			ON itt.[1614486_Laceya Susanna Riekert_JSE]=itp.[1614486_Laceya Susanna Riekert_JSE]
			AND itt.F2 = itp.F2
			AND itt.F3 = itp.F3
			AND COALESCE(itt.F5,'') = COALESCE(itp.F5,'') 
			AND CONVERT(money, itt.F6 ) = CONVERT(money, itp.F6 )
			AND CONVERT(money, itt.F7 ) = CONVERT(money, itp.F7 )
--ORDER BY CONVERT(datetime,itt.[1614486_Laceya Susanna Riekert_JSE],102)desc
--SELECT * FROM [Finance].[InvestmentTransactionsProcessed] (NOLOCK)itt
--ORDER BY CONVERT(datetime,[1614486_Laceya Susanna Riekert_JSE],102)desc

			WHERE NOT itp.F2 IS NULL
--COPY NEW TRANSACTIONS TO INTERIM PROCESSING TABLE
INSERT INTO [Finance].[InvestmentTransactionsInterim]
SELECT * FROM [Finance].[InvestmentTransactionsTransit] (NOLOCK)itt

--UPDATE MASTER HISTORY TABLE
INSERT INTO [Finance].[InvestmentTransactionsProcessed]
SELECT * FROM [Finance].[InvestmentTransactionsTransit] (NOLOCK)itt

-- add instrument codes not already existing
				INSERT INTO [Finance].[Instrument]
				--SELECT 'NEW','BHPBILL','BHP',NULL,NULL,NULL,'BHP BILLITON'

				SELECT F5,NULL,F5,NULL,NULL,NULL,NULL FROM
				(SELECT DISTINCT [F5]  from [Finance].[InvestmentTransactionsInterim](NOLOCK)
				WHERE NOT F5 IS NULL AND NOT F5 = 'Share name') AS trns

				LEFT OUTER JOIN [Finance].[Instrument] sec (NOLOCK)
				ON F5 =[kInstrumentCodeID] OR F5 =[kAlternateCodeID]OR F5 =[k2ndAlternateID]
				WHERE [kInstrumentCodeID] IS NULL

--Then add new instrument prices for specific transaction dates if not already recorded
				INSERT INTO [Finance].[InvestmentInstrumentPricing]
						SELECT CONVERT(datetime,Date,102),kInstrumentCodeID,'ZAR',[unit cost],NULL FROM 
							(SELECT [1614486_Laceya Susanna Riekert_JSE] [Date],F5[Investment],[unit cost]/qty [unit cost],qty,total, [Unit Cost Incl] FROM -- -(PATINDEX('% at %',F3 )+4)))/100  * CONVERT(money,F6))[unit cost], SUM(CONVERT(money,F6)) qty, SUM(CONVERT(money,F7)) total, SUM(CONVERT(money,F7)) / SUM(CONVERT(money,F6)) [Unit Cost] FROM
								(SELECT ft.[1614486_Laceya Susanna Riekert_JSE],ft.F5,SUM(CONVERT(money,SUBSTRING(F3,PATINDEX('% at %',F3)+4, PATINDEX('%Cents%',F3 ) -(PATINDEX('% at %',F3 )+4)))/100  * CONVERT(money,F6))[unit cost], SUM(CONVERT(money,F6)) qty, SUM(CONVERT(money,F7)) total, SUM(CONVERT(money,F7)) / SUM(CONVERT(money,F6)) [Unit Cost Incl] FROM
									(SELECT [1614486_Laceya Susanna Riekert_JSE],F5 FROM
										(SELECT [1614486_Laceya Susanna Riekert_JSE],F5, SUM(CONVERT(money,F6)) qty, SUM(CONVERT(money,F7)) total FROM [Finance].[InvestmentTransactionsInterim](NOLOCK)
										WHERE NOT F5 IS NULL AND NOT F5 = 'Share name'
										GROUP BY  [1614486_Laceya Susanna Riekert_JSE],F5) tmp
										WHERE qty <> 0) tmp
									LEFT OUTER JOIN [Finance].[InvestmentTransactionsInterim](NOLOCK) ft
									ON tmp.[1614486_Laceya Susanna Riekert_JSE] = ft.[1614486_Laceya Susanna Riekert_JSE]
									AND tmp.F5 = ft.F5
									GROUP BY  ft.[1614486_Laceya Susanna Riekert_JSE],ft.F5--,CONVERT(money,SUBSTRING(F3,PATINDEX('% at %',F3)+4, PATINDEX('%Cents%',F3 ) -(PATINDEX('% at %',F3 )+4)))/100
								) tmp) tmp
							LEFT OUTER JOIN [Finance].[Instrument] fi (NOLOCK)
											ON Investment =[kInstrumentCodeID] OR Investment =[kAlternateCodeID]
							OR fi.[k2ndAlternateID] LIKE  (SELECT Investment + '%')
						OR Investment LIKE  (SELECT [k2ndAlternateID]  + '%')

							LEFT OUTER JOIN [Finance].[InvestmentInstrumentPricing] fip (NOLOCK)
							ON [fInstrumentCodeID] = [kInstrumentCodeID]
							AND [DateOfRecord] = CONVERT(datetime,Date,102)
				
							WHERE [DateOfRecord] IS NULL AND [unit cost]=0


--##########################################################
--All transactions affecting share totals
--##########################################################
--- Add all investment transaction SELECT *  FROM [Finance].[InvestmentTransactions]
-- instrument movements (shares) indicated by value in F5
									INSERT INTO [Finance].[InvestmentTransactions]
									SELECT CONVERT(datetime,Date,102) Date,Instrument,'Instrument',Account,'Instrument movement - increase or decrease in quantity', qty,tmp.total,tmp.price/qty,NULL,tmp.total/qty * -1[Unit Cost] --, [Unit Cost Incl] 
									FROM 	
											(SELECT Date,Instrument,Account, SUM(CONVERT(money,F6)) qty, SUM(CONVERT(money,F7)) total, SUM(CONVERT(money,SUBSTRING(F3,PATINDEX('% at %',F3)+4, PATINDEX('%Cents%',F3 ) -(PATINDEX('% at %',F3 )+4)))/100*(CONVERT(money,F6))) [price] FROM
	
		
													(SELECT [1614486_Laceya Susanna Riekert_JSE] Date,[kInstrumentCodeID] Instrument, F2 Account, F6,F7,F3 FROM [Finance].[InvestmentTransactionsInterim](NOLOCK)
	
														LEFT OUTER JOIN [Finance].[Instrument] fi (NOLOCK)
														ON fi.[kInstrumentCodeID]=F5
														OR fi.[kAlternateCodeID]=F5
														OR fi.[k2ndAlternateID]=F5
														WHERE NOT F5 IS NULL AND NOT F5 = 'Share name'
														AND NOT CONVERT(money,F6)=0
														AND CONVERT(money,SUBSTRING(F3,PATINDEX('% at %',F3)+4, PATINDEX('%Cents%',F3 ) -(PATINDEX('% at %',F3 )+4))) <>0
													) tmp
	
												GROUP BY  Date,Instrument,Account) tmp


											LEFT OUTER JOIN [Finance].[Instrument] fi (NOLOCK)
											ON fi.[kInstrumentCodeID]=tmp.Instrument
											OR fi.[kAlternateCodeID]=tmp.Instrument
											OR fi.[k2ndAlternateID] LIKE  (SELECT tmp.Instrument + '%')
											OR tmp.Instrument LIKE  (SELECT [k2ndAlternateID]  + '%')
											LEFT OUTER JOIN [Finance].[InvestmentTransactions] fit
											ON fit.[DateOfTransaction] =CONVERT(datetime,tmp.Date,102)
											AND fit.[fInstrumentID]= [kInstrumentCodeID]
											AND [fInvestmentTransactionTypeID] = 'Instrument'
											AND [Account Number] = Account
											WHERE fit.[fInstrumentID] IS NULL
											and qty <>0--tmp.total <>0

-- Take up of  (shares) indicated by value in F5
					INSERT INTO [Finance].[InvestmentTransactions]
					SELECT tmp.Date,tmp.instrument ,'Take Up',tmp.F2 Account ,'Take up of share offer',tmp.qty,tmp.total,tmp.total/tmp.qty*-1,'I.CSH',tmp.total/tmp.qty*-1 FROM
						(SELECT CONVERT(datetime,[1614486_Laceya Susanna Riekert_JSE],102) Date, CASE WHEN PATINDEX('%RESIDUAL DIV%',F3 )>0 THEN SUBSTRING(F3,PATINDEX('%RESIDUAL DIV%',F3)+13,LEN(F3)) ELSE SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3)) END Instrument,
						--F2, SUBSTRING(F3,PATINDEX('%-[0-9]%',F3)+1,LEN(F3))/*,PATINDEX('%[0-9] %',SUBSTRING(F3,PATINDEX('% [0-9]%',F3),LEN(F3)))+1)*/ qty ,SUM(CONVERT(money,F7))total 
						F2, SUM(CONVERT(money,LEFT(SUBSTRING(F3,PATINDEX('%-[0-9]%',F3)+1,LEN(F3)),PATINDEX('%[0-9] %',SUBSTRING(F3,PATINDEX('%-[0-9]%',F3)+1,LEN(F3)))+1))) qty ,SUM(CONVERT(money,F7))total 
						FROM [Finance].[InvestmentTransactionsInterim](NOLOCK)
						WHERE  F5 IS NULL AND NOT F3  IS NULL
						--AND LEFT(F3,4) = 'INT ' --Interest payment
						AND PATINDEX('%Take Up%',F3 )>0 --AND PATINDEX('% TAX %',F3 )= 0 AND    PATINDEX('%REIT%',F3 ) = 0 AND  PATINDEX('%FOREIGN%',F3 ) = 0 AND PATINDEX('%REV.DIV%',F3 ) = 0 
						GROUP BY CONVERT(datetime,[1614486_Laceya Susanna Riekert_JSE],102),
						CASE WHEN PATINDEX('%RESIDUAL DIV%',F3 )>0 THEN SUBSTRING(F3,PATINDEX('%RESIDUAL DIV%',F3)+13,LEN(F3)) ELSE SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3)) END ,F2
						--,CONVERT(money,LEFT(SUBSTRING(F3,PATINDEX('%-[0-9]%',F3)+1,LEN(F3)),PATINDEX('%[0-9] %',SUBSTRING(F3,PATINDEX('%-[0-9]%',F3)+1,LEN(F3)))+1))
						) tmp	 -- Div Instrument ,F2, CONVERT(money,F7) qty ,CONVERT(money,F7)total--, [Unit Cost Incl] 
	
			
						LEFT OUTER JOIN [Finance].[Instrument] fi (NOLOCK)
						ON fi.[kInstrumentCodeID]=tmp.Instrument
						OR fi.[kAlternateCodeID]=tmp.Instrument
						OR fi.[k2ndAlternateID] LIKE  (SELECT tmp.Instrument + '%')
						OR tmp.Instrument LIKE  (SELECT [k2ndAlternateID]  + '%')
						LEFT OUTER JOIN [Finance].[InvestmentTransactions] fit
						ON fit.[DateOfTransaction] =CONVERT(datetime,tmp.date,102)
						AND fit.[fInstrumentID]= [kInstrumentCodeID]
						AND [fInvestmentTransactionTypeID] = 'Take Up'
						AND [Account Number] = tmp.F2
						WHERE fit.[fInstrumentID] IS NULL

												
--Capital repayment From shares INTO cash account (Shares exchanged for cash value)
					INSERT INTO [Finance].[InvestmentTransactions]

					SELECT tmp.Date,[kInstrumentCodeID] ,'Capital Repayment',tmp.F2 Account,'Forced return of shares',tmp.qty * -1,tmp.total,tmp.total/tmp.qty,'C.CSH',tmp.total/tmp.qty/*,F3,Instrument,COALESCE(PATINDEX('% %',SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3))),LEN(F3))*/ FROM
						(SELECT CONVERT(datetime,[1614486_Laceya Susanna Riekert_JSE],102) Date, CASE WHEN PATINDEX('%RESIDUAL DIV%',F3 )>0 THEN SUBSTRING(F3,PATINDEX('%RESIDUAL DIV%',F3)+13,LEN(F3)) ELSE LEFT(SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3)),
						CASE WHEN PATINDEX('% %',SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3))) > 0 THEN PATINDEX('% %',SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3))) ELSE LEN(F3) END) END Instrument,

						F2, SUM(CONVERT(int,LEFT(SUBSTRING(F3,PATINDEX('%[0-9]%',F3),LEN(F3)), PATINDEX('% %',SUBSTRING(F3,PATINDEX('%[0-9]%',F3),LEN(F3)))))) qty ,SUM(CONVERT(money,F7)) total FROM [Finance].[InvestmentTransactionsInterim](NOLOCK)
						WHERE  F5 IS NULL AND NOT F3  IS NULL
						AND PATINDEX('%CAP.REPAY%',F3 )>0 AND PATINDEX('%REV%',F3 )=0 AND PATINDEX('%PARTIAL%',F3 )=0 
						GROUP BY CONVERT(datetime,[1614486_Laceya Susanna Riekert_JSE],102),
						CASE WHEN PATINDEX('%RESIDUAL DIV%',F3 )>0 THEN SUBSTRING(F3,PATINDEX('%RESIDUAL DIV%',F3)+13,LEN(F3)) ELSE LEFT(SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3)),
						CASE WHEN PATINDEX('% %',SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3))) > 0 THEN PATINDEX('% %',SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3))) ELSE LEN(F3) END) END ,F2
						) tmp
			
						LEFT OUTER JOIN [Finance].[Instrument] fi (NOLOCK)
						ON fi.[kInstrumentCodeID]=tmp.Instrument
						OR fi.[kAlternateCodeID]=tmp.Instrument
						OR fi.[k2ndAlternateID] LIKE  (SELECT tmp.Instrument + '%')
						OR tmp.Instrument LIKE  (SELECT [k2ndAlternateID]  + '%')
						LEFT OUTER JOIN [Finance].[InvestmentTransactions] fit
						ON fit.[DateOfTransaction] =CONVERT(datetime,tmp.date,102)
						AND fit.[fInstrumentID]= [kInstrumentCodeID]
						AND [fInvestmentTransactionTypeID] = 'Capital Repayment'
						AND [Account Number] = tmp.F2
						WHERE fit.[fInstrumentID] IS NULL


--Reverse Capital repayment From shares INTO cash account (Shares exchanged for cash value)
					INSERT INTO [Finance].[InvestmentTransactions]

					SELECT tmp.Date,[kInstrumentCodeID] ,'Rev Cap Repayment',tmp.F2,'Reverse Forced return of shares',tmp.qty * -1,tmp.total,tmp.total/tmp.qty,'C.CSH',tmp.total/tmp.qty/*,F3,Instrument,COALESCE(PATINDEX('% %',SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3))),LEN(F3))*/ FROM
						(SELECT CONVERT(datetime,[1614486_Laceya Susanna Riekert_JSE],102) Date, CASE WHEN PATINDEX('%RESIDUAL DIV%',F3 )>0 THEN SUBSTRING(F3,PATINDEX('%RESIDUAL DIV%',F3)+13,LEN(F3)) ELSE LEFT(SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3)),
						CASE WHEN PATINDEX('% %',SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3))) > 0 THEN PATINDEX('% %',SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3))) ELSE LEN(F3) END) END Instrument,

						F2, SUM(CONVERT(int,LEFT(SUBSTRING(F3,PATINDEX('%[0-9]%',F3),LEN(F3)), PATINDEX('% %',SUBSTRING(F3,PATINDEX('%[0-9]%',F3),LEN(F3)))))) * -1 qty ,SUM(CONVERT(money,F7)) total FROM [Finance].[InvestmentTransactionsInterim](NOLOCK)
						WHERE  F5 IS NULL AND NOT F3  IS NULL
						AND PATINDEX('%CAP.REPAY%',F3 )>0 AND PATINDEX('%REV%',F3 )>0 AND PATINDEX('%PARTIAL%',F3 )=0 
						GROUP BY CONVERT(datetime,[1614486_Laceya Susanna Riekert_JSE],102),
						CASE WHEN PATINDEX('%RESIDUAL DIV%',F3 )>0 THEN SUBSTRING(F3,PATINDEX('%RESIDUAL DIV%',F3)+13,LEN(F3)) ELSE LEFT(SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3)),
						CASE WHEN PATINDEX('% %',SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3))) > 0 THEN PATINDEX('% %',SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3))) ELSE LEN(F3) END) END ,F2
						) tmp
			
						LEFT OUTER JOIN [Finance].[Instrument] fi (NOLOCK)
						ON fi.[kInstrumentCodeID]=tmp.Instrument
						OR fi.[kAlternateCodeID]=tmp.Instrument
						OR fi.[k2ndAlternateID] LIKE  (SELECT tmp.Instrument + '%')
						OR tmp.Instrument LIKE  (SELECT [k2ndAlternateID]  + '%')
						LEFT OUTER JOIN [Finance].[InvestmentTransactions] fit
						ON fit.[DateOfTransaction] =CONVERT(datetime,tmp.date,102)
						AND fit.[fInstrumentID]= [kInstrumentCodeID]
						AND [fInvestmentTransactionTypeID] = 'Capital Repayment'
						AND [Account Number] = tmp.F2
						WHERE fit.[fInstrumentID] IS NULL





--##########################################################
--All transactions affecting share totals
--##########################################################

-- Cash reinvestment (shares) indicated by value in F5
--When allocation is made, create 'cash REinvest ' transaction with ZERO quantity
--If a instrument transaction occurs with no price... update the 'Cash reinvestment' with actual quantity
					INSERT INTO [Finance].[InvestmentTransactions]
					SELECT tmp.Date,[kInstrumentCodeID] ,'Cash Reinvest',tmp.F2,'Reinvestment of Dividends for shares',0,tmp.total,tmp.total,'I.CSH',tmp.total FROM
						(SELECT CONVERT(datetime,[1614486_Laceya Susanna Riekert_JSE],102) Date, CASE WHEN PATINDEX('%RESIDUAL DIV%',F3 )>0 THEN SUBSTRING(F3,PATINDEX('%RESIDUAL DIV%',F3)+13,LEN(F3)) ELSE SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3)) END Instrument,
						--F2, SUM(CONVERT(money,LEFT(SUBSTRING(F3,PATINDEX('%-[0-9]%',F3)+1,LEN(F3)),PATINDEX('%[0-9] %',SUBSTRING(F3,PATINDEX('%-[0-9]%',F3)+1,LEN(F3)))+1))) qty ,SUM(CONVERT(money,F7))total  
						F2, SUM(CONVERT(money,F7)) qty ,SUM(CONVERT(money,F7))total 
						FROM [Finance].[InvestmentTransactionsInterim](NOLOCK)
						WHERE  F5 IS NULL AND NOT F3  IS NULL
						--AND LEFT(F3,4) = 'INT ' --Interest payment
						AND PATINDEX('%CASH.REINVEST%',F3 )>0 --AND PATINDEX('% TAX %',F3 )= 0 AND    PATINDEX('%REIT%',F3 ) = 0 AND  PATINDEX('%FOREIGN%',F3 ) = 0 AND PATINDEX('%REV.DIV%',F3 ) = 0 
						GROUP BY CONVERT(datetime,[1614486_Laceya Susanna Riekert_JSE],102),
						CASE WHEN PATINDEX('%RESIDUAL DIV%',F3 )>0 THEN SUBSTRING(F3,PATINDEX('%RESIDUAL DIV%',F3)+13,LEN(F3)) ELSE SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3)) END ,F2
						--,CONVERT(money,LEFT(SUBSTRING(F3,PATINDEX('%-[0-9]%',F3)+1,LEN(F3)),PATINDEX('%[0-9] %',SUBSTRING(F3,PATINDEX('%-[0-9]%',F3)+1,LEN(F3)))+1))
						) tmp	 -- Div Instrument ,F2, CONVERT(money,F7) qty ,CONVERT(money,F7)total--, [Unit Cost Incl] 
	
			
						LEFT OUTER JOIN [Finance].[Instrument] fi (NOLOCK)
						ON fi.[kInstrumentCodeID]=tmp.Instrument
						OR fi.[kAlternateCodeID]=tmp.Instrument
						OR fi.[k2ndAlternateID] LIKE  (SELECT tmp.Instrument + '%')
						OR tmp.Instrument LIKE  (SELECT [k2ndAlternateID]  + '%')
						LEFT OUTER JOIN [Finance].[InvestmentTransactions] fit
						ON fit.[DateOfTransaction] =CONVERT(datetime,tmp.date,102)
						AND fit.[fInstrumentID]= [kInstrumentCodeID]
						AND [fInvestmentTransactionTypeID] = 'Cash Reinvest'
						AND [Account Number] = f2
						WHERE fit.[fInstrumentID] IS NULL





--Capital investment into account by shareholder
					INSERT INTO [Finance].[InvestmentTransactions]
					SELECT tmp.Date,[kInstrumentCodeID] ,'Investment',tmp.F2,'Addition of Capital',tmp.qty,tmp.total,tmp.total,NULL,tmp.total FROM
						(SELECT CONVERT(datetime,[1614486_Laceya Susanna Riekert_JSE],102) Date,'C.CSH' Instrument ,F2, 0 qty ,CONVERT(money,F7)total--, [Unit Cost Incl] 
						FROM [Finance].[InvestmentTransactionsInterim] tmp(NOLOCK) Where  LEFT (F3,2) = 'CR' OR PATINDEX('%1614486%',F3 )>0 ) tmp	
			
					LEFT OUTER JOIN [Finance].[Instrument] fi (NOLOCK)
					ON fi.[kInstrumentCodeID]=tmp.Instrument
					OR fi.[kAlternateCodeID]=tmp.Instrument
					OR fi.[k2ndAlternateID] LIKE  (SELECT tmp.Instrument + '%')
					OR tmp.Instrument LIKE  (SELECT [k2ndAlternateID]  + '%')
					LEFT OUTER JOIN [Finance].[InvestmentTransactions] fit
					ON fit.[DateOfTransaction] =CONVERT(datetime,tmp.date,102)
					AND fit.[fInstrumentID]= [kInstrumentCodeID]
					AND [fInvestmentTransactionTypeID] = 'Investment'
					AND [Account Number] = f2
					WHERE fit.[fInstrumentID] IS NULL

--Capital withdrawal from account by shareholder
					INSERT INTO [Finance].[InvestmentTransactions]
				SELECT tmp.Date,[kInstrumentCodeID] ,'Withdrawal',tmp.F2,'Withdrawal of Capital',tmp.qty,tmp.total,1,NULL,NULL FROM
						(SELECT CONVERT(datetime,[1614486_Laceya Susanna Riekert_JSE],102) Date,'C.CSH' Instrument ,F2, 0 qty ,CONVERT(money,F7)total--, [Unit Cost Incl] 
						FROM [Finance].[InvestmentTransactionsInterim] tmp(NOLOCK) Where  PATINDEX('%10010072798%',F3 )>0) tmp	
			
					LEFT OUTER JOIN [Finance].[Instrument] fi (NOLOCK)
					ON fi.[kInstrumentCodeID]=tmp.Instrument
					OR fi.[kAlternateCodeID]=tmp.Instrument
						OR fi.[k2ndAlternateID] LIKE  (SELECT tmp.Instrument + '%')
						OR tmp.Instrument LIKE  (SELECT [k2ndAlternateID]  + '%')
					LEFT OUTER JOIN [Finance].[InvestmentTransactions] fit
					ON fit.[DateOfTransaction] =CONVERT(datetime,tmp.date,102)
					AND fit.[fInstrumentID]= [kInstrumentCodeID]
					AND [fInvestmentTransactionTypeID] = 'Withdrawal'
					AND [Account Number] = f2
					WHERE fit.[fInstrumentID] IS NULL
	
--Local Dividend payments into cash account
					INSERT INTO [Finance].[InvestmentTransactions]
					SELECT tmp.Date,[kInstrumentCodeID] ,'Dividend',tmp.F2,'Local Dividend',tmp.qty,tmp.total,1,'I.CSH',NULL FROM
						(SELECT CONVERT(datetime,[1614486_Laceya Susanna Riekert_JSE],102) Date, CASE WHEN PATINDEX('%RESIDUAL DIV%',F3 )>0 THEN SUBSTRING(F3,PATINDEX('%RESIDUAL DIV%',F3)+13,LEN(F3)) ELSE SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3)) END Instrument,
						F2, 0 qty ,SUM(CONVERT(money,F7))total 
						FROM [Finance].[InvestmentTransactionsInterim](NOLOCK)
						WHERE  F5 IS NULL AND NOT F3  IS NULL
						--AND LEFT(F3,4) = 'INT ' --Interest payment
						AND PATINDEX('%DIV%',F3 )>0 AND PATINDEX('% TAX %',F3 )= 0 AND    PATINDEX('%REIT%',F3 ) = 0 AND  PATINDEX('%FOREIGN%',F3 ) = 0 AND PATINDEX('%REV.DIV%',F3 ) = 0 
						GROUP BY CONVERT(datetime,[1614486_Laceya Susanna Riekert_JSE],102),
						CASE WHEN PATINDEX('%RESIDUAL DIV%',F3 )>0 THEN SUBSTRING(F3,PATINDEX('%RESIDUAL DIV%',F3)+13,LEN(F3)) ELSE SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3)) END ,F2
						) tmp	 -- Div Instrument ,F2, CONVERT(money,F7) qty ,CONVERT(money,F7)total--, [Unit Cost Incl] 
	
			
						LEFT OUTER JOIN [Finance].[Instrument] fi (NOLOCK)
						ON fi.[kInstrumentCodeID]=tmp.Instrument
						OR fi.[kAlternateCodeID]=tmp.Instrument
						OR fi.[k2ndAlternateID] LIKE  (SELECT tmp.Instrument + '%')
						OR tmp.Instrument LIKE  (SELECT [k2ndAlternateID]  + '%')
						LEFT OUTER JOIN [Finance].[InvestmentTransactions] fit
						ON fit.[DateOfTransaction] =CONVERT(datetime,tmp.date,102)
						AND fit.[fInstrumentID]= [kInstrumentCodeID]
						AND [fInvestmentTransactionTypeID] = 'Dividend'
						AND [Account Number] = f2
						WHERE fit.[fInstrumentID] IS NULL
					
				--		ORDER BY Date,Instrument

				--SELECT * FROM [Finance].[Instrument] fi (NOLOCK) where fi.[kAlternateCodeID]= 'SATRIXRES'

--Local Dividend payment reversals from cash account
					INSERT INTO [Finance].[InvestmentTransactions]
					SELECT tmp.Date,[kInstrumentCodeID] ,'Dividend Reversal',tmp.F2,'Reversal of local Dividend',tmp.qty,tmp.total,1,'I.CSH',NULL FROM
						(SELECT CONVERT(datetime,[1614486_Laceya Susanna Riekert_JSE],102) Date, CASE WHEN PATINDEX('%RESIDUAL DIV%',F3 )>0 THEN SUBSTRING(F3,PATINDEX('%RESIDUAL DIV%',F3)+13,LEN(F3)) ELSE SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3)) END Instrument,
						F2, 0 qty ,SUM(CONVERT(money,F7)) total FROM [Finance].[InvestmentTransactionsInterim](NOLOCK)
						WHERE  F5 IS NULL AND NOT F3  IS NULL
						--AND LEFT(F3,4) = 'INT ' --Interest payment
						AND PATINDEX('%DIV%',F3 )>0 AND PATINDEX('% TAX %',F3 )= 0 AND    PATINDEX('%REIT%',F3 ) = 0 AND  PATINDEX('%FOREIGN%',F3 ) = 0 AND PATINDEX('%REV.DIV%',F3 ) > 0
											GROUP BY CONVERT(datetime,[1614486_Laceya Susanna Riekert_JSE],102),
						CASE WHEN PATINDEX('%RESIDUAL DIV%',F3 )>0 THEN SUBSTRING(F3,PATINDEX('%RESIDUAL DIV%',F3)+13,LEN(F3)) ELSE SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3)) END ,F2
						) tmp	 -- Div Instrument ,F2, CONVERT(money,F7) qty ,CONVERT(money,F7)total--, [Unit Cost Incl] 	 -- Div Instrument ,F2, CONVERT(money,F7) qty ,CONVERT(money,F7)total--, [Unit Cost Incl] 
	
			
						LEFT OUTER JOIN [Finance].[Instrument] fi (NOLOCK)
						ON fi.[kInstrumentCodeID]=tmp.Instrument
						OR fi.[kAlternateCodeID]=tmp.Instrument
						OR fi.[k2ndAlternateID] LIKE  (SELECT tmp.Instrument + '%')
						OR tmp.Instrument LIKE  (SELECT [k2ndAlternateID]  + '%')
						LEFT OUTER JOIN [Finance].[InvestmentTransactions] fit
						ON fit.[DateOfTransaction] =CONVERT(datetime,tmp.date,102)
						AND fit.[fInstrumentID]= [kInstrumentCodeID]
						AND [fInvestmentTransactionTypeID] = 'Dividend Reversal'
						AND [Account Number] = f2
						WHERE fit.[fInstrumentID] IS NULL
--REIT payments into cash account
					INSERT INTO [Finance].[InvestmentTransactions]
					SELECT tmp.Date,[kInstrumentCodeID] ,'REIT',tmp.F2,'REIT Dividend',tmp.qty,tmp.total,1,'I.CSH',NULL FROM
						(SELECT CONVERT(datetime,[1614486_Laceya Susanna Riekert_JSE],102) Date, CASE WHEN PATINDEX('%RESIDUAL DIV%',F3 )>0 THEN SUBSTRING(F3,PATINDEX('%RESIDUAL DIV%',F3)+13,LEN(F3)) ELSE SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3)) END Instrument,F2, 0 qty ,SUM(CONVERT(money,F7)) total FROM [Finance].[InvestmentTransactionsInterim](NOLOCK)
						WHERE  F5 IS NULL AND NOT F3  IS NULL
						--AND LEFT(F3,4) = 'INT ' --Interest payment
						AND PATINDEX('%DIV%',F3 )>0 AND PATINDEX('% TAX %',F3 )= 0 AND    PATINDEX('%REIT%',F3 ) > 0 AND PATINDEX('%REV.%',F3 ) = 0
											GROUP BY CONVERT(datetime,[1614486_Laceya Susanna Riekert_JSE],102),
						CASE WHEN PATINDEX('%RESIDUAL DIV%',F3 )>0 THEN SUBSTRING(F3,PATINDEX('%RESIDUAL DIV%',F3)+13,LEN(F3)) ELSE SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3)) END ,F2
						) tmp	 -- Div Instrument ,F2, CONVERT(money,F7) qty ,CONVERT(money,F7)total--, [Unit Cost Incl] 	 -- Div Instrument ,F2, CONVERT(money,F7) qty ,CONVERT(money,F7)total--, [Unit Cost Incl] 
				
						LEFT OUTER JOIN [Finance].[Instrument] fi (NOLOCK)
						ON fi.[kInstrumentCodeID]=tmp.Instrument
						OR fi.[kAlternateCodeID]=tmp.Instrument
						OR fi.[k2ndAlternateID] LIKE  (SELECT tmp.Instrument + '%')
						OR tmp.Instrument LIKE  (SELECT [k2ndAlternateID]  + '%')
						LEFT OUTER JOIN [Finance].[InvestmentTransactions] fit
						ON fit.[DateOfTransaction] =CONVERT(datetime,tmp.date,102)
						AND fit.[fInstrumentID]= [kInstrumentCodeID]
						AND [fInvestmentTransactionTypeID] = 'REIT'
						AND [Account Number] = f2
						WHERE fit.[fInstrumentID] IS NULL

--REIT payment reversals from cash account
					INSERT INTO [Finance].[InvestmentTransactions]
					SELECT tmp.Date,[kInstrumentCodeID] ,'REIT REVERSAL',tmp.F2,'REIT Dividend Reversals',tmp.qty,tmp.total,1,'I.CSH',NULL FROM
						(SELECT CONVERT(datetime,[1614486_Laceya Susanna Riekert_JSE],102) Date, CASE WHEN PATINDEX('%RESIDUAL DIV%',F3 )>0 THEN SUBSTRING(F3,PATINDEX('%RESIDUAL DIV%',F3)+13,LEN(F3)) ELSE SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3)) END Instrument,F2, 0  qty ,SUM(CONVERT(money,F7)) total FROM [Finance].[InvestmentTransactionsInterim](NOLOCK)
						WHERE  F5 IS NULL AND NOT F3  IS NULL
						--AND LEFT(F3,4) = 'INT ' --Interest payment
						AND PATINDEX('%DIV%',F3 )>0 AND PATINDEX('% TAX %',F3 )= 0 AND    PATINDEX('%REIT%',F3 ) > 0 AND PATINDEX('%REV.%',F3 ) > 0
											GROUP BY CONVERT(datetime,[1614486_Laceya Susanna Riekert_JSE],102),
						CASE WHEN PATINDEX('%RESIDUAL DIV%',F3 )>0 THEN SUBSTRING(F3,PATINDEX('%RESIDUAL DIV%',F3)+13,LEN(F3)) ELSE SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3)) END ,F2
						) tmp	 -- Div Instrument ,F2, CONVERT(money,F7) qty ,CONVERT(money,F7)total--, [Unit Cost Incl] 	 -- Div Instrument ,F2, CONVERT(money,F7) qty ,CONVERT(money,F7)total--, [Unit Cost Incl] 
				
						LEFT OUTER JOIN [Finance].[Instrument] fi (NOLOCK)
						ON fi.[kInstrumentCodeID]=tmp.Instrument
						OR fi.[kAlternateCodeID]=tmp.Instrument
						OR fi.[k2ndAlternateID] LIKE  (SELECT tmp.Instrument + '%')
						OR tmp.Instrument LIKE  (SELECT [k2ndAlternateID]  + '%')
						LEFT OUTER JOIN [Finance].[InvestmentTransactions] fit
						ON fit.[DateOfTransaction] =CONVERT(datetime,tmp.date,102)
						AND fit.[fInstrumentID]= [kInstrumentCodeID]
						AND [fInvestmentTransactionTypeID] = 'REIT REVERSAL'
						AND [Account Number] = f2
						WHERE fit.[fInstrumentID] IS NULL

--Local Dividend tax from cash account
					INSERT INTO [Finance].[InvestmentTransactions]
					SELECT tmp.Date,[kInstrumentCodeID] ,'Dividend Tax',tmp.F2,'Local Dividend Tax',tmp.qty,tmp.total,1,'I.CSH',NULL FROM
						(SELECT CONVERT(datetime,[1614486_Laceya Susanna Riekert_JSE],102) Date, CASE WHEN PATINDEX('%RESIDUAL DIV%',F3 )>0 THEN SUBSTRING(F3,PATINDEX('%RESIDUAL DIV%',F3)+13,LEN(F3)) ELSE SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3)) END Instrument,
						F2, 0 qty ,SUM(CONVERT(money,F7)) total FROM [Finance].[InvestmentTransactionsInterim](NOLOCK)
						WHERE  F5 IS NULL AND NOT F3  IS NULL
						--AND LEFT(F3,4) = 'INT ' --Interest payment
						AND PATINDEX('%DIV%',F3 )>0 AND PATINDEX('% TAX %',F3 ) > 0 
											GROUP BY CONVERT(datetime,[1614486_Laceya Susanna Riekert_JSE],102),
						CASE WHEN PATINDEX('%RESIDUAL DIV%',F3 )>0 THEN SUBSTRING(F3,PATINDEX('%RESIDUAL DIV%',F3)+13,LEN(F3)) ELSE SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3)) END ,F2
						) tmp	 -- Div Instrument ,F2, CONVERT(money,F7) qty ,CONVERT(money,F7)total--, [Unit Cost Incl] 	 -- Div Instrument ,F2, CONVERT(money,F7) qty ,CONVERT(money,F7)total--, [Unit Cost Incl] 
	
			
						LEFT OUTER JOIN [Finance].[Instrument] fi (NOLOCK)
						ON fi.[kInstrumentCodeID]=tmp.Instrument
						OR fi.[kAlternateCodeID]=tmp.Instrument
						OR fi.[k2ndAlternateID] LIKE  (SELECT tmp.Instrument + '%')
						OR tmp.Instrument LIKE  (SELECT [k2ndAlternateID]  + '%')
						LEFT OUTER JOIN [Finance].[InvestmentTransactions] fit
						ON fit.[DateOfTransaction] =CONVERT(datetime,tmp.date,102)
						AND fit.[fInstrumentID]= [kInstrumentCodeID]
						AND [fInvestmentTransactionTypeID] = 'Dividend Tax'
						AND [Account Number] = f2
						WHERE fit.[fInstrumentID] IS NULL

--Local  tax on shares from cash account
					INSERT INTO [Finance].[InvestmentTransactions]
					SELECT tmp.Date,[kInstrumentCodeID] ,'Local Tax',tmp.F2,'Local Tax',tmp.qty,tmp.total,1,'I.CSH',NULL FROM
						(SELECT CONVERT(datetime,[1614486_Laceya Susanna Riekert_JSE],102) Date, CASE WHEN PATINDEX('%RESIDUAL DIV%',F3 )>0 THEN SUBSTRING(F3,PATINDEX('%RESIDUAL DIV%',F3)+13,LEN(F3)) ELSE SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3)) END Instrument,
						F2, 0 qty ,SUM(CONVERT(money,F7)) total  FROM [Finance].[InvestmentTransactionsInterim](NOLOCK)
						WHERE  F5 IS NULL AND NOT F3  IS NULL
						--AND LEFT(F3,4) = 'INT ' --Interest payment
						AND PATINDEX('%LOC%',F3 )>0 AND PATINDEX('% TAX %',F3 ) > 0 --AND PATINDEX('%REV.%',F3 ) = 0 
											GROUP BY CONVERT(datetime,[1614486_Laceya Susanna Riekert_JSE],102),
						CASE WHEN PATINDEX('%RESIDUAL DIV%',F3 )>0 THEN SUBSTRING(F3,PATINDEX('%RESIDUAL DIV%',F3)+13,LEN(F3)) ELSE SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3)) END ,F2
						) tmp	 -- Div Instrument ,F2, CONVERT(money,F7) qty ,CONVERT(money,F7)total--, [Unit Cost Incl] 	 -- Div Instrument ,F2, CONVERT(money,F7) qty ,CONVERT(money,F7)total--, [Unit Cost Incl] 
	
			
						LEFT OUTER JOIN [Finance].[Instrument] fi (NOLOCK)
						ON fi.[kInstrumentCodeID]=tmp.Instrument
						OR fi.[kAlternateCodeID]=tmp.Instrument
						OR fi.[k2ndAlternateID] LIKE  (SELECT tmp.Instrument + '%')
						OR tmp.Instrument LIKE  (SELECT [k2ndAlternateID]  + '%')
						LEFT OUTER JOIN [Finance].[InvestmentTransactions] fit
						ON fit.[DateOfTransaction] =CONVERT(datetime,tmp.date,102)
						AND fit.[fInstrumentID]= [kInstrumentCodeID]
						AND [fInvestmentTransactionTypeID] = 'Local Tax'
						AND [Account Number] = f2
						WHERE fit.[fInstrumentID] IS NULL


--ETF Fees on shares from cash account
					INSERT INTO [Finance].[InvestmentTransactions]
					SELECT tmp.Date,[kInstrumentCodeID] ,'ETF Fees',tmp.F2,'ETF Fees',tmp.qty,tmp.total,1,'I.CSH',NULL FROM
						(SELECT CONVERT(datetime,[1614486_Laceya Susanna Riekert_JSE],102) Date, CASE WHEN PATINDEX('%RESIDUAL DIV%',F3 )>0 THEN SUBSTRING(F3,PATINDEX('%RESIDUAL DIV%',F3)+13,LEN(F3)) ELSE SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3)) END Instrument,
						F2, 0 qty ,SUM(CONVERT(money,F7)) total  FROM [Finance].[InvestmentTransactionsInterim](NOLOCK)
						WHERE  F5 IS NULL AND NOT F3  IS NULL
						--AND LEFT(F3,4) = 'INT ' --Interest payment
						AND PATINDEX('%ETF FEE%',F3 )>0 --AND PATINDEX('% TAX %',F3 ) > 0 --AND PATINDEX('%REV.%',F3 ) = 0 
											GROUP BY CONVERT(datetime,[1614486_Laceya Susanna Riekert_JSE],102),
						CASE WHEN PATINDEX('%RESIDUAL DIV%',F3 )>0 THEN SUBSTRING(F3,PATINDEX('%RESIDUAL DIV%',F3)+13,LEN(F3)) ELSE SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3)) END ,F2
						) tmp	 -- Div Instrument ,F2, CONVERT(money,F7) qty ,CONVERT(money,F7)total--, [Unit Cost Incl] 	 -- Div Instrument ,F2, CONVERT(money,F7) qty ,CONVERT(money,F7)total--, [Unit Cost Incl] 
	
			
						LEFT OUTER JOIN [Finance].[Instrument] fi (NOLOCK)
						ON fi.[kInstrumentCodeID]=tmp.Instrument
						OR fi.[kAlternateCodeID]=tmp.Instrument
						OR fi.[k2ndAlternateID] LIKE  (SELECT tmp.Instrument + '%')
						OR tmp.Instrument LIKE  (SELECT [k2ndAlternateID]  + '%')
						LEFT OUTER JOIN [Finance].[InvestmentTransactions] fit
						ON fit.[DateOfTransaction] =CONVERT(datetime,tmp.date,102)
						AND fit.[fInstrumentID]= [kInstrumentCodeID]
						AND [fInvestmentTransactionTypeID] = 'ETF Fees'
						AND [Account Number] = f2
						WHERE fit.[fInstrumentID] IS NULL




--Foreign Dividend payments into cash account
					INSERT INTO [Finance].[InvestmentTransactions]
					SELECT tmp.Date,[kInstrumentCodeID] ,'Foreign Dividend',tmp.F2,'Foreign Dividend',tmp.qty,tmp.total,1,'I.CSH',NULL FROM
						(SELECT CONVERT(datetime,[1614486_Laceya Susanna Riekert_JSE],102) Date, CASE WHEN PATINDEX('%RESIDUAL DIV%',F3 )>0 THEN SUBSTRING(F3,PATINDEX('%RESIDUAL DIV%',F3)+13,LEN(F3)) ELSE SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3)) END Instrument,F2, 0 qty ,SUM(CONVERT(money,F7)) total FROM [Finance].[InvestmentTransactionsInterim](NOLOCK)
						WHERE  F5 IS NULL AND NOT F3  IS NULL
						--AND LEFT(F3,4) = 'INT ' --Interest payment
						AND PATINDEX('%DIV%',F3 )>0 AND PATINDEX('% TAX %',F3 )= 0 AND    PATINDEX('%REIT%',F3 ) = 0 AND  PATINDEX('%FOREIGN%',F3 ) > 0 AND PATINDEX('%REV %',F3 ) = 0
						GROUP BY CONVERT(datetime,[1614486_Laceya Susanna Riekert_JSE],102),
						CASE WHEN PATINDEX('%RESIDUAL DIV%',F3 )>0 THEN SUBSTRING(F3,PATINDEX('%RESIDUAL DIV%',F3)+13,LEN(F3)) ELSE SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3)) END ,F2
						) tmp	 -- Div Instrument ,F2, CONVERT(money,F7) qty ,CONVERT(money,F7)total--, [Unit Cost Incl] 	 -- Div Instrument ,F2, CONVERT(money,F7) qty ,CONVERT(money,F7)total--, [Unit Cost Incl] 
	
			
						LEFT OUTER JOIN [Finance].[Instrument] fi (NOLOCK)
						ON fi.[kInstrumentCodeID]=tmp.Instrument
						OR fi.[kAlternateCodeID]=tmp.Instrument
						OR fi.[k2ndAlternateID] LIKE  (SELECT tmp.Instrument + '%')
						OR tmp.Instrument LIKE  (SELECT [k2ndAlternateID]  + '%')
						LEFT OUTER JOIN [Finance].[InvestmentTransactions] fit
						ON fit.[DateOfTransaction] =CONVERT(datetime,tmp.date,102)
						AND fit.[fInstrumentID]= [kInstrumentCodeID]
						AND [fInvestmentTransactionTypeID] = 'Foreign Dividend'
						AND [Account Number] = f2
						WHERE fit.[fInstrumentID] IS NULL

--Foreign Dividend repayments from cash account
					INSERT INTO [Finance].[InvestmentTransactions]
					SELECT tmp.Date,[kInstrumentCodeID] ,'Rev Foreign Divd',tmp.F2,'reverse Foreign Dividend',tmp.qty,tmp.total,1,'I.CSH',NULL FROM
						(SELECT CONVERT(datetime,[1614486_Laceya Susanna Riekert_JSE],102) Date, CASE WHEN PATINDEX('%RESIDUAL DIV%',F3 )>0 THEN SUBSTRING(F3,PATINDEX('%RESIDUAL DIV%',F3)+13,LEN(F3)) ELSE SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3)) END Instrument,F2, 0 qty ,SUM(CONVERT(money,F7)) total FROM [Finance].[InvestmentTransactionsInterim](NOLOCK)
						WHERE  F5 IS NULL AND NOT F3  IS NULL
						--AND LEFT(F3,4) = 'INT ' --Interest payment
						AND PATINDEX('%DIV%',F3 )>0 AND PATINDEX('% TAX %',F3 )= 0 AND    PATINDEX('%REIT%',F3 ) = 0 AND  PATINDEX('%FOREIGN%',F3 ) > 0 AND PATINDEX('%REV %',F3 ) > 0
						GROUP BY CONVERT(datetime,[1614486_Laceya Susanna Riekert_JSE],102),
						CASE WHEN PATINDEX('%RESIDUAL DIV%',F3 )>0 THEN SUBSTRING(F3,PATINDEX('%RESIDUAL DIV%',F3)+13,LEN(F3)) ELSE SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3)) END ,F2
						) tmp	 -- Div Instrument ,F2, CONVERT(money,F7) qty ,CONVERT(money,F7)total--, [Unit Cost Incl] 	 -- Div Instrument ,F2, CONVERT(money,F7) qty ,CONVERT(money,F7)total--, [Unit Cost Incl] 
	
			
						LEFT OUTER JOIN [Finance].[Instrument] fi (NOLOCK)
						ON fi.[kInstrumentCodeID]=tmp.Instrument
						OR fi.[kAlternateCodeID]=tmp.Instrument
						OR fi.[k2ndAlternateID] LIKE  (SELECT tmp.Instrument + '%')
						OR tmp.Instrument LIKE  (SELECT [k2ndAlternateID]  + '%')
						LEFT OUTER JOIN [Finance].[InvestmentTransactions] fit
						ON fit.[DateOfTransaction] =CONVERT(datetime,tmp.date,102)
						AND fit.[fInstrumentID]= [kInstrumentCodeID]
						AND [fInvestmentTransactionTypeID] = 'Rev Foreign Divd'
						AND [Account Number] = f2
						WHERE fit.[fInstrumentID] IS NULL


--Foreign Dividend TAX from cash account
					INSERT INTO [Finance].[InvestmentTransactions]
					SELECT tmp.Date,[kInstrumentCodeID] ,'Foreign Dividend Tax',tmp.F2,'Foreign Dividend Tax',tmp.qty,tmp.total,1,'I.CSH',NULL FROM
						(SELECT CONVERT(datetime,[1614486_Laceya Susanna Riekert_JSE],102) Date, CASE WHEN PATINDEX('%RESIDUAL DIV%',F3 )>0 THEN SUBSTRING(F3,PATINDEX('%RESIDUAL DIV%',F3)+13,LEN(F3)) ELSE SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3)) END Instrument,F2, 0 qty ,SUM(CONVERT(money,F7)) total FROM [Finance].[InvestmentTransactionsInterim](NOLOCK)
						WHERE  F5 IS NULL AND NOT F3  IS NULL
						--AND LEFT(F3,4) = 'INT ' --Interest payment
						AND PATINDEX('%DIV%',F3 )=0 AND PATINDEX('%TAX%',F3 )> 0 AND    PATINDEX('%REIT%',F3 ) = 0 AND  PATINDEX('%FOREIGN%',F3 ) > 0 AND PATINDEX('%REV%',F3 ) = 0
											GROUP BY CONVERT(datetime,[1614486_Laceya Susanna Riekert_JSE],102),
						CASE WHEN PATINDEX('%RESIDUAL DIV%',F3 )>0 THEN SUBSTRING(F3,PATINDEX('%RESIDUAL DIV%',F3)+13,LEN(F3)) ELSE SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3)) END ,F2
						) tmp	 -- Div Instrument ,F2, CONVERT(money,F7) qty ,CONVERT(money,F7)total--, [Unit Cost Incl] 	 -- Div Instrument ,F2, CONVERT(money,F7) qty ,CONVERT(money,F7)total--, [Unit Cost Incl] 
	
			
						LEFT OUTER JOIN [Finance].[Instrument] fi (NOLOCK)
						ON fi.[kInstrumentCodeID]=tmp.Instrument
						OR fi.[kAlternateCodeID]=tmp.Instrument
						OR fi.[k2ndAlternateID] LIKE  (SELECT tmp.Instrument + '%')
						OR tmp.Instrument LIKE  (SELECT [k2ndAlternateID]  + '%')
						LEFT OUTER JOIN [Finance].[InvestmentTransactions] fit
						ON fit.[DateOfTransaction] =CONVERT(datetime,tmp.date,102)
						AND fit.[fInstrumentID]= [kInstrumentCodeID]
						AND [fInvestmentTransactionTypeID] = 'Foreign Dividend Tax'
						AND [Account Number] = f2
						WHERE fit.[fInstrumentID] IS NULL

--Foreign Dividend TAX reversals from cash account
					INSERT INTO [Finance].[InvestmentTransactions]
					SELECT tmp.Date,[kInstrumentCodeID] ,'Foreign Div Tax Rev',tmp.F2,'Foreign Dividend Tax Reversal',tmp.qty,tmp.total,1,'I.CSH',NULL FROM
						(SELECT CONVERT(datetime,[1614486_Laceya Susanna Riekert_JSE],102) Date, CASE WHEN PATINDEX('%RESIDUAL DIV%',F3 )>0 THEN SUBSTRING(F3,PATINDEX('%RESIDUAL DIV%',F3)+13,LEN(F3)) ELSE SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3)) END Instrument,F2, 0 qty ,SUM(CONVERT(money,F7)) total FROM [Finance].[InvestmentTransactionsInterim](NOLOCK)
						WHERE  F5 IS NULL AND NOT F3  IS NULL
						--AND LEFT(F3,4) = 'INT ' --Interest payment
						AND PATINDEX('%DIV%',F3 )=0 AND PATINDEX('% TAX %',F3 )> 0 AND    PATINDEX('%REIT%',F3 ) = 0 AND  PATINDEX('%FOREIGN%',F3 ) > 0 AND PATINDEX('%REV%',F3 ) > 0
											GROUP BY CONVERT(datetime,[1614486_Laceya Susanna Riekert_JSE],102),
						CASE WHEN PATINDEX('%RESIDUAL DIV%',F3 )>0 THEN SUBSTRING(F3,PATINDEX('%RESIDUAL DIV%',F3)+13,LEN(F3)) ELSE SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3)) END ,F2
						) tmp	 -- Div Instrument ,F2, CONVERT(money,F7) qty ,CONVERT(money,F7)total--, [Unit Cost Incl] 	 -- Div Instrument ,F2, CONVERT(money,F7) qty ,CONVERT(money,F7)total--, [Unit Cost Incl] 
	
			
						LEFT OUTER JOIN [Finance].[Instrument] fi (NOLOCK)
						ON fi.[kInstrumentCodeID]=tmp.Instrument
						OR fi.[kAlternateCodeID]=tmp.Instrument
						OR fi.[k2ndAlternateID] LIKE  (SELECT tmp.Instrument + '%')
						OR tmp.Instrument LIKE  (SELECT [k2ndAlternateID]  + '%')
						LEFT OUTER JOIN [Finance].[InvestmentTransactions] fit
						ON fit.[DateOfTransaction] =CONVERT(datetime,tmp.date,102)
						AND fit.[fInstrumentID]= [kInstrumentCodeID]
						AND [fInvestmentTransactionTypeID] = 'Foreign Div Tax Rev'
						AND [Account Number] = f2
						WHERE fit.[fInstrumentID] IS NULL

--Local Interest payments  From shares into cash account
					INSERT INTO [Finance].[InvestmentTransactions]
					SELECT tmp.Date,[kInstrumentCodeID] ,'Interest',tmp.F2,'Interest from instrument',tmp.qty,tmp.total,1,'I.CSH',NULL FROM
						(SELECT CONVERT(datetime,[1614486_Laceya Susanna Riekert_JSE],102) Date, CASE WHEN PATINDEX('%RESIDUAL DIV%',F3 )>0 THEN SUBSTRING(F3,PATINDEX('%RESIDUAL DIV%',F3)+13,LEN(F3)) ELSE SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3)) END Instrument,F2, 0 qty ,SUM(CONVERT(money,F7)) total FROM [Finance].[InvestmentTransactionsInterim](NOLOCK)
						WHERE  F5 IS NULL AND NOT F3  IS NULL
						--AND LEFT(F3,4) = 'INT ' --Interest payment
						AND PATINDEX('%DIV%',F3 )=0 AND PATINDEX('% TAX %',F3 )= 0 AND PATINDEX('%INT%',F3 )>0  AND  PATINDEX('%REIT%',F3 ) = 0 AND  PATINDEX('%FOREIGN%',F3 ) = 0 
						AND PATINDEX('%GROSS INTEREST%',F3 )=0 AND PATINDEX('%INTEREST ADJUSTMENT%',F3 )=0 
						AND PATINDEX('%REV.%',F3 ) = 0
											GROUP BY CONVERT(datetime,[1614486_Laceya Susanna Riekert_JSE],102),
						CASE WHEN PATINDEX('%RESIDUAL DIV%',F3 )>0 THEN SUBSTRING(F3,PATINDEX('%RESIDUAL DIV%',F3)+13,LEN(F3)) ELSE SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3)) END ,F2
						) tmp	 -- Div Instrument ,F2, CONVERT(money,F7) qty ,CONVERT(money,F7)total--, [Unit Cost Incl] 	 -- Div Instrument ,F2, CONVERT(money,F7) qty ,CONVERT(money,F7)total--, [Unit Cost Incl] 
	
			
						LEFT OUTER JOIN [Finance].[Instrument] fi (NOLOCK)
						ON fi.[kInstrumentCodeID]=tmp.Instrument
						OR fi.[kAlternateCodeID]=tmp.Instrument
						OR fi.[k2ndAlternateID] LIKE  (SELECT tmp.Instrument + '%')
						OR tmp.Instrument LIKE  (SELECT [k2ndAlternateID]  + '%')
						LEFT OUTER JOIN [Finance].[InvestmentTransactions] fit
						ON fit.[DateOfTransaction] =CONVERT(datetime,tmp.date,102)
						AND fit.[fInstrumentID]= [kInstrumentCodeID]
						AND [fInvestmentTransactionTypeID] = 'Interest'
						AND [Account Number] = f2
						WHERE fit.[fInstrumentID] IS NULL

--Local Interest payments reversals From shares from cash account
					INSERT INTO [Finance].[InvestmentTransactions]
					SELECT tmp.Date,[kInstrumentCodeID] ,'Interest Reversal',tmp.F2,'Interest reversal from instrument',tmp.qty,tmp.total,1,'I.CSH',NULL FROM
						(SELECT CONVERT(datetime,[1614486_Laceya Susanna Riekert_JSE],102) Date, CASE WHEN PATINDEX('%RESIDUAL DIV%',F3 )>0 THEN SUBSTRING(F3,PATINDEX('%RESIDUAL DIV%',F3)+13,LEN(F3)) ELSE SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3)) END Instrument,
						F2, 0 qty ,SUM(CONVERT(money,F7)) total FROM [Finance].[InvestmentTransactionsInterim](NOLOCK)
						WHERE  F5 IS NULL AND NOT F3  IS NULL
						--AND LEFT(F3,4) = 'INT ' --Interest payment
						AND PATINDEX('%DIV%',F3 )=0 AND PATINDEX('% TAX %',F3 )= 0 AND PATINDEX('%INT%',F3 )>0  AND  PATINDEX('%REIT%',F3 ) = 0 AND  PATINDEX('%FOREIGN%',F3 ) = 0 
						AND PATINDEX('%GROSS INTEREST%',F3 )=0 AND PATINDEX('%INTEREST ADJUSTMENT%',F3 )=0 
						AND PATINDEX('%REV.%',F3 ) > 0	 -- Div Instrument ,F2, CONVERT(money,F7) qty ,CONVERT(money,F7)total--, [Unit Cost Incl] 
						GROUP BY CONVERT(datetime,[1614486_Laceya Susanna Riekert_JSE],102),
						CASE WHEN PATINDEX('%RESIDUAL DIV%',F3 )>0 THEN SUBSTRING(F3,PATINDEX('%RESIDUAL DIV%',F3)+13,LEN(F3)) ELSE SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3)) END ,F2
						) tmp
	
			
						LEFT OUTER JOIN [Finance].[Instrument] fi (NOLOCK)
						ON fi.[kInstrumentCodeID]=tmp.Instrument
						OR fi.[kAlternateCodeID]=tmp.Instrument
						OR fi.[k2ndAlternateID] LIKE  (SELECT tmp.Instrument + '%')
						OR tmp.Instrument LIKE  (SELECT [k2ndAlternateID]  + '%')
						LEFT OUTER JOIN [Finance].[InvestmentTransactions] fit
						ON fit.[DateOfTransaction] =CONVERT(datetime,tmp.date,102)
						AND fit.[fInstrumentID]= [kInstrumentCodeID]
						AND [fInvestmentTransactionTypeID] = 'Interest Reversal'
						AND [Account Number] = f2
						WHERE fit.[fInstrumentID] IS NULL

						
--Other Income From shares INTO cash account
					INSERT INTO [Finance].[InvestmentTransactions]
					SELECT tmp.Date,[kInstrumentCodeID] ,'Other Income',tmp.F2,'Other Income from instrument',tmp.qty,tmp.total,1,'I.CSH',NULL FROM
						(SELECT CONVERT(datetime,[1614486_Laceya Susanna Riekert_JSE],102) Date, CASE WHEN PATINDEX('%RESIDUAL DIV%',F3 )>0 THEN SUBSTRING(F3,PATINDEX('%RESIDUAL DIV%',F3)+13,LEN(F3)) ELSE SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3)) END Instrument,
						F2, 0 qty ,SUM(CONVERT(money,F7)) total FROM [Finance].[InvestmentTransactionsInterim](NOLOCK)
						WHERE  F5 IS NULL AND NOT F3  IS NULL
						--AND LEFT(F3,4) = 'INT ' --Interest payment
						AND PATINDEX('%OTHER INCOME%',F3 )>0 AND PATINDEX('% TAX %',F3 )= 0 AND PATINDEX('%INT%',F3 )=0  AND  PATINDEX('%REIT%',F3 ) = 0 AND  PATINDEX('%FOREIGN%',F3 ) = 0 
						AND PATINDEX('%GROSS INTEREST%',F3 )=0 AND PATINDEX('%INTEREST ADJUSTMENT%',F3 )=0 
						AND PATINDEX('%REV.%',F3 ) = 0	 -- Div Instrument ,F2, CONVERT(money,F7) qty ,CONVERT(money,F7)total--, [Unit Cost Incl] 
						GROUP BY CONVERT(datetime,[1614486_Laceya Susanna Riekert_JSE],102),
						CASE WHEN PATINDEX('%RESIDUAL DIV%',F3 )>0 THEN SUBSTRING(F3,PATINDEX('%RESIDUAL DIV%',F3)+13,LEN(F3)) ELSE SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3)) END ,F2
						) tmp
	
			
						LEFT OUTER JOIN [Finance].[Instrument] fi (NOLOCK)
						ON fi.[kInstrumentCodeID]=tmp.Instrument
						OR fi.[kAlternateCodeID]=tmp.Instrument
						OR fi.[k2ndAlternateID] LIKE  (SELECT tmp.Instrument + '%')
						OR tmp.Instrument LIKE  (SELECT [k2ndAlternateID]  + '%')
						LEFT OUTER JOIN [Finance].[InvestmentTransactions] fit
						ON fit.[DateOfTransaction] =CONVERT(datetime,tmp.date,102)
						AND fit.[fInstrumentID]= [kInstrumentCodeID]
						AND [fInvestmentTransactionTypeID] = 'Other Income'
						AND [Account Number] = f2
						WHERE fit.[fInstrumentID] IS NULL


						
--Other expenses For shares FROM cash account
					INSERT INTO [Finance].[InvestmentTransactions]
					SELECT tmp.Date,[kInstrumentCodeID] ,'Other Expenses',tmp.F2,'Other Expenses for instrument',tmp.qty,tmp.total,1,'I.CSH',NULL FROM
						(SELECT CONVERT(datetime,[1614486_Laceya Susanna Riekert_JSE],102) Date, CASE WHEN PATINDEX('%RESIDUAL DIV%',F3 )>0 THEN SUBSTRING(F3,PATINDEX('%RESIDUAL DIV%',F3)+13,LEN(F3)) ELSE SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3)) END Instrument,
						F2, 0 qty ,SUM(CONVERT(money,F7)) total FROM [Finance].[InvestmentTransactionsInterim](NOLOCK)
						WHERE  F5 IS NULL AND NOT F3  IS NULL
						--AND LEFT(F3,4) = 'INT ' --Interest payment
						AND PATINDEX('%OTHER EXPENSE%',F3 )>0 AND PATINDEX('% TAX %',F3 )= 0 AND PATINDEX('%INT%',F3 )=0  AND  PATINDEX('%REIT%',F3 ) = 0 AND  PATINDEX('%FOREIGN%',F3 ) = 0 
						AND PATINDEX('%GROSS INTEREST%',F3 )=0 AND PATINDEX('%INTEREST ADJUSTMENT%',F3 )=0 
						AND PATINDEX('%REV.%',F3 ) = 0	 -- Div Instrument ,F2, CONVERT(money,F7) qty ,CONVERT(money,F7)total--, [Unit Cost Incl] 
						GROUP BY CONVERT(datetime,[1614486_Laceya Susanna Riekert_JSE],102),
						CASE WHEN PATINDEX('%RESIDUAL DIV%',F3 )>0 THEN SUBSTRING(F3,PATINDEX('%RESIDUAL DIV%',F3)+13,LEN(F3)) ELSE SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3)) END ,F2
						) tmp
	
			
						LEFT OUTER JOIN [Finance].[Instrument] fi (NOLOCK)
						ON fi.[kInstrumentCodeID]=tmp.Instrument
						OR fi.[kAlternateCodeID]=tmp.Instrument
						OR fi.[k2ndAlternateID] LIKE  (SELECT tmp.Instrument + '%')
						OR tmp.Instrument LIKE  (SELECT [k2ndAlternateID]  + '%')
						LEFT OUTER JOIN [Finance].[InvestmentTransactions] fit
						ON fit.[DateOfTransaction] =CONVERT(datetime,tmp.date,102)
						AND fit.[fInstrumentID]= [kInstrumentCodeID]
						AND [fInvestmentTransactionTypeID] = 'Other Expenses'
						AND [Account Number] = f2
						WHERE fit.[fInstrumentID] IS NULL



----Capital repayment (shares retained) From shares INTO cash account (Shares exchanged for cash value)
--					INSERT INTO [Finance].[InvestmentTransactions]

--					SELECT tmp.Date,[kInstrumentCodeID] ,'Part Cap Repayment',tmp.F2,'Reduction in share capital - shares retained',tmp.qty * -1,tmp.total,1,'C.CSH'/*,F3,Instrument,COALESCE(PATINDEX('% %',SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3))),LEN(F3))*/ FROM
--						(SELECT CONVERT(datetime,[1614486_Laceya Susanna Riekert_JSE],102) Date, CASE WHEN PATINDEX('%RESIDUAL DIV%',F3 )>0 THEN SUBSTRING(F3,PATINDEX('%RESIDUAL DIV%',F3)+13,LEN(F3)) ELSE LEFT(SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3)),
--						CASE WHEN PATINDEX('% %',SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3))) > 0 THEN PATINDEX('% %',SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3))) ELSE LEN(F3) END) END Instrument,

--						F2, 0 qty ,SUM(CONVERT(money,F7)) total FROM [Finance].[InvestmentTransactionsInterim](NOLOCK)
--						WHERE  F5 IS NULL AND NOT F3  IS NULL
--						AND PATINDEX('%CAP.REPAY%',F3 )>0 AND PATINDEX('%REV%',F3 )=0 AND PATINDEX('%PARTIAL%',F3 )>0 
--						GROUP BY CONVERT(datetime,[1614486_Laceya Susanna Riekert_JSE],102),
--						CASE WHEN PATINDEX('%RESIDUAL DIV%',F3 )>0 THEN SUBSTRING(F3,PATINDEX('%RESIDUAL DIV%',F3)+13,LEN(F3)) ELSE LEFT(SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3)),
--						CASE WHEN PATINDEX('% %',SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3))) > 0 THEN PATINDEX('% %',SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3))) ELSE LEN(F3) END) END ,F2
--						) tmp
			
--						LEFT OUTER JOIN [Finance].[Instrument] fi (NOLOCK)
--						ON fi.[kInstrumentCodeID]=tmp.Instrument
--						OR fi.[kAlternateCodeID]=tmp.Instrument
--						OR fi.[k2ndAlternateID] LIKE  (SELECT tmp.Instrument + '%')
--						OR tmp.Instrument LIKE  (SELECT [k2ndAlternateID]  + '%')
--						LEFT OUTER JOIN [Finance].[InvestmentTransactions] fit
--						ON fit.[DateOfTransaction] =CONVERT(datetime,tmp.date,102)
--						AND fit.[fInstrumentID]= [kInstrumentCodeID]
--						AND [fInvestmentTransactionTypeID] = 'Part Cap Repayment'
--						AND [Account Number] = f2
--						WHERE fit.[fInstrumentID] IS NULL

----Reverse Capital repayment From shares INTO cash account (Shares exchanged for cash value)
--					INSERT INTO [Finance].[InvestmentTransactions]

--					SELECT tmp.Date,[kInstrumentCodeID] ,'Rev Cap Repayment',tmp.F2,'Forced return of shares',tmp.qty * -1,tmp.total,1,'C.CSH'/*,F3,Instrument,COALESCE(PATINDEX('% %',SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3))),LEN(F3))*/ FROM
--						(SELECT CONVERT(datetime,[1614486_Laceya Susanna Riekert_JSE],102) Date, CASE WHEN PATINDEX('%RESIDUAL DIV%',F3 )>0 THEN SUBSTRING(F3,PATINDEX('%RESIDUAL DIV%',F3)+13,LEN(F3)) ELSE LEFT(SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3)),
--						CASE WHEN PATINDEX('% %',SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3))) > 0 THEN PATINDEX('% %',SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3))) ELSE LEN(F3) END) END Instrument,

--						F2, SUM(CONVERT(int,LEFT(SUBSTRING(F3,PATINDEX('%[0-9]%',F3),LEN(F3)), PATINDEX('% %',SUBSTRING(F3,PATINDEX('%[0-9]%',F3),LEN(F3))))))* -1 qty ,SUM(CONVERT(money,F7)) total FROM [Finance].[InvestmentTransactionsInterim](NOLOCK)
--						WHERE  F5 IS NULL AND NOT F3  IS NULL
--						AND PATINDEX('%CAP.REPAY%',F3 )>0 AND PATINDEX('%REV%',F3 )>0  AND PATINDEX('%PARTIAL%',F3 )=0 
--						GROUP BY CONVERT(datetime,[1614486_Laceya Susanna Riekert_JSE],102),
--						CASE WHEN PATINDEX('%RESIDUAL DIV%',F3 )>0 THEN SUBSTRING(F3,PATINDEX('%RESIDUAL DIV%',F3)+13,LEN(F3)) ELSE LEFT(SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3)),
--						CASE WHEN PATINDEX('% %',SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3))) > 0 THEN PATINDEX('% %',SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3))) ELSE LEN(F3) END) END ,F2
--						) tmp
			
--						LEFT OUTER JOIN [Finance].[Instrument] fi (NOLOCK)
--						ON fi.[kInstrumentCodeID]=tmp.Instrument
--						OR fi.[kAlternateCodeID]=tmp.Instrument
--						OR fi.[k2ndAlternateID] LIKE  (SELECT tmp.Instrument + '%')
--						OR tmp.Instrument LIKE  (SELECT [k2ndAlternateID]  + '%')
--						LEFT OUTER JOIN [Finance].[InvestmentTransactions] fit
--						ON fit.[DateOfTransaction] =CONVERT(datetime,tmp.date,102)
--						AND fit.[fInstrumentID]= [kInstrumentCodeID]
--						AND [fInvestmentTransactionTypeID] = 'Rev Cap Repayment'
--						AND [Account Number] = f2
--						WHERE fit.[fInstrumentID] IS NULL


--Capital repayment From shares INTO cash account
					INSERT INTO [Finance].[InvestmentTransactions]
					SELECT tmp.Date,[kInstrumentCodeID] ,'Capital Reduction',tmp.F2,'Capital repayment from shares',tmp.qty,tmp.total,1,'C.CSH',NULL/*,F3,Instrument,COALESCE(PATINDEX('% %',SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3))),LEN(F3))*/ FROM
						(SELECT CONVERT(datetime,[1614486_Laceya Susanna Riekert_JSE],102) Date, CASE WHEN PATINDEX('%RESIDUAL DIV%',F3 )>0 THEN SUBSTRING(F3,PATINDEX('%RESIDUAL DIV%',F3)+13,LEN(F3)) ELSE LEFT(SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3)),
						CASE WHEN PATINDEX('% %',SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3))) > 0 THEN PATINDEX('% %',SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3))) ELSE LEN(F3) END) END Instrument,
						--COALESCE(PATINDEX('% %',SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3))),LEN(F3))

						F2, 0 qty ,SUM(CONVERT(money,F7)) total FROM [Finance].[InvestmentTransactionsInterim](NOLOCK)
						WHERE  F5 IS NULL AND NOT F3  IS NULL
						--AND LEFT(F3,4) = 'INT ' --Interest payment
						AND PATINDEX('%CAP.REDUC%',F3 )>0 
						GROUP BY CONVERT(datetime,[1614486_Laceya Susanna Riekert_JSE],102),
						CASE WHEN PATINDEX('%RESIDUAL DIV%',F3 )>0 THEN SUBSTRING(F3,PATINDEX('%RESIDUAL DIV%',F3)+13,LEN(F3)) ELSE LEFT(SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3)),
						CASE WHEN PATINDEX('% %',SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3))) > 0 THEN PATINDEX('% %',SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3))) ELSE LEN(F3) END) END ,F2
						) tmp
	
			
						LEFT OUTER JOIN [Finance].[Instrument] fi (NOLOCK)
						ON fi.[kInstrumentCodeID]=tmp.Instrument
						OR fi.[kAlternateCodeID]=tmp.Instrument
						OR fi.[k2ndAlternateID] LIKE  (SELECT tmp.Instrument + '%')
						OR tmp.Instrument LIKE  (SELECT [k2ndAlternateID]  + '%')
						LEFT OUTER JOIN [Finance].[InvestmentTransactions] fit
						ON fit.[DateOfTransaction] =CONVERT(datetime,tmp.date,102)
						AND fit.[fInstrumentID]= [kInstrumentCodeID]
						AND [fInvestmentTransactionTypeID] = 'Capital Reduction'
						AND [Account Number] = f2
						WHERE fit.[fInstrumentID] IS NULL

--Reverse Capital repayment From shares INTO cash account
					INSERT INTO [Finance].[InvestmentTransactions]
					SELECT tmp.Date,[kInstrumentCodeID] ,'Rev Cap Reduction',tmp.F2,'Reversal of Capital reduction from shares',tmp.qty,tmp.total,1,'C.CSH',NULL/*,F3,Instrument,COALESCE(PATINDEX('% %',SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3))),LEN(F3))*/ FROM
						(SELECT CONVERT(datetime,[1614486_Laceya Susanna Riekert_JSE],102) Date, CASE WHEN PATINDEX('%RESIDUAL DIV%',F3 )>0 THEN SUBSTRING(F3,PATINDEX('%RESIDUAL DIV%',F3)+13,LEN(F3)) ELSE LEFT(SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3)),
						CASE WHEN PATINDEX('% %',SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3))) > 0 THEN PATINDEX('% %',SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3))) ELSE LEN(F3) END) END Instrument,
						--COALESCE(PATINDEX('% %',SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3))),LEN(F3))

						F2, 0 qty ,SUM(CONVERT(money,F7)) total FROM [Finance].[InvestmentTransactionsInterim](NOLOCK)
						WHERE  F5 IS NULL AND NOT F3  IS NULL
						--AND LEFT(F3,4) = 'INT ' --Interest payment
						AND PATINDEX('%CAP.REDUC%',F3 )>0 AND PATINDEX('%REV%',F3 )>0 
						GROUP BY CONVERT(datetime,[1614486_Laceya Susanna Riekert_JSE],102),
						CASE WHEN PATINDEX('%RESIDUAL DIV%',F3 )>0 THEN SUBSTRING(F3,PATINDEX('%RESIDUAL DIV%',F3)+13,LEN(F3)) ELSE LEFT(SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3)),
						CASE WHEN PATINDEX('% %',SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3))) > 0 THEN PATINDEX('% %',SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3))) ELSE LEN(F3) END) END ,F2
						) tmp
	
			
						LEFT OUTER JOIN [Finance].[Instrument] fi (NOLOCK)
						ON fi.[kInstrumentCodeID]=tmp.Instrument
						OR fi.[kAlternateCodeID]=tmp.Instrument
						OR fi.[k2ndAlternateID] LIKE  (SELECT tmp.Instrument + '%')
						OR tmp.Instrument LIKE  (SELECT [k2ndAlternateID]  + '%')
						LEFT OUTER JOIN [Finance].[InvestmentTransactions] fit
						ON fit.[DateOfTransaction] =CONVERT(datetime,tmp.date,102)
						AND fit.[fInstrumentID]= [kInstrumentCodeID]
						AND [fInvestmentTransactionTypeID] = 'Capital Reduction'
						AND [Account Number] = f2
						WHERE fit.[fInstrumentID] IS NULL

--Interest earned from cash account balance
					INSERT INTO [Finance].[InvestmentTransactions]
					SELECT tmp.Date,[kInstrumentCodeID] ,'Cash Balance Int',tmp.F2,'Interest earned on positive cash balance',tmp.qty,tmp.total,1,'I.CSH',NULL FROM
						(SELECT CONVERT(datetime,[1614486_Laceya Susanna Riekert_JSE],102) Date, 'I.CSH'  Instrument,F2, SUM(CONVERT(money,F7)) qty ,SUM(CONVERT(money,F7)) total FROM [Finance].[InvestmentTransactionsInterim](NOLOCK)
						WHERE  F5 IS NULL AND NOT F3  IS NULL
						--AND LEFT(F3,4) = 'INT ' --Interest payment
						
						AND PATINDEX('%GROSS INTEREST%',F3 )>0 AND PATINDEX('%INTEREST ADJUSTMENT%',F3 )=0 
											GROUP BY CONVERT(datetime,[1614486_Laceya Susanna Riekert_JSE],102),
						CASE WHEN PATINDEX('%RESIDUAL DIV%',F3 )>0 THEN SUBSTRING(F3,PATINDEX('%RESIDUAL DIV%',F3)+13,LEN(F3)) ELSE SUBSTRING(F3,PATINDEX('%[0-9] %',F3)+2,LEN(F3)) END ,F2
						) tmp	 -- Div Instrument ,F2, CONVERT(money,F7) qty ,CONVERT(money,F7)total--, [Unit Cost Incl] 	 -- Div Instrument ,F2, CONVERT(money,F7) qty ,CONVERT(money,F7)total--, [Unit Cost Incl] 
	
			
						LEFT OUTER JOIN [Finance].[Instrument] fi (NOLOCK)
						ON fi.[kInstrumentCodeID]=tmp.Instrument
						OR fi.[kAlternateCodeID]=tmp.Instrument
						OR fi.[k2ndAlternateID] LIKE  (SELECT tmp.Instrument + '%')
						OR tmp.Instrument LIKE  (SELECT [k2ndAlternateID]  + '%')
						LEFT OUTER JOIN [Finance].[InvestmentTransactions] fit
						ON fit.[DateOfTransaction] =CONVERT(datetime,tmp.date,102)
						AND fit.[fInstrumentID]= [kInstrumentCodeID]
						AND [fInvestmentTransactionTypeID] = 'Cash Balance Int'
						AND [Account Number] = f2
						WHERE fit.[fInstrumentID] IS NULL

--Brokerage fee
					INSERT INTO [Finance].[InvestmentTransactions]
					SELECT tmp.Date,[kInstrumentCodeID] ,'Broker Fee' Instrument,tmp.F2,'BROKER TRUSTEES FEE',tmp.qty,tmp.total,1,'C.CSH',NULL FROM
						(SELECT CONVERT(datetime,[1614486_Laceya Susanna Riekert_JSE],102) Date, 'C.CSH' Instrument,F2, SUM(CONVERT(money,F7)) qty ,SUM(CONVERT(money,F7)) total FROM [Finance].[InvestmentTransactionsInterim](NOLOCK)
						WHERE  F5 IS NULL AND NOT F3  IS NULL
						--AND LEFT(F3,4) = 'INT ' --Interest payment
						
						AND PATINDEX('%BROKER TRUSTEES FEE%',F3 )>0 
											GROUP BY CONVERT(datetime,[1614486_Laceya Susanna Riekert_JSE],102),F2
						) tmp	 -- Div Instrument ,F2, CONVERT(money,F7) qty ,CONVERT(money,F7)total--, [Unit Cost Incl] 	 -- Div Instrument ,F2, CONVERT(money,F7) qty ,CONVERT(money,F7)total--, [Unit Cost Incl] 
	
							LEFT OUTER JOIN [Finance].[Instrument] fi (NOLOCK)
						ON fi.[kInstrumentCodeID]=tmp.Instrument
						OR fi.[kAlternateCodeID]=tmp.Instrument
						OR fi.[k2ndAlternateID]=tmp.Instrument		
					
						LEFT OUTER JOIN [Finance].[InvestmentTransactions] fit
						ON fit.[DateOfTransaction] =CONVERT(datetime,tmp.date,102)
						AND fit.[fInstrumentID]= [kInstrumentCodeID]
						AND [fInvestmentTransactionTypeID] = 'Broker Fee'
						AND [Account Number] = f2
						WHERE fit.[fInstrumentID] IS NULL		

--Brokerage fee VAT
					INSERT INTO [Finance].[InvestmentTransactions]
					SELECT tmp.Date,[kInstrumentCodeID] ,'Broker Fee VAT' Instrument,tmp.F2,'VAT ON BROKER TRUSTEES FEE',tmp.qty,tmp.total,1,'C.CSH',NULL FROM
						(SELECT CONVERT(datetime,[1614486_Laceya Susanna Riekert_JSE],102) Date, 'C.CSH' Instrument,F2, SUM(CONVERT(money,F7)) qty ,SUM(CONVERT(money,F7)) total FROM [Finance].[InvestmentTransactionsInterim](NOLOCK)
						WHERE  F5 IS NULL AND NOT F3  IS NULL
						--AND LEFT(F3,4) = 'INT ' --Interest payment
						
						AND PATINDEX('%VAT%',F3 )>0 
											GROUP BY CONVERT(datetime,[1614486_Laceya Susanna Riekert_JSE],102),F2
						) tmp	 -- Div Instrument ,F2, CONVERT(money,F7) qty ,CONVERT(money,F7)total--, [Unit Cost Incl] 	 -- Div Instrument ,F2, CONVERT(money,F7) qty ,CONVERT(money,F7)total--, [Unit Cost Incl] 
	
							LEFT OUTER JOIN [Finance].[Instrument] fi (NOLOCK)
						ON fi.[kInstrumentCodeID]=tmp.Instrument
						OR fi.[kAlternateCodeID]=tmp.Instrument
						OR fi.[k2ndAlternateID]=tmp.Instrument		
					
						LEFT OUTER JOIN [Finance].[InvestmentTransactions] fit
						ON fit.[DateOfTransaction] =CONVERT(datetime,tmp.date,102)
						AND fit.[fInstrumentID]= [kInstrumentCodeID]
						AND [fInvestmentTransactionTypeID] = 'Broker Fee VAT'
						AND [Account Number] = f2
						WHERE fit.[fInstrumentID] IS NULL		


--Update processed transactions
						--DELETE FROM  [Finance].[InvestmentTransactionsProcessed]
						--SELECT iti.* FROM [Finance].[InvestmentTransactionsInterim](NOLOCK) iti
						--LEFT OUTER JOIN [Finance].[InvestmentTransactionsProcessed](NOLOCK) itp
			   --         ON iti.[1614486_Laceya Susanna Riekert_JSE]=itp.[1614486_Laceya Susanna Riekert_JSE]
						--AND iti.F2 = itp.F2
						--AND iti.F3 = itp.F3
						--AND COALESCE(iti.F5,'') = COALESCE(itp.F5,'')
						--AND COALESCE(iti.F6,'') = COALESCE(itp.F6,'')
						--AND COALESCE(iti.F7,'') = COALESCE(itp.F7,'')
						--WHERE itp.F2 IS NULL

-- Clear out interim transactions
	DELETE FROM  [Finance].[InvestmentTransactionsInterim]

-- Clear out  transactions
	DELETE FROM [Finance].[InvestmentTransactionsTransit]



				

		END
		IF @transitTable = 'HomeTransactions'
		BEGIN
		SET @transitTable ='HomeTransactions'
		END
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
			@FileName)

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
/*
--LOAD transactions from source

INSERT INTO [dbo].[FinActual]
([fFinTranID],
[Month],
[fCategoryID],

[ActualAmount],
[kFinActualID]) 

SELECT 
kFinTranID,
month,
 fFinCategoryID,
trans,
NEWID()
--,* 
FROM
(SELECT 
 [kFinTranID],[Card],[Card number],ft.Description,fs.kCatSrchID
,

--CONVERT(datetime, 
YEAR([Transaction Date])* 100  + MONTH([Transaction Date]) as month,
fs.[fFinCategoryID],
--fs.kCatSrchID,

COALESCE(Credit,0) - COALESCE(Debit,0) as trans

FROM  [dbo].[FinTran] ft (nolock)
LEFT OUTER JOIN 
[dbo].[FinActual]  fa (nolock)
ON ft.[kFinTranID] = fa.[fFinTranID]
LEFT OUTER JOIN  [dbo].[FinCategorySearch] fs (nolock)
ON patindex(fs.[DescrLookup],ft.description)>0 
AND ((fs.Card IS NULL AND ft.[Card Number] IS NULL) OR fs.Card = ft.[Card Number]
OR (NOT ft.[Card Number] IS NULL AND (SELECT COUNT(1) FROM [dbo].[FinCategorySearch] Where patindex([DescrLookup],ft.description)>0)>0
 AND (SELECT COUNT(1) FROM [dbo].[FinCategorySearch] Where patindex([DescrLookup],ft.description)>0 AND Card = ft.[Card Number])=0
 AND fs.Card is NULL)

)

WHERE 
fa.[fFinTranID] IS NULL
--OR 
--fa.fCategoryID IS NULL
)
 as f


UPDATE [dbo].[FinActual]
set fCategoryID = 
--SELECT 
fFinCategoryID
FROM [dbo].[FinActual] fa 

LEFT OUTER JOIN   [dbo].[FinTran] ft (nolock)
ON ft.[kFinTranID] = fa.[fFinTranID]

LEFT OUTER JOIN  [dbo].[FinCategorySearch] fs (nolock)
ON patindex(fs.[DescrLookup],ft.description)>0 
AND ((fs.Card IS NULL AND ft.[Card Number] IS NULL) OR fs.Card = ft.[Card Number]
OR (NOT ft.[Card Number] IS NULL AND (SELECT COUNT(1) FROM [dbo].[FinCategorySearch] Where patindex([DescrLookup],ft.description)>0)>0
 AND (SELECT COUNT(1) FROM [dbo].[FinCategorySearch] Where patindex([DescrLookup],ft.description)>0 AND Card = ft.[Card Number])=0
 AND fs.Card is NULL))

WHERE fa.fCategoryID IS NULL


UPDATE [dbo].[FinActual]
set fCategoryID = 
--SELECT 
(SELECT kCategoryID
FROM [dbo].[FinancialHierarchy]fh where  ShortName = 'Unmatched')


WHERE fCategoryID IS NULL
*/


--Delete from [dbo].[FinActual]
----select fa.*
--FROM [dbo].[FinActual] fa 
--INNER JOIN (
--	select fa.fFinTranID,min(kFinActualID) as kFinActualID FROM
--	(select fFinTranID from [dbo].[FinActual] fa 
--	GROUP by fFinTranID
--	having count(kFinActualID) >1) as fr
--	INNER JOIN [dbo].[FinActual] fa 
--	on fa. fFinTranID = fr. fFinTranID
--	GROUP BY fa.fFinTranID)
--	as fr
--	ON fa.kFinActualID = fr.kFinActualID


--select * from [dbo].[FinActual] fa where fFinTranID IS NULL

--SELECT * FROM [Finance].[InvestmentInstrumentPricing] where ExchangeRate is null
