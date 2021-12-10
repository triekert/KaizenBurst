CREATE TABLE [Finance].[FinActualDetail] (
    [Description]        VARCHAR (254)    NULL,
    [ShortName]          VARCHAR (20)     NULL,
    [AmountPaid]         MONEY            NULL,
    [DocImage]           IMAGE            NULL,
    [AmountInvoiced]     MONEY            NULL,
    [AmountAllowed]      MONEY            NULL,
    [Qty]                DECIMAL (10, 4)  NULL,
    [Month]              SMALLINT         NULL,
    [AmountAllowedExcl]  MONEY            NULL,
    [kFinActualDetailID] UNIQUEIDENTIFIER NULL,
    [fFinActualID]       UNIQUEIDENTIFIER NULL
);

