CREATE TABLE [dbo].[ProjectHierarchy] (
    [ProjHierarchyID] [sys].[hierarchyid] NOT NULL,
    [kProjectID]      INT                 NOT NULL,
    [ShortName]       VARCHAR (20)        NOT NULL,
    [Description]     VARCHAR (254)       NULL,
    [ProjectInit]     DATETIME            NULL
);

