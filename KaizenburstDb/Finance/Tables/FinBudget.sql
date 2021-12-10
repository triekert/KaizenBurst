CREATE TABLE [Finance].[FinBudget] (
    [MonthStart]  INT              NOT NULL,
    [MonthEnd]    INT              NOT NULL,
    [fVersionID]  INT              NULL,
    [BudgetType]  INT              NULL,
    [Description] NVARCHAR (254)   NULL,
    [Name]        NVARCHAR (50)    NULL,
    [kBudgetID]   UNIQUEIDENTIFIER NOT NULL,
    [fKeyVID]     UNIQUEIDENTIFIER NULL
);

