
CREATE PROC [Finance].[ProcessInvestmentHoldings] AS
/*
Stored proc ProcessInvestmentTransactions
This stored proc will use data imported into the [Finance].[InvetmentTransactionsTransit] table to update tables related to investment tables.



Created : Dec 2020

*/

BEGIN  
--First check for any accounts referenced in the transit file and add
INSERT INTO [Finance].[InvestmentAccounts]
SELECT DISTINCT F2,F2,'Investec' 
FROM [Finance].[InvestmentTransactionsTransit] itt (NOLOCK)
LEFT OUTER JOIN [Finance].[InvestmentAccounts] it (NOLOCK)
ON Account = F2
WHERE Account IS NULL
AND NOT F3 IS NULL
AND NOT F2 = 'Account Number'

INSERT INTO [Finance].[Share]
SELECT DISTINCT F5,F5,NULL,NULL,NULL 
FROM [Finance].[InvestmentTransactionsTransit] itt (NOLOCK)
LEFT OUTER JOIN [Finance].[Share] s (NOLOCK)
ON Code = F5
WHERE CODE IS NULL
AND NOT F5 IS NULL
AND NOT F5 = 'Share Name'



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
