
CREATE PROC [Finance].[ProcessInvestmentTransactions] AS
/*
Stored proc AddTransactionsFromFiles
This stored proc will import data stored in csv files in the listed directory and with file names of 'Transaction-historya.csv' and/or 'Transaction-historyc.csv'
into the FinTran table

This uses another stored proc, ProcessActuals, to sort transactions in genealogical and date order, using filters in the [FinCategorySearch] table,
and the transaction date provided

Created : 2018
Modified: 29/12/2018 by TRiekert
*/

BEGIN  


delete from [dbo].[Inv Transactions a]
delete from [dbo].[Inv Transactions c]
--Start with clean tables

BULK INSERT [dbo].[Inv Transactions a]FROM 'C:\Users\triek\Downloads\Transaction-historya.csv' 
WITH (   FIELDTERMINATOR =',',
        ROWTERMINATOR = '\n' ,FIRSTROW = 3)
		--the BULK INSERT command is used to import the .csv files
BULK INSERT [dbo].[Inv Transactions c]FROM 'C:\Users\triek\Downloads\Transaction-historyc.csv' 
WITH (   FIELDTERMINATOR =',',
        ROWTERMINATOR = '\n' ,FIRSTROW = 3)   


UPDATE [dbo].[Inv Transactions a]
SET [Balance] = STUFF(STUFF([Balance],PATINDEX('%"%',[Balance]),1,''),PATINDEX('%"%',STUFF([Balance],PATINDEX('%"%',[Balance]),1,'')),1,''),
[Debits] = STUFF(STUFF([Debits],PATINDEX('%"%',[Debits]),1,''),PATINDEX('%"%',STUFF([Debits],PATINDEX('%"%',[Debits]),1,'')),1,''),
[Credits] = STUFF(STUFF([Credits],PATINDEX('%"%',[Credits]),1,''),PATINDEX('%"%',STUFF([Credits],PATINDEX('%"%',[Credits]),1,'')),1,'')
from  [dbo].[Inv Transactions a]
WHERE PATINDEX('%"%', [Balance])>0
OR PATINDEX('%"%', [Debits])>0
OR PATINDEX('%"%', [Credits])>0

UPDATE [dbo].[Inv Transactions c]
SET 
[Debits] = STUFF(STUFF([Debits],PATINDEX('%"%',[Debits]),1,''),PATINDEX('%"%',STUFF([Debits],PATINDEX('%"%',[Debits]),1,'')),1,''),
[Credits] = STUFF(STUFF([Credits],PATINDEX('%"%',[Credits]),1,''),PATINDEX('%"%',STUFF([Credits],PATINDEX('%"%',[Credits]),1,'')),1,'')
from  [dbo].[Inv Transactions c]
WHERE  PATINDEX('%"%', [Debits])>0
OR PATINDEX('%"%', [Credits])>0

UPDATE [dbo].[Inv Transactions a]
SET [Balance] = '-' + STUFF([Balance],PATINDEX('%DR%',[Balance]),2,''),
[Debits] = STUFF(STUFF([Debits],PATINDEX('%"%',[Debits]),1,''),PATINDEX('%"%',STUFF([Debits],PATINDEX('%"%',[Debits]),1,'')),1,''),
[Credits] = STUFF(STUFF([Credits],PATINDEX('%"%',[Credits]),1,''),PATINDEX('%"%',STUFF([Credits],PATINDEX('%"%',[Credits]),1,'')),1,'')
from  [dbo].[Inv Transactions a]
WHERE PATINDEX('%DR%', [Balance])>0
OR PATINDEX('%DR%', [Debits])>0
OR PATINDEX('%DR%', [Credits])>0

UPDATE [dbo].[Inv Transactions c]
SET 
[Debits] = STUFF(STUFF([Debits],PATINDEX('%"%',[Debits]),1,''),PATINDEX('%"%',STUFF([Debits],PATINDEX('%"%',[Debits]),1,'')),1,''),
[Credits] = STUFF(STUFF([Credits],PATINDEX('%"%',[Credits]),1,''),PATINDEX('%"%',STUFF([Credits],PATINDEX('%"%',[Credits]),1,'')),1,'')
from  [dbo].[Inv Transactions c]
WHERE  PATINDEX('%DR%', [Debits])>0
OR PATINDEX('%DR%', [Credits])>0

UPDATE [dbo].[Inv Transactions a]
SET [Balance] =+ STUFF([Balance],PATINDEX('% %',[Balance]),1,'')
from  [dbo].[Inv Transactions a]
WHERE PATINDEX('% %', [Balance])>0

--delete  from [dbo].[FinTran]

-- transactions not yet on the FinTran table are added
INSERT INTO [dbo].[FinTran]
([Posted Date],
[Transaction Date],
[Description],
[Debit],
[Credit],
[Balance],
[Card Number],
[kFinTranID]
)
SELECT --top 10  
CONVERT(datetime,rg.[Posting Date],101) ,
 CONVERT(datetime,rg.[Transaction Date],101),
 rg.[Description],
 
 --convert(money,rg.[Debits]),
 -- convert(money,rg.[Credits]),
  --convert(money,rg.[Balance]),
 rg.[Debits],
  rg.[Credits],
  rg.[Balance],
  rc.[Card Number],
  NEWID()
  --,len



 FROM [dbo].[Inv Transactions a] rg (nolock)
LEFT OUTER JOIN [dbo].[FinTran] (nolock) ft
ON CONVERT(datetime,rg.[Posting Date],101) = ft.[Posted Date]
AND CONVERT(datetime,rg.[Transaction Date],101) = ft.[Transaction Date]
AND rg.[Description]=ft.[Description]
AND rg.Balance = ft.Balance
LEFT OUTER JOIN  [dbo].[Inv Transactions c] rc (nolock)
ON rg.[Posting Date]= rc.[Posting Date]
AND rg.[Transaction Date]= rc.[Transaction Date]
AND rg.[Description]=rc.[Description]
AND (rg.debits = rc.debits OR rg.debits is null)
WHERE ft.[Description] IS NULL

EXEC [dbo].[ProcessActuals]
END ;  
