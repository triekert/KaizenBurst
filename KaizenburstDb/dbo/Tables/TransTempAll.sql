CREATE TABLE [dbo].[TransTempAll] (
    [Transaction Date] DATE          NOT NULL,
    [Posting Date]     DATE          NOT NULL,
    [Description]      NVARCHAR (50) NOT NULL,
    [Debits]           FLOAT (53)    NULL,
    [Credits]          FLOAT (53)    NULL,
    [Balance]          FLOAT (53)    NOT NULL,
    [column7]          NVARCHAR (1)  NULL
);

