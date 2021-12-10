CREATE TABLE [dbo].[MeterReading] (
    [fDateMeteringID] UNIQUEIDENTIFIER NOT NULL,
    [MeterReading]    INT              NOT NULL,
    [fMeterID]        UNIQUEIDENTIFIER NULL,
    [fSourceID]       UNIQUEIDENTIFIER NULL
);

