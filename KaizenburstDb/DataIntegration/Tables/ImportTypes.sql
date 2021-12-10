CREATE TABLE [DataIntegration].[ImportTypes] (
    [kImportTargetID] UNIQUEIDENTIFIER NOT NULL,
    [Name]            VARCHAR (100)    NULL,
    [Description]     VARCHAR (500)    NULL,
    [isSuspend]       VARCHAR (1)      NULL,
    [transitTable]    VARCHAR (50)     NULL
);

