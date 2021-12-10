
CREATE PROC [Finance].[spFindInvalidCardFilter]
AS   
BEGIN  
   select * FROM 
(select * from [Finance].[fnTblFinHiearch]() fh
where NOT card IS NULL) as fh
INNER JOIN [Finance].[fnTblFinHiearch]() fh1
on fh.Card = fh1.card
AND fh.Parent = fh1.parent
AND fh.shortName <> fh1.shortName


END ;  

