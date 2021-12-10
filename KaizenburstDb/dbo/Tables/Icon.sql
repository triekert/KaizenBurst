CREATE TABLE [dbo].[Icon] (
    [kIconID]      UNIQUEIDENTIFIER NOT NULL,
    [Name]         VARCHAR (50)     NULL,
    [Description]  VARCHAR (250)    NULL,
    [Image]        IMAGE            NULL,
    [ResourcePath] VARCHAR (250)    NULL
);

