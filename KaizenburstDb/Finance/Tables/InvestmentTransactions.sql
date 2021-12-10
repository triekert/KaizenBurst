CREATE TABLE [Finance].[InvestmentTransactions] (
    [DateOfTransaction]            DATE            NOT NULL,
    [fInstrumentID]                NVARCHAR (20)   NOT NULL,
    [fInvestmentTransactionTypeID] NVARCHAR (20)   NOT NULL,
    [fAccountID]                   NVARCHAR (10)   NOT NULL,
    [Description]                  NVARCHAR (255)  NULL,
    [Quantity]                     DECIMAL (10, 3) NULL,
    [Total]                        MONEY           NULL,
    [Price]                        MONEY           NULL,
    [fCtrInstrumentID]             NVARCHAR (20)   NULL,
    [Cost]                         MONEY           NULL,
    CONSTRAINT [PK_InvestmentTransactions] PRIMARY KEY CLUSTERED ([DateOfTransaction] ASC, [fInstrumentID] ASC, [fInvestmentTransactionTypeID] ASC, [fAccountID] ASC)
);

