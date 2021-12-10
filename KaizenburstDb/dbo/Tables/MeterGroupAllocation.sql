CREATE TABLE [dbo].[MeterGroupAllocation] (
    [fMeterGroupID] UNIQUEIDENTIFIER NOT NULL,
    [fMeterID]      UNIQUEIDENTIFIER NOT NULL,
    [DateStart]     DATE             NOT NULL,
    [DateEnd]       DATE             NULL
);

