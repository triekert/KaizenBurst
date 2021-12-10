CREATE TABLE [dbo].[MeterReadingsRoughJune22] (
    [Erf_No]                NVARCHAR (50) NULL,
    [Meter_Number]          NVARCHAR (50) NULL,
    [Owners_Name]           NVARCHAR (50) NOT NULL,
    [Last_Months_Reading]   INT           NULL,
    [Current_Month_Reading] INT           NULL,
    [Units_Used]            TINYINT       NULL,
    [Area__YELLOW]          NVARCHAR (50) NULL
);

