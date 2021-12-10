
CREATE Proc [DataIntegration].[spManageFileImportData](@SourceDirectory varchar(100) NULL, @filePrefix varchar(100) NULL , @fileExtension varchar(10)  NULL,@EOLCharacter varchar(10) NULL,@FirstRow int NULL, @LastRow int NULL,
@AccountStart int NULL,@AccountLength int NULL,@DateStart int NULL,@DateLength int NULL,@SheetName varchar(100),@name varchar(100) ,@DateFormat nchar(20))  



/* Stored procedure:spAddImportType

Used for adding an ImportType

Parameters: 

@Name  - Name of Import Type
@Description - Longer description of new import type if required

Created : 2020/12/5 by TRiekert

*/

AS   
BEGIN  

DECLARE @ImportType uniqueidentifier
SET @ImportType = (SELECT [kImportTargetID] FROM [DataIntegration].[ImportTypes] (NOLOCK)
	WHERE Name = @Name ) 


--If import type does not exit, exit with error
	IF @ImportType IS NULL
	RETURN 1

	IF (SELECT COUNT(*) FROM [DataIntegration].[FileImport] (NOLOCK)

	WHERE [fImportTargetID] = @ImportType
	--'SN 180742756'
	) = 1
		BEGIN
			IF @SourceDirectory  IS NULL
			SET @SourceDirectory = (SELECT SourceDirectory  FROM [DataIntegration].[FileImport] (NOLOCK) WHERE [fImportTargetID] = @ImportType) 
			--SELECT  @transitTable
			IF @filePrefix  IS NULL 
			SET @filePrefix =  (SELECT filePrefix  FROM [DataIntegration].[FileImport] (NOLOCK) WHERE [fImportTargetID] = @ImportType)
			IF @fileExtension  IS NULL 
			SET @fileExtension =  (SELECT fileExtension  FROM [DataIntegration].[FileImport] (NOLOCK) WHERE [fImportTargetID] = @ImportType)			
			IF @EOLCharacter  IS NULL 
			SET @EOLCharacter =  (SELECT EOLCharacter  FROM [DataIntegration].[FileImport] (NOLOCK) WHERE [fImportTargetID] = @ImportType)		
			IF @FirstRow  IS NULL
			SET @FirstRow = (SELECT FirstRow  FROM [DataIntegration].[FileImport] (NOLOCK) WHERE [fImportTargetID] = @ImportType)			
			IF @LastRow  IS NULL
			SET @LastRow = (SELECT LastRow  FROM [DataIntegration].[FileImport] (NOLOCK) WHERE [fImportTargetID] = @ImportType)
			IF @AccountStart  IS NULL
			SET @AccountStart = (SELECT AccountStart  FROM [DataIntegration].[FileImport] (NOLOCK) WHERE [fImportTargetID] = @ImportType)							  
			IF @AccountLength  IS NULL
			SET @AccountLength = (SELECT AccountLength  FROM [DataIntegration].[FileImport] (NOLOCK) WHERE [fImportTargetID] = @ImportType)			
			IF @DateStart  IS NULL
			SET @DateStart = (SELECT DateStart  FROM [DataIntegration].[FileImport] (NOLOCK) WHERE [fImportTargetID] = @ImportType)
			IF @DateLength  IS NULL
			SET @DateLength = (SELECT DateLength  FROM [DataIntegration].[FileImport] (NOLOCK) WHERE [fImportTargetID] = @ImportType)
			IF @SheetName  IS NULL
			SET @SheetName = (SELECT SheetName  FROM [DataIntegration].[FileImport] (NOLOCK) WHERE [fImportTargetID] = @ImportType)
			IF @DateFormat  IS NULL
			SET @DateFormat = (SELECT DateFormat  FROM [DataIntegration].[FileImport] (NOLOCK) WHERE [fImportTargetID] = @ImportType)
			UPDATE [DataIntegration].[FileImport] 
			SET Sourcedirectory = @SourceDirectory,
			[filePrefix]= @filePrefix,
			[fileExtension]= @fileExtension,
			[EOLCharacter] =@EOLCharacter,
			[FirstRow] =@FirstRow,
			[LastRow] =@LastRow,
			[AccountStart] =@AccountStart,
			[AccountLength] =@AccountLength,
			[DateStart] =@DateStart,
			[DateLength] =@DateLength,
			[SheetName] =@SheetName,
			[DateFormat] =@DateFormat
			WHERE [fImportTargetID] = @ImportType 
		END

	ELSE		 
			 INSERT [DataIntegration].[FileImport] 

			  VALUES (@ImportType ,@SourceDirectory,@filePrefix,@fileExtension,@EOLCharacter,@FirstRow , @LastRow ,
@AccountStart ,@AccountLength ,@DateStart ,@DateLength,@SheetName,@DateFormat )  
	

END ;  

