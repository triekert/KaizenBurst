CREATE PROC [Finance].[AddFinHierarchyNode](@Parent varchar(20),  @ShortName varchar(20), @description varchar(254) = NULL,@Card nvarchar(50) = NULL)  



/* Stored procedure:AddFinHierarchyNode

Used for adding a node to the Financial Hierarchy. 

Parameters: 
@Parent - Short Name of the node below which this new node will be added
@ShortName  - Short Name of new node, must be unique
@Description - Longer description of new node if required
@Card - Credit card number if the categorisation of the transaction is affected by the actual entity initiating the transaction

Created : 2018
Modified: 26/12/2018 by TRiekert
*/

AS   
BEGIN  
   DECLARE  @lc hierarchyid  ,@ParentCatNode hierarchyid
SET @parentCatNode = (SELECT FinHierarchyID from [Finance].[FinancialHierarchy] f where f.ShortName = @parent)
IF NOT @parentCatNode IS NULL
	BEGIN
	--Logic for ignoring credit card number if same number is already used higher up in the hierarchy
	 IF NOT @card IS NULL AND EXISTS (SELECT (1) FROM [Finance].[fnTblFinHierarch]() fh
		--Function checks to see if card number already used higher up in the hierarchy.
		WHERE fh.Card =@card
		AND fh.Parent = @parent) 
		SET @card = NULL

	   SET TRANSACTION ISOLATION LEVEL SERIALIZABLE  
	   BEGIN TRANSACTION  
		  SELECT @lc = max(FinHierarchyID)   
		  --find location in the current hierarchy
		  FROM [Finance].[FinancialHierarchy]   
		  WHERE FinHierarchyID.GetAncestor(1) =@ParentCatNode ;  

		  INSERT [Finance].[FinancialHierarchy]  ([FinHierarchyID], [ShortName], [Description],[Card],[kCategoryID])  
		  VALUES (@ParentCatNode.GetDescendant(@lc, NULL), @ShortName, @description,@card,NEWID())  
		  -- NEWID() returns a unique identifier
	   COMMIT 
   END 
END ;  
