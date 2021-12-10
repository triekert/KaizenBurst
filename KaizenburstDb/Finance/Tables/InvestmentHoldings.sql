CREATE TABLE [Finance].[InvestmentHoldings] (
    [DateOfRecord]      DATE            NOT NULL,
    [fAccountID]        NVARCHAR (10)   NOT NULL,
    [fInstrumentCodeID] NVARCHAR (20)   NOT NULL,
    [Quantity]          INT             NOT NULL,
    [ReferenceCurrency] NVARCHAR (10)   NOT NULL,
    [ReferenceUnitCost] DECIMAL (14, 4) NOT NULL,
    [ReferenceCost]     MONEY           NOT NULL,
    [CurrentCurrency]   NVARCHAR (50)   NOT NULL,
    [CurrentUnitCost]   DECIMAL (14, 4) NOT NULL,
    [CurrentValue]      MONEY           NOT NULL,
    [ExchangeRate]      NVARCHAR (50)   NOT NULL,
    CONSTRAINT [PK_InvestmentHolding] PRIMARY KEY CLUSTERED ([DateOfRecord] ASC, [fAccountID] ASC, [fInstrumentCodeID] ASC)
);

