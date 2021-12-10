CREATE PROC [Finance].[Prices_DisplayReadingsbyDate](@DateStart date,@DateEnd date, @InvestementInstrument nvarchar(10) NULL) AS

/*
This stored procedure makes use of the PIVOT function in MS SQL to transpose values from rows into columns
*/
BEGIN  
	DECLARE @columns NVARCHAR(MAX), @sql NVARCHAR(MAX)
	/*
	,@DateStart date,@DateEnd date
	SET @DateStart = '2020/08/12'
	SET @DateEnd = '2020/08/20'
	--*/
	SET @columns = N'';
	SELECT @columns+=N', mrd.'+QUOTENAME([DateOfRecord])
	FROM
	(
		SELECT  [DateOfRecord]
		FROM [Finance].[InvestmentInstrumentPricing] mr
		WHERE DateOfRecord  BETWEEN @DateStart AND @DateEnd
		--WHERE [DateOfRecord] BETWEEN '2020/05/12'AND '2020/06/12'
		GROUP BY [DateOfRecord]

	) AS x	
	ORDER BY DateOfRecord 
	--SELECT @columns
	--SELECT STUFF(REPLACE(REPLACE(@columns, ', mrd.[', ','''), ']', ''''), 1, 1, '')
	--SELECT REPLACE(@columns, ']', '''')
	--SELECT STUFF(REPLACE(@columns, ', mrd.[', ',['), 1, 1, '')


	SET @sql = N'
	SELECT Description,[fInstrumentCodeID], '+STUFF(@columns, 1, 2, '')+'FROM (SELECT Description,fInstrumentCodeID,DateOfRecord,SUM(CurrentUnitCost) CurrentUnitCost FROM [Finance].[InvestmentInstrumentPricing] fip LEFT OUTER JOIN [Finance].[Instrument] fi ON kInstrumentCodeID = fInstrumentCodeID WHERE [DateOfRecord] BETWEEN '''+CONVERT(Varchar(10),@DateStart,111)  +''' AND '''+CONVERT(Varchar(10),@DateEnd,111)+'''GROUP BY description ,fInstrumentCodeID ,[DateOfRecord]) AS j PIVOT (SUM([CurrentUnitCost]) FOR [DateOfRecord] in ('+STUFF(REPLACE(@columns, ', mrd.[', ',['), 1, 1, '')+')) AS mrd ORDER BY [fInstrumentCodeID];'
		   ;
	SELECT @sql
	EXEC sp_executesql @sql

END ;  

--SELECT [MeterReading],MeterIDentity,date FROM [dbo].[PropertyMeter] pm  (NOLOCK)
--LEfT OUTER JOIN Property p (NOLOCK)
--ON kPropertyID = pm.fPropertyID
--LEFT OUTER JOIN Meter m (nolock)
--ON m.kMeterID = pm.fMeterId
--LEFT OUTER JOIN [dbo].[MeterReading] mr (NOLOCK)
--ON mr.fMeterID = kMeterID
--LEFT OUTER JOIN [dbo].[MeterReadingDate]mrd (NOLOCK)
--ON mr.fDateMeteringID = kDateMeteringID
--WHERE ErfNumber = '105'
--AND Date BETWEEN '2020/05/12'AND '2020/06/12'


