SELECT
	dtt.ID, dtt.WaysheetRouteId,
	o.Name as DumpTruck, dtt.BeginTime As BeginTime_DumpTruck, dtt.EndTime as EndTime_DumpTruck, c.Name as Cargo, w.Name as WorkName, w1.ShortName as Driver_DumpTruck
	
	,wsr.Name as Name_Areas, wsr.WorkDate, wsr.SM, wsr.BeginTime as BeginTime_Shovel,wsr.EndTime as EndTime_Shovel, wsr.Shovel,wsr.ShovelDriver,wsr.LoadZone,wsr.UnloadZone,wsr.ShovelSubDriver,wsr.Closed,wsr.Received
FROM
	Navigation.dbo.Mn_DumptruckTasks dtt
	left join Objects o on o.id = dtt.DumptruckId
	left join NavCargos c on c.id = dtt.CargoId
	left join NavWorks w on w.id = dtt.WorkId
	left join workers w1 on w1.id = dtt.WorkerId
	left join 	
(SELECT
	wr.ID, ma.Name, wr.WorkDate, wr.SM, wr.BeginTime, wr.EndTime, o.Name as Shovel, w.Shortname as ShovelDriver,
	mr.LoadZone, mr.UnloadZone, w1.Shortname as ShovelSubDriver, wr.Closed, wr.Received
	FROM
		Navigation.dbo.Mn_WaysheetRoutes wr
		left join mn_miningareas ma on ma.id = wr.ma_id
		left join objects o on o.id = wr.ExcavId
		left join workers w on w.id = wr.WorkerId
		left join workers w1 on w1.id = wr.SubWorkerId
		left join 
			(select r.id, zload.Name as LoadZone, zunload.Name as UnloadZone 
				from mn_route r
					left join zones zload on zload.id = r.loading_zone
					left join zones zunload on zunload.id = r.unloading_zone) 
			mr on mr.id = wr.MiningRouteId) wsr
			on wsr.id = dtt.WaysheetRouteId
		;