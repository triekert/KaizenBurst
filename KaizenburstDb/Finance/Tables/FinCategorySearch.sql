CREATE TABLE [Finance].[FinCategorySearch] (
    [DescrLookup]    VARCHAR (254)    NULL,
    [Proportion]     INT              NULL,
    [Card]           NVARCHAR (50)    NULL,
    [MonthSpecific]  BIT              NULL,
    [NonRepetitive]  BIT              NULL,
    [kCatSrchId]     UNIQUEIDENTIFIER NULL,
    [fFinCategoryID] UNIQUEIDENTIFIER NULL
);

