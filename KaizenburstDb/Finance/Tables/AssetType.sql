CREATE TABLE [Finance].[AssetType] (
    [kAssetTypeID] NVARCHAR (10)  NOT NULL,
    [Description]  NVARCHAR (100) NULL,
    CONSTRAINT [PK_kAssetTypeID] PRIMARY KEY CLUSTERED ([kAssetTypeID] ASC)
);

