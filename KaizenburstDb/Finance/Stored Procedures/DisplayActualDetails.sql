CREATE PROC[Finance].[DisplayActualDetails](@monthbeg int,@monthend int = NULL,@parent varchar(20) = NULL) AS
BEGIN  
DECLARE @ParentHierID hierarchyID 
IF @monthend IS NULL
BEGIN
SET @monthend = @monthbeg
END
	--CASE   WHEN NOT @parent IS NULL
	--THEN
	--DECLARE @monthbeg int =201801,@monthend int = 201801,@parent varchar(20) = 'root'
	IF NOT @parent IS NULL
	BEGIN
		SET @ParentHierID = (SELECT finHierarchyID from[Finance].[FinancialHierarchy] (nolock) fc WHERE ShortName = @Parent)
		select month,fc.Parent,Shortname,ft.[Posted Date],ft.description,ft.Debit,ft.credit,ft.kFinTranID,ft.[Card Number],fa.ActualAmount,kFinActualID,
		(SELECT count(*) from[Finance].[FinActualDetail] where fa.kFinActualID = [fFinActualID]) as Breakdown
		from FinActual (nolock) fa
		INNER JOIN 
			(SELECT cc.finHierarchyID,cc.kCategoryID,cc.finHierarchyID.GetLevel() as H_Level,pc.finhierarchyID.GetLevel() as ParentLevel,cc.ShortName,pc.Shortname as Parent 
			FROM [Finance].FinancialHierarchy (nolock) pc 
			INNER JOIN [Finance].FinancialHierarchy (nolock) cc 
			ON cc.finHierarchyID.IsDescendantOf(pc.finHierarchyID) = 1) as fc
		ON fa.[fCategoryID] = fc.[kCategoryID]
		INNER JOIN FinTran ft(nolock)
		on fa.[fFinTranID] = ft.[kFinTranID]
		WHERE month between @monthbeg and @monthend
		AND Parent = @parent
		ORDER BY month,ParentLevel,fc.Parent,fc.shortName,ft.[Card Number],ft.[Posted Date] 
	--GROUP BY month,ParentLevel,fc.Parent
		select month,fc.Parent,SUM(coalesce(Credit,0)) as Cr,SUM(coalesce(Debit,0)) as Db,SUM(coalesce(Credit,0)-coalesce(Debit,0)) as Nett--,ft.description,ft.Debit,ft.credit,ft.kFinTranID,ft.[Card Number] 
		from FinActual (nolock) fa
		INNER JOIN 
			(SELECT DISTINCT cc.finHierarchyID,cc.kCategoryID,cc.finHierarchyID.GetLevel() as H_Level,pc.finhierarchyID.GetLevel() as ParentLevel,cc.ShortName,pc.Shortname as Parent 
			FROM [Finance].FinancialHierarchy (nolock) pc 
			INNER JOIN [Finance].FinancialHierarchy (nolock) cc 
			ON cc.finHierarchyID.IsDescendantOf(pc.finHierarchyID) = 1) as fc
		ON fa.[fCategoryID] = fc.[kCategoryID]
		INNER JOIN FinTran ft(nolock)
		on fa.[fFinTranID] = ft.[kFinTranID]
		WHERE month between @monthbeg and @monthend
		AND Parent = @parent
		GROUP BY month,fc.Parent
	--DECLARE @monthbeg int =201805,@monthend int = 201805,@parent varchar(20) = 'root'
	select month,Shortname,parent,gparent,ggparent,level,SUM(actualamount) as Nett--,ft.description,ft.Debit,ft.credit,ft.kFinTranID,ft.[Card Number] 

	FROM
	(
	select 
	distinct 
	fa.month,fh1.ShortName,fa.kFinActualID,fa.ActualAmount,ft.description,fp.shortname parent,fgp.ShortName gparent,fggp.ShortName ggparent,fh1.FinHierarchyID.GetLevel() level from 
	FinancialHierarchy fh
	INNER JOIN FinancialHierarchy fh1
	on fh.FinHierarchyID.IsDescendantOf(fh1.FinHierarchyID) = 1
	INNER JOIN FinancialHierarchy fhh
	on fh1.FinHierarchyID.IsDescendantOf(fhh.FinHierarchyID) = 1
	LEFT OUTER JOIN[Finance].[FinancialHierarchy] (nolock) fp
	on fp.FinHierarchyID = fh1.FinHierarchyID.GetAncestor(1)
	LEFT OUTER JOIN[Finance].[FinancialHierarchy] (nolock) fgp
	on fgp.FinHierarchyID = fh1.FinHierarchyID.GetAncestor(2)
	LEFT OUTER JOIN[Finance].[FinancialHierarchy] (nolock) fggp
	on fggp.FinHierarchyID = fh1.FinHierarchyID.GetAncestor(3)	
	INNER JOIN 
	FinActual fa 
	on fa.fCategoryID =fh.kCategoryID

	INNER JOIN FinTran ft
	on fa.fFinTranID =ft.kFinTranID
	WHERE fa.month between @monthbeg and @monthend
	and fhh.shortname = @parent
	--order by level,fh1.ShortName
	) as t
	GROUP BY month,Shortname,parent,gparent,ggparent,level
	order by month,level,ShortName

