CREATE TABLE [dbo].[ImagesStore] (
    [ImageId]      INT              NOT NULL,
    [OriginalPath] VARCHAR (200)    NOT NULL,
    [ImageData]    IMAGE            NOT NULL,
    [kKeyID]       UNIQUEIDENTIFIER NULL
);

