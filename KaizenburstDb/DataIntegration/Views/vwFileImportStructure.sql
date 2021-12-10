






CREATE VIEW [DataIntegration].[vwFileImportStructure]
AS
SELECT        *
FROM            [DataIntegration].[FileImport]fi (NOLOCK)
				 LEFT OUTER JOIN [DataIntegration].[ImportTypes] it (NOLOCK)
				 ON [fImportTargetID] =[kImportTargetID]





