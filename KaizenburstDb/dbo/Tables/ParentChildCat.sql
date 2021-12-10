CREATE TABLE [dbo].[ParentChildCat] (
    [CatNode]           [sys].[hierarchyid] NOT NULL,
    [kCategoryID]       INT                 NULL,
    [ShortName]         VARCHAR (20)        NULL,
    [fParentCategoryID] INT                 NULL,
    [H_Level]           SMALLINT            NULL,
    [Description]       VARCHAR (254)       NULL,
    [Card]              NVARCHAR (50)       NULL
);

