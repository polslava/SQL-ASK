SELECT
	dtt.ID,
	dtt.WaysheetRouteId,
	/*DumptruckId,*/ o.Name as DumpTruck,
	dtt.BeginTime,
	dtt.EndTime,
	/*CargoId,*/  c.Name as Cargo,
	/*dtt.WorkId,*/ w.Name as WorkName,
	/*dtt.WorkerId,*/ w1.ShortName as Driver
	/*,
	dtt.attributes,
	dtt.Received,
	dtt.main_attributes*/
FROM
	Navigation.dbo.Mn_DumptruckTasks dtt
	left join Objects o on o.id = dtt.DumptruckId
	left join NavCargos c on c.id = dtt.CargoId
	left join NavWorks w on w.id = dtt.WorkId
	left join workers w1 on w1.id = dtt.WorkerId
	;