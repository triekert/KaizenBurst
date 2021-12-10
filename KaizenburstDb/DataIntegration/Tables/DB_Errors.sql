CREATE TABLE [DataIntegration].[DB_Errors] (
    [ErrorID]        INT           IDENTITY (1, 1) NOT NULL,
    [UserName]       VARCHAR (100) NULL,
    [ErrorNumber]    INT           NULL,
    [ErrorState]     INT           NULL,
    [ErrorSeverity]  INT           NULL,
    [ErrorLine]      INT           NULL,
    [ErrorProcedure] VARCHAR (MAX) NULL,
    [ErrorMessage]   VARCHAR (MAX) NULL,
    [ErrorDateTime]  DATETIME      NULL,
    [ProcedureName]  VARCHAR (100) NULL,
    [VerboseMessage] VARCHAR (MAX) NULL
);

