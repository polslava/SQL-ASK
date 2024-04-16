use Navigation;
select a2.workdate, a2.sm, a2.DumpTruck 
, sum(cargo_time+uncargo_time) as route_time
,round(sum(cargo_time+uncargo_time)/cast(cast(datepart(hour, '12:00:00') as float)/24 as float) /*12 часов = 1 КИО, план = 10ч, 0,83КИО*/ 
,2) as KIO

from
(
select 
a1.trip_num, a1.workdate, a1.SM, a1.wait_beg, a1.load_beg, a1.unload_end, a1.DumpTruck, a1.Shovel_ws, a1.UnloadZone_ws, a1.Closed,	
a1.cargo_time,
(case
when sel_r.wait_beg - a1.unload_end is null then 0 else
cast(sel_r.wait_beg - a1.unload_end as float) end) as uncargo_time
from 
(
SELECT /*top 10 */
	row_number() over (order by b.Name asc, a.workdate asc, a.SM asc ) as trip_num,
	a.workdate, a.SM	
	, a.wait_beg, a.load_beg, a.unload_end, 
	b.Name as DumpTruck, 
	wsr_sdt.Shovel as Shovel_ws,
	 wsr_sdt.UnloadZone as UnloadZone_ws, wsr_sdt.Closed		
	,
	cast(a.unload_end - a.load_beg as float) as cargo_time /*время от начала загрузки до конца разгрузки*/
	
	
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
		where a.load_beg >= cast('19.08.2019 08:00:00' as datetime)
			and wsr_sdt.closed is not null
		group by a.workdate, a.SM, a.wait_beg, a.load_beg, a.unload_end,b.Name,wsr_sdt.Shovel,wsr_sdt.UnloadZone,wsr_sdt.Closed
) a1					
			left join (
			SELECT 
	row_number() over (order by b.Name asc, a.workdate asc, a.SM asc ) as trip_num,
	a.workdate, a.SM	
	, a.wait_beg, a.load_beg, a.unload_end,
	b.Name as DumpTruck, 	wsr_sdt.Shovel as Shovel_ws,
	 wsr_sdt.UnloadZone as UnloadZone_ws, wsr_sdt.Closed		
	,
	cast(a.unload_end - a.load_beg as float) as cargo_time /*время от начала загрузки до конца разгрузки*/
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
					
		
		where a.load_beg >= cast('19.08.2019 08:00:00' as datetime)
			and wsr_sdt.closed is not null
		group by a.workdate, a.SM, a.wait_beg, a.load_beg, a.unload_end,b.Name,wsr_sdt.Shovel,wsr_sdt.UnloadZone,wsr_sdt.Closed
		) sel_r on 
			sel_r.workdate = a1.workdate and sel_r.sm = a1.sm and sel_r.DumpTruck = a1.DumpTruck and sel_r.Shovel_ws = a1.Shovel_ws /*and sel_r.UnloadZone_ws = a1.UnloadZone_ws*/
				and a1.trip_num+1 = sel_r.trip_num
		) a2
		group by a2.workdate, a2.sm, a2.DumpTruck