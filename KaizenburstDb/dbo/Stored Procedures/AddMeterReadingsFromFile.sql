-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	working area for meter reading processing from files
-- =============================================
CREATE PROCEDURE [dbo].[AddMeterReadingsFromFile]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [Erf_No]
      ,[Meter_Number]
      ,[Owners_Name]
      ,[Date_of_Last_Reading]
      ,[Date_of_Current_Reading]
      ,[Units_Used]
      ,[Area__YELLOW]
  FROM [OptFinMan].[dbo].[MeterReadingsRough]

  update [dbo].[MeterReadingsRough]
  set [Date_of_Last_Reading] = '64' where [Erf_No] = '6'

  INSERT INTO [dbo].[Member]
  ([kMemberID],

[ErfNumber],
[OwnerName])

SELECT 
NEWID(),
[Erf_No],
[Owners_Name]
FROM 
[dbo].[MeterReadingsRough] (nolock)




INSERT INTO [dbo].[MeterType] values (NEWID(), 'Water')

INSERT INTO [dbo].[MeterGrouping]
values (NEWID(), 'Yellow')

INSERT INTO [dbo].[MeterGrouping]
values (NEWID(), 'Red')

INSERT INTO [dbo].[MeterGrouping]
values (NEWID(), 'Green')


INSERT INTO [dbo].[Party]
([kPartyID],
[Name])


SELECT NEWID(),
[Owners_Name]

FROM 
(SELECT 
DISTINCT

[Owners_Name]

FROM 
[dbo].[MeterReadingsRough] (nolock)) as i


select * from property

  INSERT INTO [dbo].[Property]
  ([kPropertyID],

[ErfNumber],
[fPartyID])

SELECT 

NEWID(),
[Erf_No],
[kPartyID]
FROM 
[dbo].[MeterReadingsRough] (nolock)
INNER JOIN [dbo].[Party]
on Name = [Owners_Name]

select [ErfNumber],[Name] from [dbo].[Property]
INNER JOIN [dbo].[Party]
on fPartyID = kPartyID


INSERT INTO [dbo].[MeterReadingDate] VALUES (NEWID(),'2019/06/12')

INSERT INTO [dbo].[MeterReadingDate] VALUES (NEWID(),'2019/06/29')

INSERT INTO [dbo].[MeterReadingDate] VALUES (NEWID(),'2019/07/20')
UPDATE [dbo].[MeterReadingDate] set date = '2019/06/15' where date = '2019/06/12'
UPDATE [dbo].[MeterReadingDate] set date = '2019/07/12' where date = '12/07/2019'

select * from property order by erfnumber

select * from [dbo].[MeterReadingDate]

select * from [dbo].[PropertyMeter]
select * from [dbo].[Meter]

INSERT INTO [dbo].[Meter]
([kMeterID],
[MeterIdentity],
[MeterType])

SELECT 
NEWID(),
[Meter_Number],
'w'
--select *--, [Erf_No]
FROM 
[dbo].[MeterReadingsRough]
LEFT OUTER JOIN [dbo].[Meter]
ON [Meter_Number]=[MeterIdentity]
WHERE LEN([Meter_Number])>0 and ([MeterIdentity])IS NULL



order by  [Erf_No] 
update [dbo].[MeterReadingsRough]
set [Erf_No] = '105B' where [Owners_Name] ='P Thon (105B)'

---------------------------------------------------------------------

-- Add Meter Readings from table
--delete [dbo].[MeterReading]

DECLARE @Date date
SET  @Date ='2019/06/29'
INSERT INTO [dbo].[MeterReading]


(
[fDateMeteringID],
[MeterReading],
[fMeterID])

SELECT 
--*
m.[kDateMeteringID],
--[Current_Weeks_Reading],
--[Current_Month_Reading],
--,
[Last_Months_Reading],
--[Date_of_Last_Reading_____________],
--[Date_of_Current_Reading_______________________],
m2.[kMeterId]

