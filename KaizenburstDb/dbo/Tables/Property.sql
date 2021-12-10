CREATE TABLE [dbo].[Property] (
    [kPropertyID] UNIQUEIDENTIFIER NOT NULL,
    [ErfNumber]   NVARCHAR (10)    NULL,
    [DateStart]   DATE             NULL,
    [DateEnd]     DATE             NULL,
    [fPartyID]    UNIQUEIDENTIFIER NULL
);

