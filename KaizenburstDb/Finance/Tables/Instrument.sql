CREATE TABLE [Finance].[Instrument] (
    [kInstrumentCodeID]     NVARCHAR (20)  NOT NULL,
    [kAlternateCodeID]      NVARCHAR (20)  NULL,
    [Description]           NVARCHAR (100) NULL,
    [fInvestmentCategoryID] NVARCHAR (50)  NULL,
    [fAssetTypeID]          NVARCHAR (50)  NULL,
    [fSectorID]             NVARCHAR (50)  NULL,
    [k2ndAlternateID]       NVARCHAR (20)  NULL,
    CONSTRAINT [kInstrumentCodeID1] PRIMARY KEY CLUSTERED ([kInstrumentCodeID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_Instrument]
    ON [Finance].[Instrument]([kInstrumentCodeID] ASC);