--order by level,ShortName
--		select month,fc.Parent,ft.[Card Number] ,Shortname,SUM(coalesce(Credit,0)) as Cr,SUM(coalesce(Debit,0)) as Db,SUM(coalesce(Credit,0)-coalesce(Debit,0)) as Nett--,ft.description,ft.Debit,ft.credit,ft.kFinTranID,ft.[Card Number] 
--		from FinActual (nolock) fa
--		INNER JOIN 
--			(SELECT distinct cc.finHierarchyID,cc.kCategoryID,cc.finHierarchyID.GetLevel() as H_Level,pc.finhierarchyID.GetLevel() as ParentLevel,cc.ShortName,pc.Shortname as Parent 
--			FROM [Finance].FinancialHierarchy (nolock) pc 
--			INNER JOIN [Finance].FinancialHierarchy (nolock) cc 
--			ON cc.finHierarchyID.IsDescendantOf(pc.finHierarchyID) = 1
--		LEFT OUTER JOIN[Finance].[FinancialHierarchy] (nolock) fp
--		on fp.FinHierarchyID = fc.FinHierarchyID.GetAncestor(1)
--		LEFT OUTER JOIN[Finance].[FinancialHierarchy] (nolock) fgp
--		on fgp.FinHierarchyID = fc.FinHierarchyID.GetAncestor(2)
--		LEFT OUTER JOIN[Finance].[FinancialHierarchy] (nolock) fggp
--		on fggp.FinHierarchyID = fc.FinHierarchyID.GetAncestor(3)			
--			) as fc
--		ON fa.[fCategoryID] = fc.[kCategoryID]
--		INNER JOIN FinTran ft(nolock)
--		on fa.[fFinTranID] = ft.[kFinTranID]
--		WHERE month  between @monthbeg and @monthend
--		AND Parent = @parent
--		GROUP BY month,fc.Parent,Shortname,ft.[Card Number]
--		ORDER BY month,fc.Parent,Shortname,ft.[Card Number]

	--DECLARE @monthbeg	int =201801,@monthend int =201805,@ParentHierID hierarchyID =0x		
	select month,ShortName,Parent,GParent,ggParent,KCategoryID,SUM(coalesce(Credit,0)-coalesce(Debit,0)) as Actual--,ft.description,ft.Debit,ft.credit,ft.kFinTranID,ft.[Card Number] 
	FROM

		(
		SELECT DISTINCT month,fc.FinHierarchyID,fc.ShortName,fp.ShortName Parent,fgp.ShortName GParent,fggp.ShortName GGParent,fc.KCategoryID,Credit,Debit
		from FinActual (nolock) fa

		INNER JOIN FinTran ft(nolock)
		on fa.[fFinTranID] = ft.[kFinTranID]
		INNER JOIN[Finance].[FinancialHierarchy] (nolock) fc
		on fa.fCategoryID = fc.kCategoryID
		AND fc.FinHierarchyID.IsDescendantOf(@ParentHierID) = 1
		LEFT OUTER JOIN[Finance].[FinancialHierarchy] (nolock) fp
		on fp.FinHierarchyID = fc.FinHierarchyID.GetAncestor(1)
		LEFT OUTER JOIN[Finance].[FinancialHierarchy] (nolock) fgp
		on fgp.FinHierarchyID = fc.FinHierarchyID.GetAncestor(2)
		LEFT OUTER JOIN[Finance].[FinancialHierarchy] (nolock) fggp
		on fggp.FinHierarchyID = fc.FinHierarchyID.GetAncestor(3)
		WHERE month between @monthbeg and @monthend) as act

		GROUP BY month,ShortName,Parent,GParent,ggParent,kCategoryID,FinHierarchyID
ORDER BY Month,FinHierarchyID.GetLevel(),ShortName




	END
	ELSE
	BEGIN
		select month,ParentLevel,fc.Parent,SUM(ActualAmount) from FinActual (nolock) fa
		INNER JOIN 
	(SELECT cc.finHierarchyID,cc.kCategoryID,cc.finHierarchyID.GetLevel() as H_Level,pc.finhierarchyID.GetLevel() as ParentLevel,cc.ShortName,pc.Shortname as Parent 
			FROM [Finance].FinancialHierarchy (nolock) pc 
			INNER JOIN [Finance].FinancialHierarchy (nolock) cc 
			ON cc.finHierarchyID.IsDescendantOf(pc.finHierarchyID) = 1) as fc
		ON fa.[fCategoryID] = fc.[kCategoryID]
		INNER JOIN FinTran ft(nolock)
		on fa.[fFinTranID] = ft.[kFinTranID]
		--WHERE month = @month
		GROUP BY month,ParentLevel,fc.Parent
				ORDER BY month,ParentLevel,fc.Parent
	END

END ;  

