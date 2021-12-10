CREATE PROC [Finance].[RemDupTransactions] AS
BEGIN  

DELETE FROM [Finance].[FinActual]
--select * 
FROM [Finance].[FinActual]fin inner join 
(select max(kFinActualID) kFinActID FROM 
(select ft2.* FROM
(select fFinTranID from finActual ft
group by fFinTranID
having count(fFinTranID) >1
) as dup
left outer JOIN finActual ft2
on dup.fFinTranID = ft2.fFinTranID
--ORDER BY fFinTranID
) dup
GROUP BY dup.fFinTranID) dup
ON dup.kFinActID = fin.kFinActualID

DELETE FROM [Finance].[FinActual]
--select * 
FROM [Finance].[FinActual]fin inner join 
(select max(kFinTranID) kFinTranID FROM 
(select ft2.* FROM
(select balance from fintran ft
group by balance,[Transaction Date]
having count(balance) >1
) as dup
left outer JOIN fintran ft2
on dup.balance = ft2.Balance) dup
GROUP BY dup.Balance,dup.[Transaction Date]) dup
ON dup.kFinTranID = fin.fFinTranID


DELETE FROM [Finance].[FinTran]
--select * 
FROM [Finance].[FinTran]fin inner join 
(select max(kFinTranID) kFinTranID FROM 
(select ft2.* FROM
(select balance from fintran ft
group by balance,[Transaction Date]
having count(balance) >1
) as dup
left outer JOIN fintran ft2
on dup.balance = ft2.Balance) dup
GROUP BY dup.Balance,dup.[Transaction Date]) dup
ON dup.kFinTranID = fin.kFinTranID


DELETE FROM [Finance].[FinActual]
--select *  

FROM [Finance].[FinActual] fa INNER JOIN 
(SELECT ft2.fFinTranID,max(ft2.kFinActualID) kFinActualID FROM
	(select ft2.* FROM
		(select l.*--,count(f.description) 
			FROM
				(select distinct [Posted Date],[Transaction Date],Description,Balance,kFinActualID,kFinTranID from FinTran
				INNER JOIN FinActual on fFinTranID = kFinTranID) l
			LEFT OUTER JOIN FinActual f
			on l.kFinTranID = f.fFinTranID
			GROUP BY l.[Posted Date],
			l.[Transaction Date],
			l.Description,
			l.Balance,
			l.kFinActualID,
			l.kFinTranID
			HAVING count(f.kFinActualID)>1
			) as l
			left outer JOIN finActual ft2
			on l.kFinActualID= ft2.kFinActualID) dup
	left outer JOIN finActual ft2
	on dup.kFinActualID= ft2.kFinActualID
	GROUP BY ft2.fFinTranID) as dup
ON dup.kFinActualID = fa.kFinActualID

END ;  


