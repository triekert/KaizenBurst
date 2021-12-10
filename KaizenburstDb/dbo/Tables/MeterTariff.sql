CREATE TABLE [dbo].[MeterTariff] (
    [DateStart]      DATETIME     NOT NULL,
    [DateEnd]        DATETIME     NULL,
    [ThresholdLower] INT          NOT NULL,
    [ThresholdUpper] INT          NULL,
    [Units]          VARCHAR (20) NOT NULL,
    [Tariff]         MONEY        NULL,
    [TariffExcl]     MONEY        NULL,
    [ShortName]      VARCHAR (20) NULL,
    [MeterType]      VARCHAR (1)  NOT NULL
);

