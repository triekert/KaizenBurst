CREATE TABLE [Finance].[InvestementCategory] (
    [kInvestmentCategoryID] NVARCHAR (50)  NOT NULL,
    [Description]           NVARCHAR (100) NULL,
    CONSTRAINT [kInvestmentCategoryID] PRIMARY KEY CLUSTERED ([kInvestmentCategoryID] ASC)
);

