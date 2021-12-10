CREATE TABLE [dbo].[FinActualOld] (
    [kFinActualID]    BIGINT              NOT NULL,
    [fFinTranID]      BIGINT              NULL,
    [Month]           INT                 NULL,
    [fCatHierarchyID] [sys].[hierarchyid] NULL,
    [fVersionID]      INT                 NULL,
    [ActualAmount]    MONEY               NULL
);

