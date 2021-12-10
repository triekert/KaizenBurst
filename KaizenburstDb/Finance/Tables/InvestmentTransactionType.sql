CREATE TABLE [Finance].[InvestmentTransactionType] (
    [kInvestmentTransactionTypeID] NVARCHAR (20)  NOT NULL,
    [Description]                  NVARCHAR (100) NULL,
    CONSTRAINT [kInvestmentTransactionTypeID] PRIMARY KEY CLUSTERED ([kInvestmentTransactionTypeID] ASC)
);

