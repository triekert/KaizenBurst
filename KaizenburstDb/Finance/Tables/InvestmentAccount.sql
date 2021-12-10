CREATE TABLE [Finance].[InvestmentAccount] (
    [kAccountID]    NVARCHAR (10)  NOT NULL,
    [Description]   NVARCHAR (100) NULL,
    [Institution]   NVARCHAR (50)  NULL,
    [fASPNetUserID] NVARCHAR (254) NULL,
    CONSTRAINT [kAccountID] PRIMARY KEY CLUSTERED ([kAccountID] ASC)
);

