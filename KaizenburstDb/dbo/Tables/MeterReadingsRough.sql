CREATE TABLE [dbo].[MeterReadingsRough] (
    [Erf_No]                  NVARCHAR (50) NULL,
    [Meter_Number]            NVARCHAR (50) NULL,
    [Owners_Name]             NVARCHAR (50) NOT NULL,
    [Date_of_Last_Reading]    INT           NULL,
    [Date_of_Current_Reading] INT           NULL,
    [Units_Used]              SMALLINT      NOT NULL,
    [Area__YELLOW]            NVARCHAR (50) NULL
);

