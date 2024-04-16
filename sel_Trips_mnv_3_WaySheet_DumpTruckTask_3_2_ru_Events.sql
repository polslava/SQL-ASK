/*выборка рейсов из сменного задания*/
/*попытка построить график рейсов*/

use navigation;

SELECT /*top 10 */
	a.workdate as 'Дата', a.SM as 'Смена'
    , a.load_beg as 'Время события'
    /*, a.unload_end as 'Конец разгрузки'*/
    /*, round(a.Laden_mileage,1) as 'Пробег гружёным', round(a.Weight,1) as 'Вес', */
	/*a.loadzone, a.unloadzone,*/ 
    ,a.archived, a.active
	,b.Name as 'Самосвал'
    , c.Name as 'Пункт'

	/*z_load.Name as 'Зона погрузки', zg_load.Name as 'Группа зон погрузки', 
	z_unload.Name as 'Зона разгрузки', zg_unload.Name as 'Группа зон разгрузки'		
	*/
	/*, wsr_sdt.BeginTime_DumpTruck as 'Начало смены самосвала', wsr_sdt.EndTime_DumpTruck as 'Конец смены самосвала', wsr_sdt.Cargo as 'Вид груза', wsr_sdt.WorkName as 'Вид работ', 
	wsr_sdt.Driver_DumpTruck as 'Водитель самосвала', wsr_sdt.Name_Areas as 'Горный участок',
	wsr_sdt.WorkDate as 'Дата смены см', wsr_sdt.SM as 'Смена см', wsr_sdt.BeginTime_Shovel as 'Начало работы экскаватора см', wsr_sdt.EndTime_Shovel as 'Конец работы экскаватора см', 
	wsr_sdt.Shovel as 'Экскаватор см',
	wsr_sdt.ShovelDriver  as 'Машинист экскаватора см',wsr_sdt.LoadZone as 'Зона погрузки см', wsr_sdt.UnloadZone as 'Зона разгрузки см', wsr_sdt.Closed		
	*/
	/*,round(a.Laden_mileage*a.Weight,1) as 'Грузооборот ткм'*/
	, cast(a.load_beg - a.wait_beg as time) as 'Ожидание погрузки' 
	, cast(a.load_end - a.load_beg as time) as 'Время погрузки'
	, cast(a.unload_beg - a.load_end as time) as 'Время гружёным'
	, cast(a.unload_end - a.unload_beg as time) as 'Время разгрузки'
	--, round(a.Laden_mileage/(cast((a.unload_beg - a.load_end) as float)*24),1) as 'Скорость гружёным'
	/*,cast(a.unload_beg - a.load_end as float)*2 as 'Время на маршруте туда-обратно'
	,round(cast(wsr_sdt.EndTime_DumpTruck - wsr_sdt.BeginTime_DumpTruck as float)*2,2) as 'Время в смене самосвала'
	,round((cast(a.unload_beg - a.load_end as float)*2) / (cast(wsr_sdt.EndTime_DumpTruck - wsr_sdt.BeginTime_DumpTruck as float)*2),5) as 'КИО'*/
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
		where a.load_beg >= cast('30.10.2019 20:00:00' as datetime)
			and closed is not null
		/* between cast('30.04.2019' as date) and cast('02.05.2019' as date) */
		

union 
SELECT /*top 10 */
	a.workdate as 'Дата', a.SM as 'Смена'
    , a.unload_beg as 'Время события'
    /*, a.unload_end as 'Конец разгрузки'*/
    /*, round(a.Laden_mileage,1) as 'Пробег гружёным', round(a.Weight,1) as 'Вес', */
	/*a.loadzone, a.unloadzone,*/ 
    ,a.archived, a.active
	,b.Name as 'Самосвал'
    --, c.Name as 'Пункт'

	/*z_load.Name as 'Зона погрузки', zg_load.Name as 'Группа зон погрузки', */
	,z_unload.Name as 'Пункт'
    /*, zg_unload.Name as 'Группа зон разгрузки'		
	*/
	/*, wsr_sdt.BeginTime_DumpTruck as 'Начало смены самосвала', wsr_sdt.EndTime_DumpTruck as 'Конец смены самосвала', wsr_sdt.Cargo as 'Вид груза', wsr_sdt.WorkName as 'Вид работ', 
	wsr_sdt.Driver_DumpTruck as 'Водитель самосвала', wsr_sdt.Name_Areas as 'Горный участок',
	wsr_sdt.WorkDate as 'Дата смены см', wsr_sdt.SM as 'Смена см', wsr_sdt.BeginTime_Shovel as 'Начало работы экскаватора см', wsr_sdt.EndTime_Shovel as 'Конец работы экскаватора см', 
	wsr_sdt.Shovel as 'Экскаватор см',
	wsr_sdt.ShovelDriver  as 'Машинист экскаватора см',wsr_sdt.LoadZone as 'Зона погрузки см', wsr_sdt.UnloadZone as 'Зона разгрузки см', wsr_sdt.Closed		
	*/
	/*,round(a.Laden_mileage*a.Weight,1) as 'Грузооборот ткм'*/
	, cast(a.load_beg - a.wait_beg as time) as 'Ожидание погрузки' 
	, cast(a.load_end - a.load_beg as time) as 'Время погрузки'
	, cast(a.unload_beg - a.load_end as time) as 'Время гружёным'
	, cast(a.unload_end - a.unload_beg as time) as 'Время разгрузки'
	--, round(a.Laden_mileage/(cast((a.unload_beg - a.load_end) as float)*24),1) as 'Скорость гружёным'
	/*,cast(a.unload_beg - a.load_end as float)*2 as 'Время на маршруте туда-обратно'
	,round(cast(wsr_sdt.EndTime_DumpTruck - wsr_sdt.BeginTime_DumpTruck as float)*2,2) as 'Время в смене самосвала'
	,round((cast(a.unload_beg - a.load_end as float)*2) / (cast(wsr_sdt.EndTime_DumpTruck - wsr_sdt.BeginTime_DumpTruck as float)*2),5) as 'КИО'*/
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
		where a.load_beg >= cast('30.10.2019 20:00:00' as datetime)
			and closed is not null
		/* between cast('30.04.2019' as date) and cast('02.05.2019' as date) */
		
	order by load_beg;






