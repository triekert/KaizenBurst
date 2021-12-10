CREATE PROC [dbo].[CalculateConsumptionVariance](@DateStart date,@DateEnd date) AS
BEGIN  
		
		--First validate whether readings taken on requested dates...
		IF NOT EXISTS (SELECT * FROM [dbo].[MeterReadingDate] (NOLOCK)
		WHERE [Date] = @DateStart ) 
		BEGIN 
			RETURN 'No Readings for Selected Start Date'
		END
				IF NOT EXISTS (SELECT * FROM [dbo].[MeterReadingDate] (NOLOCK)
		WHERE [Date] = @DateEnd) 
		BEGIN 
			RETURN 'No Readings for Selected End Date'
		END
		--Manipulate order of dates if mistake is made in order...
		DECLARE @DateTemp date

		--DECLARE @DateStart date, @DateEnd date
		--Set @DateStart = '2019/07/12'
		--Set @DateEnd = '2019/07/20'

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

		--SET Registered = RegCalc,
		--Loss = LossCalc
		--FROM #tmp_area

		INSERT INTO  #tmp_area 
		select
		'Total',
		SUM (INPUT),
		SUM (REGISTERED),
		SUM (LOSS)
		FROM 
		#tmp_area 



		--Calculate consumption between dates
		--DECLARE @DateStart date, @DateEnd date
		--Set @DateStart = '2019/06/12'
		--Set  @DateEnd= '2019/07/12'
		SELECT 
		--*
		----kMeterID,
		--[MeterIdentity],
		ErfNumber,
		Name,
		
		StartReading,CurrentReading,
		----SET Registered = 
		Description Area,
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
		ORDER BY Description,ErfNumber



		SELECT * FROM #tmp_area ORDER BY [Loss]
		SELECT * FROM #tmp_bulk ORDER BY [Meter]

END ;  