FROM 
--IMPORT FROM FILE
--SELECT * FROM
[dbo].[MeterReadingsRoughJune22](nolock)

LEFT OUTER JOIN (

SELECT * FROM [dbo].[MeterReading]


INNER JOIN [dbo].[Meter] m1(NOLOCK)
ON [fMeterID] = m1.[kMeterID]--
WHERE  EXISTS
(SELECT * FROM [dbo].[MeterReadingDate] (NOLOCK)
WHERE [Date] = @Date AND [fDateMeteringID] = [kDateMeteringID])) as i
ON [Meter_Number] = MeterIdentity

LEFT OUTER JOIN (SELECT * FROM [dbo].[MeterReadingDate] (NOLOCK)
WHERE [Date] = @Date) AS o
ON [fDateMeteringID] = o.[kDateMeteringID]

INNER JOIN [dbo].[MeterReadingDate] m (NOLOCK)
ON m.[Date] = @Date

INNER JOIN [dbo].[Meter] m2(NOLOCK)
ON m2.[MeterIdentity] = [Meter_Number]
WHERE  o.[kDateMeteringID] IS NULL
AND LEN([Meter_Number])>0
-----------------------------------------------
---------------------------------------------------------------------
--UPDATE table reading


--DECLARE @Date date
SET  @Date ='2019/06/22'
--UPDATE [dbo].[MeterReading]


--SET [MeterReading] = [Date_of_Last_Reading_____________]
--[fMeterID])

SELECT 
*
--m.[kDateMeteringID],
--[Current_Weeks_Reading]
----[Current_Month_Reading]
--,
----[Date_of_Last_Reading],
--m2.[kMeterId]

FROM [dbo].[MeterReading] m


--IMPORT FROM FILE





INNER JOIN [dbo].[Meter] m1(NOLOCK)
ON [fMeterID] = m1.[kMeterID]--


INNER JOIN (
--DECLARE @Date date
--SET  @Date ='2019/06/12'
SELECT * FROM [dbo].[MeterReadingDate] (NOLOCK)
WHERE [Date] = @Date) AS o
ON [fDateMeteringID] = o.[kDateMeteringID]
INNER JOIN [dbo].[MeterReadingsRoughJuly12] (nolock)
ON [Meter_Number] = MeterIdentity


------------------------------------
select * from [dbo].[MeterReading] where MeterReading = 105


SELECT * FROM [dbo].[MeterGroupAllocation] 
INNER JOIN [dbo].[MeterGrouping]
on fMeterGroupID = kMeterGroupID
where fMeterID= '653CF5A8-6A47-4453-9F5D-3526A0F925F9'

--SELECT * FROM 
SELECT * FROM [dbo].[PropertyMeter]

INSERT INTO [dbo].[PropertyMeter]
([fMeterId],
[fPropertyID])

SELECT DISTINCT 
[kMeterID]
,
[kPropertyID]
FROM 
[dbo].[MeterReadingsRough]
INNER JOIN meter on [Meter_Number] = [MeterIdentity]
INNER JOIN property on [ErfNumber] =[Erf_No]


UPDATE property 
set [ErfNumber] = '105B'

select *
FROM property  INNER JOIN party on kPartyID = fPartyID
WHERE [Name] = 'P Thon (105B)'

