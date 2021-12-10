CREATE TABLE [dbo].[MeterReadingsRoughJuly20] (
    [Erf_No]                NVARCHAR (50) NULL,
    [Meter_Number]          NVARCHAR (50) NULL,
    [Owners_Name]           NVARCHAR (50) NOT NULL,
    [Last_weeks_Reading]    INT           NULL,
    [Current_Weeks_Reading] INT           NULL,
    [Units_Used]            TINYINT       NOT NULL,
    [Area__YELLOW]          NVARCHAR (1)  NULL
);

