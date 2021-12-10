CREATE TABLE [Finance].[FinVersion] (
    [kVersionID]   INT              NOT NULL,
    [Version]      NCHAR (20)       NULL,
    [DateApproved] DATETIME         NULL,
    [Current]      NCHAR (1)        NULL,
    [kKeyId]       UNIQUEIDENTIFIER NULL
);