SELECT 
Date,
[MeterIdentity],
ErfNumber,
Name,
[MeterReading],
[Description],
[fDateMeteringID]
FROM [dbo].[MeterReading] mr (NOLOCK)
LEFT OUTER JOIN [dbo].[Meter] m (NOLOCK) 
ON [kMeterID] = mr.fMeterID
LEFT OUTER JOIN [dbo].[PropertyMeter] pm (NOLOCK) 
ON [kMeterID] = pm.fMeterID
LEFT OUTER JOIN [dbo].[Property] pf (NOLOCK) 
on kPropertyID = fPropertyID
LEFT OUTER JOIN [dbo].[Party] p (NOLOCK) 
on fPartyID = kPartyID
LEFT OUTER JOIN [dbo].[MeterReadingDate]mrd (NOLOCK) 
on [fDateMeteringID] = [kDateMeteringID]
LEFT OUTER JOIN [dbo].[MeterGroupAllocation] mga (NOLOCK) 
on mga.[fMeterID] = [kMeterID]
LEFT OUTER JOIN [dbo].[MeterGrouping] mg(NOLOCK) 
on [fMeterGroupID] = [kMeterGroupID]
where date = '2019/06/15'
ORDER BY date,Description,ErfNumber



--------------------------------------
delete from [dbo].[MeterReading] where [fDateMeteringID] ='E2A11E55-D82D-4851-A78A-E6AC121394FD'
--DECLARE @DateStart date, @DateEnd date
--Set @DateStart = '12/06/2019'
--Set @DateEnd = '12/07/2019'

--SELECT 

----kMeterID,
--[MeterIdentity],
--ErfNumber,
--Name,
--SUM(mr.[MeterReading]-
--mr1.[MeterReading] ),
--[Description]
--FROM
--(SELECT DISTINCT fMeterID
--FROM [dbo].[MeterReading] mr (NOLOCK))  as lft

--LEFT OUTER JOIN [dbo].[MeterReading] mr (NOLOCK)
--ON lft.fMeterID = mr.fMeterID
--AND EXISTS (SELECT * FROM [dbo].[MeterReadingDate] mrd1(NOLOCK)
--WHERE [Date] = @DateEnd AND mr.[fDateMeteringID] = [kDateMeteringID])

--LEFT OUTER JOIN [dbo].[MeterReading] mr1 (NOLOCK)
--ON lft.fMeterID = mr1.fMeterID
--AND EXISTS (SELECT * FROM [dbo].[MeterReadingDate] mrd1(NOLOCK)
--WHERE [Date] = @DateStart AND mr1.[fDateMeteringID] = [kDateMeteringID])


--LEFT OUTER JOIN [dbo].[Meter] m (NOLOCK) 
--ON [kMeterID] = lft.fMeterID
--LEFT OUTER JOIN [dbo].[PropertyMeter] pm (NOLOCK) 
--ON [kMeterID] = pm.fMeterID
--INNER JOIN [dbo].[Property] pf (NOLOCK) 
--on kPropertyID = fPropertyID
--INNER JOIN [dbo].[Party] p (NOLOCK) 
--on fPartyID = p.kPartyID
----LEFT OUTER JOIN [dbo].[MeterReadingDate]mrd (NOLOCK) 
----on mr.[fDateMeteringID] = [kDateMeteringID]
--INNER JOIN [dbo].[MeterGroupAllocation] mga (NOLOCK) 
--on mga.[fMeterID] = [kMeterID]
--INNER JOIN [dbo].[MeterGrouping] mg(NOLOCK) 
--on [fMeterGroupID] = [kMeterGroupID]

--GROUP by 
--[Description]
----,Name

-----------------------------------------
DECLARE @DateStart date, @DateEnd date
Set @DateStart = '2019/07/12'
Set @DateEnd = '2019/07/20'

IF OBJECT_ID('tempdb..#tmp_bulk') IS NOT NULL
    DROP TABLE #tmp_bulk
CREATE TABLE #tmp_bulk
(
Meter VARCHAR(30),
Volume int
)

INSERT INTO #tmp_bulk
SELECT  

[MeterIdentity],

(mr.[MeterReading]-
mr1.[MeterReading]) AS Volume

FROM
(SELECT DISTINCT fMeterID
FROM [dbo].[MeterReading] mr (NOLOCK))  as lft

