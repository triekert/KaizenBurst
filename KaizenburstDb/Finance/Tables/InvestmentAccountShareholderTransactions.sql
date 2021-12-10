CREATE TABLE [Finance].[InvestmentAccountShareholderTransactions] (
    [fAccountID]        NVARCHAR (10)  NOT NULL,
    [fASPNetUserID]     NVARCHAR (254) NOT NULL,
    [DateOfTransaction] DATE           NOT NULL,
    [Amount]            MONEY          NOT NULL,
    [Description]       NVARCHAR (100) NULL,
    CONSTRAINT [PK_InvestmentAccountShareholderTransactions] PRIMARY KEY CLUSTERED ([fAccountID] ASC, [fASPNetUserID] ASC, [DateOfTransaction] ASC)
);

