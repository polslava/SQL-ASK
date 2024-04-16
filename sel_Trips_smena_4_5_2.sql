/*выборка рейсов из сменного задания*/

use navigation;
SELECT /*top 10 */
	a.workdate as 'Дата', a.SM as 'Смена'
	, a.load_beg as 'Начало погрузки'
	, a.unload_end as 'Конец разгрузки'
	, round(a.Laden_mileage,1) as 'Пробег гружёным'
	, round(a.Weight,1) as 'Вес'
	, round((a.Weight/2.28),1) as 'Объём'
	/*a.loadzone, a.unloadzone,*/ 
	,a.archived, a.active
	,b.Name as 'Самосвал'
	, c.Name as 'Экскаватор',
	z_load.Name as 'Зона погрузки'
	, zg_load.Name as 'Группа зон погрузки', /*a.loadzone,*/
	z_unload.Name as 'Зона разгрузки'
	, zg_unload.Name as 'Группа зон разгрузки'		
	
	, wsr_sdt.BeginTime_DumpTruck as 'Начало смены самосвала'
	, wsr_sdt.EndTime_DumpTruck as 'Конец смены самосвала'
	, wsr_sdt.Cargo as 'Вид груза', wsr_sdt.WorkName as 'Вид работ', 
	wsr_sdt.Driver_DumpTruck as 'Водитель самосвала'
	, wsr_sdt.Name_Areas as 'Горный участок',
	wsr_sdt.WorkDate as 'Дата смены см'
	, wsr_sdt.SM as 'Смена см'
	, wsr_sdt.BeginTime_Shovel as 'Начало работы экскаватора см'
	, wsr_sdt.EndTime_Shovel as 'Конец работы экскаватора см', 
	wsr_sdt.Shovel as 'Экскаватор см',
	wsr_sdt.ShovelDriver  as 'Машинист экскаватора см'
	,wsr_sdt.LoadZone as 'Зона погрузки см'
	, wsr_sdt.UnloadZone as 'Зона разгрузки см', wsr_sdt.Closed		
	
	,round(a.Laden_mileage*a.Weight,1) as 'Грузооборот ткм'
	, cast(a.load_beg - a.wait_beg as time) as 'Ожидание погрузки' /*, a.wait_beg*/
	, round(cast(a.load_beg - a.wait_beg  as float)*24*60,1) as 'Ожидание  погрузки, мин'
    , round(cast(a.load_beg - a.wait_beg  as float)*24,5) as 'Ожидание  погрузки, ч'
	, cast(a.load_end - a.load_beg as time) as 'Время погрузки'
    , round(cast(a.load_end - a.load_beg as float)*24*60,1) as 'Время погрузки, мин'
	, round(cast(a.load_end - a.load_beg as float)*24,5) as 'Время погрузки, ч'
	, cast(a.unload_beg - a.load_end as time) as 'Время гружёным'
	, cast(a.unload_end - a.unload_beg as time) as 'Время разгрузки'
	, round(cast(a.unload_beg - a.load_end as float)*24,5) as 'Время гружёным, ч'
    , round(cast(a.unload_end - a.unload_beg as float)*24,5) as 'Время разгрузки, ч'
    , round(a.Laden_mileage/(cast((a.unload_beg - a.load_end) as float)*24),1) as 'Скорость гружёным'
	
    ,cast(a.move_end - a.load_end as float) as 'Время движения на маршруте туда-обратно'
    ,cast(a.move_end - a.unload_end as float) as 'Время порожним обратно'
    ,round(cast(a.move_end - a.load_end as float)*24,5) as 'Время движения на маршруте туда-обратно, ч'
    ,round(cast(a.move_end - a.unload_end as float)*24,5) as 'Время порожним обратно, ч'
    /*,cast(a.unload_beg - a.load_end as float) as 'Время движения на маршруте туда-обратно 1'*/

    /*,cast(a.unload_beg - a.load_end as float)*2+cast(a.load_end - a.load_beg as float)+cast(a.unload_end - a.unload_beg as float) as 'Время на маршруте туда-обратно и погрузка-разгрузка'*/
	,cast(a.move_end - a.load_beg as float) as 'Время на маршруте туда-обратно и погрузка-разгрузка'
	,round(cast(wsr_sdt.EndTime_DumpTruck - wsr_sdt.BeginTime_DumpTruck as float)*24,2) as 'Время в смене самосвала'
	/*,round(cast(a.unload_beg - a.load_end as float)*24,5)*2 as 'Время движения на маршруте туда-обратно, ч'*/
    /*,round(cast(a.unload_beg - a.load_end as float)*2+cast(a.load_end - a.load_beg as float)+cast(a.unload_end - a.unload_beg as float)*24,5) as 'Время на маршруте туда-обратно и погрузка-разгрузка, ч'*/
	,round(cast(a.move_end - a.load_beg as float)*24,5) as 'Время на маршруте туда-обратно и погрузка-разгрузка, ч'
	,round(cast(wsr_sdt.EndTime_DumpTruck - wsr_sdt.BeginTime_DumpTruck as float)*24,2) as 'Время в смене самосвала, ч'
	,/*round(cast(a.unload_beg - a.load_end as float)*2+cast(a.load_end - a.load_beg as float)+cast(a.unload_end - a.unload_beg as float) 
        / (cast(wsr_sdt.EndTime_DumpTruck - wsr_sdt.BeginTime_DumpTruck as float)*12),5) as 'КИО'*/
    round(cast(a.move_end - a.wait_beg as float)*24,5)
	    /  round(cast(wsr_sdt.EndTime_DumpTruck - wsr_sdt.BeginTime_DumpTruck as float)*24,5) as 'КИО'
	

		
	, CONVERT(varchar(19), a.load_beg,20) as 'Начало погрузки t'
	, CONVERT(varchar(19), a.unload_end,20) as 'Конец разгрузки t'
	, left(CONVERT(varchar(8), a.unload_end,108),2) as 'Час разгрузки t'
	, (case when left(left(CONVERT(varchar(8), a.unload_end,108),2),1)='2' 
		then concat(left(CONVERT(varchar(8), a.workdate ,104),2),'__',left(CONVERT(varchar(8), a.unload_end,108),2))
		else concat(left(CONVERT(varchar(8), a.workdate ,104),2),'_',left(CONVERT(varchar(8), a.unload_end,108),2)) 
	end) as 'Час разгрузки t1'
    , CONVERT(varchar(19), wsr_sdt.BeginTime_Shovel,20) as 'Начало работы экскаватора см t'
    , CONVERT(varchar(19), wsr_sdt.EndTime_Shovel,20) as 'Конец работы экскаватора см t'
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
		where a.load_beg >= cast('31.10.2019 20:00:00' as datetime)
			and closed is not null
		/* between cast('30.04.2019' as date) and cast('02.05.2019' as date) */
and Active>0 /*Уч. - первая галочка для рейсов к учёту, для исключения красных рейсов*/
and Archived>0 /*Исп. - вторая галочка для рейсов по маршруту*/
	order by load_beg;



