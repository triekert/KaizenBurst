
CREATE Proc [DataIntegration].[spManageImportType](@Name varchar(100), @OldName varchar(100) NULL, @description varchar(500) = NULL,@isSuspend varchar(1) ,@transitTable varchar(50) )  



/* Stored procedure:spAddImportType

Used for adding an ImportType

Parameters: 

@Name  - Name of Import Type
@Description - Longer description of new import type if required
@isSuspend - 's' if suspended, 'a' if active
@transitTable  - Table on DataIntegration schema into which data should be imported

Created : 2020/12/5 by TRiekert

*/

AS   
BEGIN  
/*
DECLARE @Name varchar(100), @OldName varchar(100) , @description varchar(500) ,@isSuspend varchar(1) ,@transitTable varchar(50)


		SET @Name = N'ABSATransactions'
		SET @OldName = NULL
		SET @description = NULL
		SET @isSuspend = N'a'
		SET @transitTable = N'TransactionsAbsa'
--*/
--select 'start'
--SELECT  @OldName
IF NOT @OldName  IS NULL 
BEGIN
--select 'Old name passed'
--If name alrady exists
	IF (SELECT COUNT(*) FROM [DataIntegration].[ImportTypes] (NOLOCK)
	WHERE Name = @OldName  
	) = 1
	BEGIN
	SELECT 'got here'
		 IF @description IS NULL 
		 SET @description = (SELECT description  FROM [DataIntegration].[ImportTypes] (NOLOCK) WHERE Name = @OldName) 
		 IF @transitTable IS NULL 
		 SET @transitTable = (SELECT transitTable  FROM [DataIntegration].[ImportTypes] (NOLOCK) WHERE Name = @OldName) 		 
		  
			  UPDATE [DataIntegration].[ImportTypes] 
			  SET Name = @Name,
			  Description = @description,
			  isSuspend = @isSuspend,
			  [transitTable]= @transitTable

			  WHERE Name = @OldName  
	END
END
ELSE 
--If name alrady exists
--select 'existing or new name'
	IF (SELECT COUNT(*) FROM [DataIntegration].[ImportTypes] (NOLOCK)
	WHERE Name = @Name  
	--'SN 180742756'
	) = 1
		BEGIN
		--SELECT 'got here'
			IF @description IS NULL 
			SET @description = (SELECT description  FROM [DataIntegration].[ImportTypes] (NOLOCK) WHERE Name = @Name) 
			--SELECT  @transitTable
			IF @transitTable IS NULL 
			SET @transitTable = (SELECT transitTable  FROM [DataIntegration].[ImportTypes] (NOLOCK) WHERE Name = @Name) 
			UPDATE [DataIntegration].[ImportTypes] 
			SET Name = @Name,
			Description = @description,
			isSuspend = @isSuspend,
			[transitTable]= @transitTable
			WHERE Name = @Name  
		END
	ELSE		 
			 INSERT [DataIntegration].[ImportTypes] 
			  VALUES (NEWID(),@Name,  @description,@isSuspend,@transitTable)  
			  -- NEWID() returns a unique identifier


END ;  
