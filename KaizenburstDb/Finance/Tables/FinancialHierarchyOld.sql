CREATE TABLE [Finance].[FinancialHierarchyOld] (
    [FinHierarchyID] [sys].[hierarchyid] NOT NULL,
    [ShortName]      VARCHAR (20)        NOT NULL,
    [Description]    VARCHAR (254)       NULL,
    [Card]           NVARCHAR (50)       NULL,
    [Frequency]      INT                 NULL,
    [kCategoryID]    UNIQUEIDENTIFIER    NOT NULL,
    [fIconID]        UNIQUEIDENTIFIER    NULL
);

