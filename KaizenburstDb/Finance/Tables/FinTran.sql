CREATE TABLE [Finance].[FinTran] (
    [Posted Date]      DATETIME         NULL,
    [Transaction Date] DATETIME         NULL,
    [Description]      VARCHAR (254)    NULL,
    [Debit]            MONEY            NULL,
    [Credit]           MONEY            NULL,
    [Balance]          MONEY            NULL,
    [fSpender]         INT              NULL,
    [isAllocated]      VARCHAR (1)      NULL,
    [Card Number]      VARCHAR (50)     NULL,
    [kFinTranID]       UNIQUEIDENTIFIER NOT NULL
);

