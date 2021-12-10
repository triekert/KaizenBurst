CREATE TABLE [dbo].[TransTempCard] (
    [Transaction Date] DATE          NOT NULL,
    [Posting Date]     DATE          NOT NULL,
    [Description]      NVARCHAR (50) NOT NULL,
    [column4]          NVARCHAR (1)  NULL,
    [Card Number]      NVARCHAR (50) NOT NULL,
    [Debit]            FLOAT (53)    NOT NULL,
    [column7]          NVARCHAR (1)  NULL,
    [Balance]          FLOAT (53)    NOT NULL,
    [column9]          NVARCHAR (1)  NULL
);

