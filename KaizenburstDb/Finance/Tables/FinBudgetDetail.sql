CREATE TABLE [Finance].[FinBudgetDetail] (
    [Month]        INT              NOT NULL,
    [BudgetAmount] MONEY            NOT NULL,
    [ActualAmount] MONEY            NULL,
    [fCategoryID]  UNIQUEIDENTIFIER NULL,
    [fVersionID]   UNIQUEIDENTIFIER NULL,
    [fProjectID]   UNIQUEIDENTIFIER NULL,
    [fBudgetID]    UNIQUEIDENTIFIER NOT NULL
);

