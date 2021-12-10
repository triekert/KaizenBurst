CREATE PROC [DataIntegration].[AddTransactionsFromFiles]
WITH RECOMPILE
AS
/*
Stored proc AddTransactionsFromFiles
This stored proc will import data stored in files of various types stored in the registered directory/ies by first listing all files of the target file classification
into a temporary 'transit' table corresponding to the relevant data type, then read eachfile into the staging table, after which the read file is moved to an archive folder. Should an error result whilst importing a specific file, that file will be moved to an
'Error' directory. Any errors encountered during the process will be logged on the DB error table as well.

This procedure then uses various other stored procedures, to process data from the,
and the transaction date provided

Created : 2018
Modified: 29/12/2018 by TRiekert
*/

BEGIN  

/* First create a temp table to store all file names in the target source directory, use xp_commandshell to load the filenames into the table,
then create a cursor and loop through all files, using BulkInsert to load into the Transaction landing table

*/
--Create temp table for loading file directory cursor

DECLARE @ImportPath  varchar(200),@ImportType varchar(100),@ImportTypeID uniqueidentifier,@sourceDirectory varchar(100),@filePrefix varchar(100),@fileExtension varchar(10),@fileName varchar(1000),@transitTable varchar(50)
,@BulkInsert nvarchar(max),@EOLCharacter varchar(10),@FieldCharacter varchar(10),@SheetName varchar(50),@DateOfFile date,@Account varchar(50),@AccountStart int,@AccountLength int,@DateStart int,@DateLength int,@DateFormat nchar(20)
IF OBJECT_ID('tempdb..##tmp_files') IS NOT NULL
	DROP TABLE ##tmp_files
	CREATE TABLE ##tmp_files
	(
	fileName varchar(1000)
	)



--Create cursor importTypeCursor to work all import directories for processing import files
DECLARE  importTypeCursor CURSOR    
FOR
SELECT  Name,kImportTargetID,sourceDirectory,filePrefix ,fileExtension,transitTable,EOLCharacter,FieldCharacter,AccountStart,AccountLength,DateStart,DateLength,DateFormat,SheetName 
FROM[DataIntegration].[ImportTypes] (NOLOCK)it
INNER JOIN [DataIntegration].[FileImport] fi (NOLOCK)
ON [kImportTargetID] = [fImportTargetID]
WHERE NOT COALESCE(isSuspend,'a') = 's'

	OPEN importTypeCursor
		FETCH NEXT FROM importTypeCursor INTO @ImportType,@ImportTypeID,@sourceDirectory,@filePrefix ,@fileExtension ,@transitTable,@EOLCharacter,@FieldCharacter,@AccountStart,@AccountLength,@DateStart,@DateLength,@DateFormat,@sheetName   
		WHILE @@FETCH_STATUS = 0  
		BEGIN
			SET @ImportPath  =  'dir '+@sourceDirectory+ '/b/a-d'
			--SELECT  @ImportPath
			DELETE  FROM ##tmp_files
			INSERT INTO ##tmp_files EXECUTE xp_cmdshell     @ImportPath 
			SELECT * FROM ##tmp_files
			--SET @fileExtension='.xlsx'
			--SELECT @fileExtension
			--SET @filePrefix = 'TransactionHistory-All'
 
			--Create Cursor for looping through files in target directory - only files having the predefined suffix and file extension are included in the list
			--SELECT @fileExtension
			--SELECT @filePrefix 
			--SELECT len(@fileExtension)
			--SELECT len(@filePrefix)
			--SELECT * FROM ##tmp_files
			--WHERE RIGHT(fileName,len(@fileExtension)) =@fileExtension
			--AND LEFT(fileName,len(@filePrefix)) =@filePrefix

			DECLARE  fileCursor CURSOR    
			FOR
			/*DECLARE @ImportPath  varchar(200),@ImportType varchar(100),@ImportTypeID uniqueidentifier,@sourceDirectory varchar(100),@filePrefix varchar(100),@fileExtension varchar(10),@fileName varchar(1000),@transitTable varchar(50)
,@BulkInsert nvarchar(max),@EOLCharacter varchar(10),@SheetName varchar(50),@DateOfFile date,@Account varchar(50),@AccountStart int,@AccountLength int,@DateStart int,@DateLength int,@DateFormat nchar(20)
			SET @fileExtension='.xlsx'
			SET @filePrefix = 'TransactionHistory-All'
			--*/


			SELECT FileName FROM ##tmp_files
			WHERE RIGHT(Filename,len(@fileExtension)) =@fileExtension
			AND LEFT(Filename,len(@filePrefix)) =@filePrefix
				OPEN fileCursor	
					FETCH NEXT FROM fileCursor INTO @fileName;
					SELECT @fileName
					WHILE @@FETCH_STATUS = 0  


					BEGIN

					BEGIN TRY	
