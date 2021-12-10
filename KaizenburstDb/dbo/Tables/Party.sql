CREATE TABLE [dbo].[Party] (
    [kPartyID] UNIQUEIDENTIFIER NOT NULL,
    [Name]     NCHAR (50)       NULL,
    [Email]    NCHAR (50)       NULL,
    [Voice]    SMALLINT         NULL,
    [IsPerson] BIT              NULL
);

