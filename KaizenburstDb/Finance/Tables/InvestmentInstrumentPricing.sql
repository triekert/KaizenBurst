CREATE TABLE [Finance].[InvestmentInstrumentPricing] (
    [DateOfRecord]      DATE            NOT NULL,
    [fInstrumentCodeID] NVARCHAR (20)   NOT NULL,
    [CurrentCurrency]   NVARCHAR (50)   NOT NULL,
    [CurrentUnitCost]   DECIMAL (14, 4) NOT NULL,
    [ExchangeRate]      DECIMAL (14, 4) NULL,
    CONSTRAINT [PK_InstrumentPricing] PRIMARY KEY CLUSTERED ([DateOfRecord] ASC, [fInstrumentCodeID] ASC)
);

