CREATE TABLE [Finance].[FinActual] (
    [Month]         INT              NULL,
    [ActualAmount]  MONEY            NULL,
    [Frequency]     INT              NULL,
    [MonthSpecific] BIT              NULL,
    [kFinActualID]  UNIQUEIDENTIFIER NOT NULL,
    [fFinTranID]    UNIQUEIDENTIFIER NULL,
    [fCategoryID]   UNIQUEIDENTIFIER NULL,
    [fVersionVID]   UNIQUEIDENTIFIER NULL,
    [fProjectID]    UNIQUEIDENTIFIER NULL
);

