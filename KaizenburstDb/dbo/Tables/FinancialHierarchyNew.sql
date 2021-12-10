CREATE TABLE [dbo].[FinancialHierarchyNew] (
    [FinHierarchyID] [sys].[hierarchyid] NOT NULL,
    [kCategoryID]    INT                 NOT NULL,
    [ShortName]      VARCHAR (20)        NOT NULL,
    [Description]    VARCHAR (254)       NULL,
    [Card]           NVARCHAR (50)       NULL,
    [Frequency]      INT                 NULL,
    [kKeyID]         UNIQUEIDENTIFIER    NOT NULL
);

