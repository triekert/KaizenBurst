CREATE TABLE [Finance].[FinActualDetTemplate] (
    [kFinActDetailTemplID] BIGINT          NOT NULL,
    [fFinActualID]         BIGINT          NULL,
    [Description]          VARCHAR (254)   NULL,
    [ShortName]            VARCHAR (20)    NULL,
    [AmountPaid]           MONEY           NULL,
    [DocImage]             IMAGE           NULL,
    [AmountDue]            MONEY           NULL,
    [AmountAllowed]        MONEY           NULL,
    [Qty]                  DECIMAL (10, 4) NULL,
    [Month]                SMALLINT        NULL,
    [CalcProc]             VARCHAR (254)   NULL,
    [fCategoryID]          BIGINT          NULL
);

