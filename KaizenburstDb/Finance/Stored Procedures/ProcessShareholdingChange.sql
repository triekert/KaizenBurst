CREATE PROC [Finance].[ProcessShareholdingChange] ( @Account nvarchar(10) ,@fAspNetUserID nvarchar(20),@DateOfTransaction date,@Amount money,@Description nvarchar(100)) AS

/*
Stored proc ProcessShareholding Change
This procedure is used for managing shareholder contributions to a specified portfolio
The monetary contribution is converted to a portion of the portfolio as at a particular date
Any payments made to a shareholder are in turn converted to cash at the date of transaction and the portion of the portfolio attributed to the 
shareholder is similarly reduced.

Created : 2021

*/
BEGIN 

	BEGIN TRY
	
		INSERT INTO [Finance].[InvestmentAccountShareholderTransactions] VALUES(@Account,@fAspNetUserID,@DateOfTransaction,@Amount,@Description)
			
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
			'Shareholding')

			RETURN 1
	---- Transaction uncommittable
	--	IF (XACT_STATE()) = -1
	--	  ROLLBACK TRANSACTION
 
	---- Transaction committable
	--	IF (XACT_STATE()) = 1
	--	  COMMIT TRANSACTION
	END CATCH 	
	RETURN 0
END
