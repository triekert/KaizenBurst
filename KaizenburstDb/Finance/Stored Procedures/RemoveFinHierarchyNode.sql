Create PROC [Finance].[RemoveFinHierarchyNode](@Node hierarchyID)   
AS   
BEGIN  
   DECLARE  @lc hierarchyid  

   --SET TRANSACTION ISOLATION LEVEL SERIALIZABLE  
   --BEGIN TRANSACTION  
   --   SELECT @lc = max(FinHierarchyID)   
   --   FROM [Finance].[FinancialHierarchy]   
   --   WHERE FinHierarchyID.GetAncestor(1) =@ParentCatNode ;  

   --   INSERT [Finance].[FinancialHierarchy]  ([FinHierarchyID], [ShortName], [Description],[Card])  
   --   VALUES (@ParentCatNode.GetDescendant(@lc, NULL), @ShortName, @description,@card)  
   --COMMIT  
   --WITH H AS
--(
--    -- Anchor: the first level of the hierarchy
--    SELECT id, parent_id, name, CAST(name AS NVARCHAR(300)) AS path 
--    FROM Test 
--    WHERE parent_id IS NULL      
--UNION ALL
--    -- Recursive: join the original table to the anchor, and combine data from both  
--    SELECT T.id, T.parent_id, T.name, CAST(H.path + '\' + T.name AS NVARCHAR(300)) 
--    FROM Test T INNER JOIN H ON T.parent_id = H.id
--)
---- You can query H as if it was a normal table or View
--SELECT * FROM H
--   WHERE PATH = 'L1\L1-A' -- for example to see if this exists

END ;  
