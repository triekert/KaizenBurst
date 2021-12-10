CREATE TABLE [DataIntegration].[FileImport] (
    [fImportTargetID] UNIQUEIDENTIFIER NOT NULL,
    [SourceDirectory] VARCHAR (100)    NULL,
    [filePrefix]      VARCHAR (100)    NULL,
    [fileExtension]   VARCHAR (10)     NULL,
    [EOLCharacter]    NVARCHAR (10)    NULL,
    [Firstrow]        INT              NULL,
    [Lastrow]         INT              NULL,
    [AccountStart]    INT              NULL,
    [AccountLength]   INT              NULL,
    [DateStart]       INT              NULL,
    [DateLength]      INT              NULL,
    [SheetName]       NVARCHAR (50)    NULL,
    [DateFormat]      NCHAR (20)       NULL,
    [FieldCharacter]  NVARCHAR (10)    NULL
);

