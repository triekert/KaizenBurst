CREATE PROC [dbo].[CalculateConsumptionComparisonDetail](@DateS date,@DateF date) AS
BEGIN  


	DECLARE 
	@Datestart date, @DateEnd date
	--@DateS date,@DateF date
	--SET @DateF = '2019/12/01'
	--SET @DateS = '2019/06/12' 
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
			Area VARCHAR(30),
			PeriodStartDate date,
			PeriodEndDate date,
			StartReading int,
			EndReading int,
			Consumption int,
			WeeklyConsumption real
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
			INSERT INTO ##tmp_area
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
		SELECT * FROM ##tmp_area  ORDER BY Area,ErfNumber,PeriodEndDate
		DROP TABLE ##tmp_area

END ; 