--Currently provision is made for reading .csv and .xslx files
--A 'transit' table must be created in the corresponding data format and linked to each importFileType/fileImport combination before any data can be loaded	
				
					-- if date and /or account number are contained in filename, extract same into variables
					
					IF 	NOT (@AccountStart IS NULL OR @AccountLength IS NULL)	--Extract account number from filename		
					SET @Account = SUBSTRING(@fileName,@AccountStart,@AccountLength)

/*DECLARE @ImportPath  varchar(200),@ImportType varchar(100),@sourceDirectory varchar(100),@filePrefix varchar(100),@fileExtension varchar(10),@fileName varchar(1000),@transitTable varchar(50)
,@BulkInsert nvarchar(max),@EOLCharacter varchar(10),@SheetName varchar(50),@DateOfFile date,@Account varchar(50),@AccountStart int,@AccountLength int,@DateStart int,@DateLength int,@DateFormat nchar(20)
SET @fileName ='Holdings-201908071614486_Laceya Susanna Riekert_JSE'
SET  @DateStart = 10
SET @DateLength =8
SET @DateFormat = 'CCCCMMDD'
--*/


					IF NOT (@DateStart IS NULL OR @DateFormat IS NULL OR @DateLength IS NULL)	--Extract date from filename	
					SET @DateOfFile = CONVERT(date,SUBSTRING(@fileName,@DateStart,@DateLength),CASE WHEN @DateFormat = 'CCCCMMDD' THEN
					112 END)

					SELECT @DateOfFile



					IF @fileExtension ='.csv'
						BEGIN
										
							SET @BulkInsert=


								'BULK INSERT'+@transitTable+ ' FROM ''' +REPLACE(@sourceDirectory,'"','')+@fileName +''' WITH (   FIELDTERMINATOR ='''+@FieldCharacter+ ''',ROWTERMINATOR = '''+@EOLCharacter+ ''' ,FIRSTROW = 2, MAXERRORS =100
								,ERRORFILE = '''+REPLACE(@sourceDirectory,'"','')+'Errors\'+@fileName +'.log'+''')'

						END
					ELSE
					--default to reading native .XSLX files
					BEGIN


						/*DECLARE @BulkInsert nvarchar(max),@SheetName varchar(50),@sourceDirectory varchar(100),@fileName varchar(1000),@transitTable varchar(50)
						SET @SheetName = '''Transaction History$'''
						SET @sourceDirectory ='C:\Users\triek\Downloads\InvestmentTransactions\'
						SET @fileName ='TransactionHistory-All-20050101-20210205.xlsx'
						SET @transitTable ='[Finance].[InvestmentTransactionsTransit]'
						--*/
						EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1

						EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1						
						SET @BulkInsert='INSERT INTO ' +@transitTable+ ' SELECT * FROM OPENDATASOURCE('''+ 'Microsoft.ACE.OLEDB.12.0'+''','''
						+'Data Source='+REPLACE(@sourceDirectory,'"','')+@fileName +';Extended Properties=Excel 12.0'+ ''')...['+@SheetName +']'
			--SELECT @BulkInsert
			--		EXECUTE sp_executesql @BulkInsert

					END
					SELECT @BulkInsert
					EXECUTE sp_executesql @BulkInsert
					--SELECT @Filename
					--BULK INSERT[DataIntegration].[TransactionsAbsa] FROM 'C:\Users\triek\Downloads\Tre Donne transactions\4055172264_2018-11-15 4UKAJ7Q29V6se7JbURsU.pdf.csv' WITH (   FIELDTERMINATOR =',',ROWTERMINATOR = '0x0a' ,FIRSTROW = 2)
					SELECT * FROM [Finance].[InvestmentTransactionsTransit]
					--Process data from transit files and move into organisation production database

					EXEC [Finance].[ProcessActuals] @transitTable,@Account,@DateOfFile,@FileName

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
					---- Transaction uncommittable
					--	IF (XACT_STATE()) = -1
					--	  ROLLBACK TRANSACTION
 
					---- Transaction committable
					--	IF (XACT_STATE()) = 1
					--	  COMMIT TRANSACTION
					END CATCH 		
				--Move successfully imported file to Archive directory

		/*		DECLARE @ImportPath  varchar(200), @sourceDirectory varchar(100),@fileName varchar(1000)
				SET @fileName ='"Transaction-History (22).csv"'
				SET @sourceDirectory = 'C:\Users\triek\Downloads\Holdings'

		--*/
				SET @ImportPath  =  'move '+@sourceDirectory+'"' +@fileName + '" '+ @sourceDirectory+'Archive\'
				SELECT  @ImportPath
				EXECUTE xp_cmdshell     @ImportPath 					  			
				FETCH NEXT FROM fileCursor INTO @fileName;        
			END


			CLOSE fileCursor;
			DEALLOCATE fileCursor;
			FETCH NEXT FROM importTypeCursor INTO @ImportType,@ImportTypeID,@sourceDirectory,@filePrefix ,@fileExtension ,@transitTable,@EOLCharacter,@FieldCharacter,@AccountStart,@AccountLength,@DateStart,@DateLength,@DateFormat,@sheetName   
		END
	CLOSE importTypeCursor;
	DEALLOCATE importTypeCursor;
-- DECLARE @BulkInsert nvarchar(max)
-- SET @BulkInsert ='BULK INSERT [DataIntegration].[TransactionsAbsa] FROM ''C:\Users\triek\Downloads\Tre Donne transactions\4055172264_2018-11-15 4UKAJ7Q29V6se7JbURsU.pdf.csv'' WITH (   FIELDTERMINATOR ='','',ROWTERMINATOR = ''0x0a'' ,FIRSTROW = 2)'
--EXECUTE sp_executesql @BulkInsert
--BULK INSERT[DataIntegration].[TransactionsAbsa] FROM 'C:\Users\triek\Downloads\Tre Donne transactions\4055172264_2020-07-15 CRoxyTflYWEbggQYXHua.pdf.csv' WITH (   FIELDTERMINATOR =',',ROWTERMINATOR = '0x0a' ,FIRSTROW = 2, MAXERRORS =10        ,ERRORFILE = 'C:\Users\triek\Downloads\Tre Donne transactions\Errors\4055172264_2020-07-15 CRoxyTflYWEbggQYXHua.pdf.csv.log')
 
--delete from [DataIntegration].[TransactionsAbsa]
--select * from [DataIntegration].[TransactionsAbsa]
--select * from [DataIntegration].[DB_Errors]
--DELETE from [DataIntegration].[DB_Errors]
--delete from [dbo].[Inv Transactions a]
--delete from [dbo].[Inv Transactions c]
--Start with clean tables

--BULK INSERT [dbo].[4055172264_2018-11-15 4UKAJ7Q29V6se7JbURsU.pdf]FROM 'C:\Users\triek\Downloads\Tre Donne transactions\4055172264_2018-11-15 4UKAJ7Q29V6se7JbURsU.pdf.csv' 
--WITH (   FIELDTERMINATOR =',',
--        ROWTERMINATOR = '0x0a' ,FIRSTROW = 2)
--		--the BULK INSERT command is used to import the .csv files
--BULK INSERT [dbo].[Inv Transactions c]FROM 'C:\Users\triek\Downloads\Transaction-historyc.csv' 
--WITH (   FIELDTERMINATOR =',',
--        ROWTERMINATOR = '\n' ,FIRSTROW = 3)   

/*
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
*/
DROP TABLE ##tmp_files
END ;  
