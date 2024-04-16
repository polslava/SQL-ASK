use navigation;
select workdate, sm, Shovel_ws, 
	/*sum(load_time_Shovel)/24 as working_time*/
	
	 sum( DATEPART(SECOND, load_time) + 60 * 
              DATEPART(MINUTE, load_time) + 3600 * 
              DATEPART(HOUR, load_time) 
	 ) as 'время погрузки в секундах'
	,
	round(sum(cast( DATEPART(SECOND, load_time) + 60 * 
              DATEPART(MINUTE, load_time) + 3600 * 
              DATEPART(HOUR, load_time) 
	  as float))/3600,5)  as 'время погрузки в часах'
	,
	sum(load_time_Shovel) as working_time
	/*sum(cargo_time_route) as cargo_time,*/
	, round((sum(load_time_Shovel)/24)/cast(cast(datepart(hour, '12:00:00') as float)/24 as float) 
	/* 12 часов  = 1 КИО*/ 
	/*(cast(EndTime_Shovel - BeginTime_Shovel as float))*/
	,2) as KIO
/*,cast(EndTime_Shovel - BeginTime_Shovel as float)*/

	from (
	
SELECT /*top 10 */
	a.workdate, a.SM, a.load_beg, a.unload_end, round(a.Laden_mileage,1) as Laden_mileage, round(a.Weight,1) as Weight, 
	/*a.loadzone, a.unloadzone,*/ a.archived, a.active,
	b.Name as DumpTruck, c.Name as Shovel,
	z_load.Name as LoadZone, zg_load.Name as LoadZoneGroup, /*a.loadzone,*/
	z_unload.Name as UnloadZone, zg_unload.Name as UnLoadZoneGroup		
	
	, wsr_sdt.BeginTime_DumpTruck, wsr_sdt.EndTime_DumpTruck, wsr_sdt.Cargo, wsr_sdt.WorkName, wsr_sdt.Driver_DumpTruck, wsr_sdt.Name_Areas,
	wsr_sdt.WorkDate as WorkDate_ws, wsr_sdt.SM as SM_ws, wsr_sdt.BeginTime_Shovel, wsr_sdt.EndTime_Shovel, wsr_sdt.Shovel as Shovel_ws,
	wsr_sdt.ShovelDriver ,wsr_sdt.LoadZone as LoadZone_ws, wsr_sdt.UnloadZone as UnloadZone_ws, wsr_sdt.Closed		
	
	,round(a.Laden_mileage*a.Weight,1) as tkm
	, cast(a.load_beg - a.wait_beg as time) as stand_load_time /*, a.wait_beg*/
	, cast(a.load_end - a.load_beg as time) as load_time
	, cast(a.unload_beg - a.load_end as time) as cargo_time
	, cast(a.unload_end - a.unload_beg as time) as unload_time
	, round(a.Laden_mileage/(cast((a.unload_beg - a.load_end) as float)*24),1) as velocity
	,cast(a.unload_beg - a.load_beg as float)*2 as cargo_time_route /*����� �� ������ �������� �� ����� ���������*/
	,round(cast(wsr_sdt.EndTime_DumpTruck - wsr_sdt.BeginTime_DumpTruck as float)*2,2) as working_time
	/*,round((cast(a.unload_beg - a.load_end as float)*2) / (cast(wsr_sdt.EndTime_DumpTruck - wsr_sdt.BeginTime_DumpTruck as float)*2),5) as kio*/
	,
datepart(hour, cast(a.load_end - a.load_beg as time))+cast(datepart(minute, cast(a.load_end - a.load_beg as time)) as float)/60+cast(datepart(second, cast(a.load_end - a.load_beg as time)) as float)/3600
as load_time_Shovel
	FROM Navigation.dbo.Mn_ArchiveRounds a
		left join Navigation.dbo.objects b on a.dumpid = b.ID
		left join Navigation.dbo.objects c on a.Excavid = c.ID
		left join Navigation.dbo.Zones z_load on a.loadzone = z_load.ID
		left join Navigation.dbo.Zones z_unload on a.unloadzone = z_unload.ID
		left join Navigation.dbo.ZoneGroupToZone zgz_load on zgz_load.ZoneID = z_load.ID
		left join Navigation.dbo.ZoneGroups zg_load on zg_load.id = zgz_load.ZoneGroupID
		left join Navigation.dbo.ZoneGroupToZone zgz_unload on zgz_unload.ZoneID = z_unload.ID
		left join Navigation.dbo.ZoneGroups zg_unload on zg_unload.id = zgz_unload.ZoneGroupID
		left join 
			(SELECT
				dtt.ID, dtt.WaysheetRouteId,
				dtt.DumptruckId,
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
									on wsr.id = dtt.WaysheetRouteId) wsr_sdt 
				on wsr_sdt.dumptruckid = a.dumpid and a.workdate = wsr_sdt.WorkDate and a.sm = wsr_sdt.sm
					and c.Name = wsr_sdt.Shovel and z_unload.Name = wsr_sdt.UnloadZone
		where a.load_beg >= cast('11.09.2019 08:00:00' as datetime)
			and closed is not null
		/* between cast('30.04.2019' as date) and cast('02.05.2019' as date) */
		/*and b.Name like '%10%'*/
/*	order by load_beg;*/
		) sel1
		group by workdate, sm, Shovel_ws, EndTime_Shovel, BeginTime_Shovel
		order by workdate, sm, Shovel_ws