LEFT OUTER JOIN [dbo].[MeterReading] mr (NOLOCK)
ON lft.fMeterID = mr.fMeterID
AND EXISTS (SELECT * FROM [dbo].[MeterReadingDate] mrd1(NOLOCK)
WHERE [Date] = @DateEnd AND mr.[fDateMeteringID] = [kDateMeteringID])

LEFT OUTER JOIN [dbo].[MeterReading] mr1 (NOLOCK)
ON lft.fMeterID = mr1.fMeterID
AND EXISTS (SELECT * FROM [dbo].[MeterReadingDate] mrd1(NOLOCK)
WHERE [Date] = @DateStart AND mr1.[fDateMeteringID] = [kDateMeteringID])


LEFT OUTER JOIN [dbo].[Meter] m (NOLOCK) 
ON [kMeterID] = lft.fMeterID

WHERE LEFT([MeterIdentity],4) = 'bulk'


IF OBJECT_ID('tempdb..#tmp_area') IS NOT NULL
    DROP TABLE #tmp_area
CREATE TABLE #tmp_area
(
Area VARCHAR(30),
Input int,
Registered int,
Loss int
)

DECLARE @Bulk1 int,@Bulk2 int,@Bulk3 int,@Bulk4 int,@Bulk5 int
SET @Bulk1 = (SELECT CONVERT(int,Volume) FROM #tmp_bulk WHERE Meter = 'bulk1')
SET @Bulk2 = (SELECT CONVERT(int,Volume) FROM #tmp_bulk WHERE Meter = 'bulk2')
SET @Bulk3 = (SELECT CONVERT(int,Volume) FROM #tmp_bulk WHERE Meter = 'bulk3')
SET @Bulk4 = (SELECT CONVERT(int,Volume) FROM #tmp_bulk WHERE Meter = 'bulk4')
SET @Bulk5 = (SELECT CONVERT(int,Volume) FROM #tmp_bulk WHERE Meter = 'bulk5')
INSERT INTO #tmp_area 
VALUES('Yellow',@Bulk2 - (@Bulk3 + @Bulk4 +@Bulk5),NULL,NULL)
INSERT INTO #tmp_area 
VALUES('Green',@Bulk3 ,NULL,NULL)
INSERT INTO #tmp_area 
VALUES('Orange',@Bulk4 ,NULL,NULL)
INSERT INTO   #tmp_area 
VALUES('Red',@Bulk5 ,NULL,NULL)





--DECLARE @DateStart date, @DateEnd date
--Set @DateStart = '12/06/2019'
--Set @DateEnd = '12/07/2019'

UPDATE #tmp_area

SET Registered = RegCalc,
Loss = LossCalc
FROM #tmp_area

LEFT OUTER JOIN

(SELECT 

--kMeterID,
--[MeterIdentity],
--ErfNumber,
--Name,
--SET Registered = 
Description,
 SUM(CurrentReading-
StartReading) RegCalc
,
--Loss = 
Input -SUM( CurrentReading-
StartReading ) LossCalc

FROM #tmp_area

LEFT OUTER JOIN

(SELECT mr.[MeterReading] as CurrentReading,
mr1.[MeterReading] as StartReading,
[Description]

FROM
((SELECT DISTINCT fMeterID
FROM [dbo].[MeterReading] mr (NOLOCK))  as lft

LEFT OUTER JOIN [dbo].[MeterReading] mr (NOLOCK)
ON lft.fMeterID = mr.fMeterID
AND EXISTS (SELECT * FROM [dbo].[MeterReadingDate] mrd1(NOLOCK)
WHERE [Date] = @DateEnd AND mr.[fDateMeteringID] = [kDateMeteringID])

LEFT OUTER JOIN [dbo].[MeterReading] mr1 (NOLOCK)
ON lft.fMeterID = mr1.fMeterID
AND EXISTS (SELECT * FROM [dbo].[MeterReadingDate] mrd1(NOLOCK)
WHERE [Date] = @DateStart AND mr1.[fDateMeteringID] = [kDateMeteringID])


LEFT OUTER JOIN [dbo].[Meter] m (NOLOCK) 
ON [kMeterID] = lft.fMeterID
LEFT OUTER JOIN [dbo].[PropertyMeter] pm (NOLOCK) 
ON [kMeterID] = pm.fMeterID
INNER JOIN [dbo].[Property] pf (NOLOCK) 
on kPropertyID = fPropertyID
INNER JOIN [dbo].[Party] p (NOLOCK) 
on fPartyID = p.kPartyID

INNER JOIN [dbo].[MeterGroupAllocation] mga (NOLOCK) 
on mga.[fMeterID] = [kMeterID]
INNER JOIN [dbo].[MeterGrouping] mg(NOLOCK) 
on [fMeterGroupID] = [kMeterGroupID]))
 as i
on i.Description = Area
GROUP by [Description],Input)
as i 
on i.Description = Area
SELECT * FROM #tmp_area
SELECT * FROM #tmp_bulk
------------------------------------
select * from property
------------------------------------

SELECT * FROM [dbo].[MeterReadingsRough]
SELECT * FROM [dbo].[MeterGrouping]
SELECT * FROM [dbo].[MeterReading]
LEFT OUTER JOIN [dbo].[Meter] m (NOLOCK) 
ON [kMeterID] = fMeterID
LEFT OUTER JOIN [dbo].[PropertyMeter] pm (NOLOCK) 
ON [kMeterID] = pm.fMeterID
LEFT OUTER JOIN [dbo].[Property] pf (NOLOCK) 
on kPropertyID = fPropertyID
LEFT OUTER JOIN [dbo].[Party] p (NOLOCK) 
on fPartyID = kPartyID
--LEFT OUTER JOIN [dbo].[MeterReadingDate]mrd (NOLOCK) 
--on mr.[fDateMeteringID] = [kDateMeteringID]
LEFT OUTER JOIN [dbo].[MeterGroupAllocation] mga (NOLOCK) 
on mga.[fMeterID] = [kMeterID]
LEFT OUTER JOIN [dbo].[MeterGrouping] mg(NOLOCK) 
on [fMeterGroupID] = [kMeterGroupID]

delete from [dbo].[MeterGroupAllocation]

INSERT INTO [dbo].[MeterGroupAllocation]
([fMeterGroupID],
[fMeterID],
[DateStart])

SELECT [kMeterGroupID],
[kMeterID],
'01/01/2001'
--,
--[Area__YELLOW],
--[Description]

--select SUBSTRING ([Area__YELLOW],7,10),LEN(SUBSTRING ([Area__YELLOW],6,10)),patindex('%'+RTRIM([Description])+'%',[Area__YELLOW]),LEN(description), '%'+RTRIM([Description])+'%',*--, [Erf_No]
--Select * 
FROM 
[dbo].[MeterReadingsRough]
INNER JOIN [dbo].[Meter] 
ON [MeterIdentity] = [Meter_Number]
LEFT OUTER JOIN [dbo].[MeterGrouping]
ON 
patindex('%'+RTRIM([Description])+'%',[Area__YELLOW])>0
WHERE NOT [Description] IS NULL

delete from[dbo].[MeterReadingsRough]
UPDATE [dbo].[MeterReadingsRough] set 	[Area__YELLOW] = 	'Area  YELLOW'		where 		[Erf_No]	= '109'											


SELECT * FROM meter 
LEFT OUTER JOIN [dbo].[PropertyMeter] ON kMeterID =  fMeterID
LEFT OUTER JOIN [dbo].[Property] ON[fPropertyID]=[kPropertyID]
LEFT OUTER JOIN  [dbo].[MeterGroupAllocation] mg ON kMeterID = mg.fMeterID




--DECLARE @Datestart date, @DateEnd date
DECLARE @DateS date,@DateF date
SET @DateF = '2019/12/01'
SET @DateS = '2019/06/12' 
SET @Datestart = 
(
select MIN (date) from [dbo].[MeterReadingDate] 
WHERE 
date BETWEEN @DateS AND @DateF
) 

		IF OBJECT_ID('tempdb..##tmp_area') IS NOT NULL
			DROP TABLE ##tmp_area
		CREATE TABLE ##tmp_area
		(
		ErfNumber VARCHAR(30),
		Name VARCHAR(30),
		Registered int,
		Loss int
		)

DECLARE Period_Cursor CURSOR 
FOR 
SELECT  date FROM [dbo].[MeterReadingDate] (NOLOCK)
WHERE date > @DateStart AND  date <=@DateF 
OPEN Period_Cursor
FETCH NEXT FROM  Period_Cursor INTO 
        @DateEnd

WHILE @@FETCH_STATUS = 0
    BEGIN

		SELECT 
		--*
		----kMeterID,
	
		ErfNumber,
		Name,		
		Description Area,
		@DateStart PeriodStartDate,	
		@DateEnd PeriodEndDate,		
		StartReading,CurrentReading,
		----SET Registered = 

		 (CurrentReading-
		StartReading) Consumption
		,
		 CONVERT(real,(CurrentReading-
		StartReading) )/ CONVERT(real,DATEDIFF(D,@DateStart,@DateEnd))*7 WeeklyConsumption
		----Loss = 
		--Input -SUM( CurrentReading-
		--StartReading ) DailyAverage


		FROM
		(
		
		--DECLARE @DateStart date, @DateEnd date
		--Set  = '2019/06/12'
		--Set  = '2019/07/12'		
		SELECT 
		--*
		mr.[MeterReading] as CurrentReading,
		mr1.[MeterReading] as StartReading,
		[Description]	,
		[MeterIdentity],
		ErfNumber
		,	Name

		FROM
		(SELECT DISTINCT fMeterID 
		--,[MeterIdentity]
		--ErfNumber,

		FROM [dbo].[MeterReading] mr (NOLOCK))  as lft

		LEFT OUTER JOIN [dbo].[MeterReading] mr (NOLOCK)
		ON lft.fMeterID = mr.fMeterID
		AND EXISTS (SELECT * FROM [dbo].[MeterReadingDate] mrd1(NOLOCK)
		WHERE [Date] = @DateEnd AND mr.[fDateMeteringID] = [kDateMeteringID])

		LEFT OUTER JOIN [dbo].[MeterReading] mr1 (NOLOCK)
		ON lft.fMeterID = mr1.fMeterID
		AND EXISTS (SELECT * FROM [dbo].[MeterReadingDate] mrd1(NOLOCK)
		WHERE [Date] = @DateStart AND mr1.[fDateMeteringID] = [kDateMeteringID])


		LEFT OUTER JOIN [dbo].[Meter] m (NOLOCK) 
		ON [kMeterID] = lft.fMeterID
		LEFT OUTER JOIN [dbo].[PropertyMeter] pm (NOLOCK) 
		ON [kMeterID] = pm.fMeterID
		INNER JOIN [dbo].[Property] pf (NOLOCK) 
		on kPropertyID = fPropertyID
		INNER JOIN [dbo].[Party] p (NOLOCK) 
		on fPartyID = p.kPartyID

		INNER JOIN [dbo].[MeterGroupAllocation] mga (NOLOCK) 
		on mga.[fMeterID] = [kMeterID]
		INNER JOIN [dbo].[MeterGrouping] mg(NOLOCK) 
		on [fMeterGroupID] = [kMeterGroupID]
		)
		as i
	SET @Datestart = @DateEnd
		

        FETCH NEXT FROM Period_Cursor  INTO 
             @DateEnd
           
    END;

	CLOSE Period_Cursor
	DEALLOCATE Period_Cursor 

END
