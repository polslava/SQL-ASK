SELECT
	wr.ID,
	/*MA_ID,*/ ma.Name,
	wr.WorkDate,
	wr.SM,
	wr.BeginTime,
	wr.EndTime,
	/*wr.ExcavId,*/ o.Name as Shovel,
	/*wr.WorkerId*/ w.Shortname as ShovelDriver,
	/*wr.MiningRouteId*/ mr.routename,
	/*wr.attributes,*/
	/*wr.SubWorkerId*/ w1.Shortname as ShovelSubDriver, 
	wr.Closed,
	wr.Received
	/*,
	wr.main_attributes*/
	FROM
		Navigation.dbo.Mn_WaysheetRoutes wr
		left join mn_miningareas ma on ma.id = wr.ma_id
		left join objects o on o.id = wr.ExcavId
		left join workers w on w.id = wr.WorkerId
		left join workers w1 on w1.id = wr.SubWorkerId
		left join 
			(select r.id, (zload.Name+' - '+zunload.Name) as routename 
				from mn_route r
					left join zones zload on zload.id = r.loading_zone
					left join zones zunload on zunload.id = r.unloading_zone) 
			mr on mr.id = wr.MiningRouteId
		;