CREATE PROC [Finance].[ClassifyTransactions] AS

/*
Stored proc ProcessActuals
This stored proc will process transactions in the FinTranimport data stored in csv files in the listed directory and with file names of 'Transaction-historya.csv' and/or 'Transaction-historyc.csv'
into the  table

This uses another stored proc, ProcessActuals, to sort transactions in genealogical and date order, using filters in the [FinCategorySearch] table,
and the transaction date provided

Created : 2018
Modified: 29/12/2018 by TRiekert
*/
BEGIN  

--LOAD transactions from source

INSERT INTO [Finance].[FinActual]
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

FROM  [Finance].[FinTran] ft (nolock)
LEFT OUTER JOIN 
[Finance].[FinActual]  fa (nolock)
ON ft.[kFinTranID] = fa.[fFinTranID]
LEFT OUTER JOIN  [Finance].[FinCategorySearch] fs (nolock)
ON patindex(fs.[DescrLookup],ft.description)>0 
AND ((fs.Card IS NULL AND ft.[Card Number] IS NULL) OR fs.Card = ft.[Card Number]
OR (NOT ft.[Card Number] IS NULL AND (SELECT COUNT(1) FROM [Finance].[FinCategorySearch] Where patindex([DescrLookup],ft.description)>0)>0
 AND (SELECT COUNT(1) FROM [Finance].[FinCategorySearch] Where patindex([DescrLookup],ft.description)>0 AND Card = ft.[Card Number])=0
 AND fs.Card is NULL)

)

WHERE 
fa.[fFinTranID] IS NULL
--OR 
--fa.fCategoryID IS NULL
)
 as f


UPDATE [Finance].[FinActual]
set fCategoryID = 
--SELECT 
fFinCategoryID
FROM [Finance].[FinActual] fa 

LEFT OUTER JOIN   [Finance].[FinTran] ft (nolock)
ON ft.[kFinTranID] = fa.[fFinTranID]

LEFT OUTER JOIN  [Finance].[FinCategorySearch] fs (nolock)
ON patindex(fs.[DescrLookup],ft.description)>0 
AND ((fs.Card IS NULL AND ft.[Card Number] IS NULL) OR fs.Card = ft.[Card Number]
OR (NOT ft.[Card Number] IS NULL AND (SELECT COUNT(1) FROM [Finance].[FinCategorySearch] Where patindex([DescrLookup],ft.description)>0)>0
 AND (SELECT COUNT(1) FROM [Finance].[FinCategorySearch] Where patindex([DescrLookup],ft.description)>0 AND Card = ft.[Card Number])=0
 AND fs.Card is NULL))

WHERE fa.fCategoryID IS NULL




END ;  
--Delete from [Finance].[FinActual]
----select fa.*
--FROM [Finance].[FinActual] fa 
--INNER JOIN (
--	select fa.fFinTranID,min(kFinActualID) as kFinActualID FROM
--	(select fFinTranID from [Finance].[FinActual] fa 
--	GROUP by fFinTranID
--	having count(kFinActualID) >1) as fr
--	INNER JOIN [Finance].[FinActual] fa 
--	on fa. fFinTranID = fr. fFinTranID
--	GROUP BY fa.fFinTranID)
--	as fr
--	ON fa.kFinActualID = fr.kFinActualID


--select * from [Finance].[FinActual] fa where fFinTranID IS NULL
