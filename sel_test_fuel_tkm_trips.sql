
/*проверочная выборка значений рейсов из удельного расхода
*/
select * from (
select dtt.attributes,
	o.name
	,
			 (cast(
	substring(right(dtt.attributes,
			len(dtt.attributes)-PATINDEX('%LadenMileageByRouteCountArchive~%',
				dtt.attributes)+1),
		(len('LadenMileageByRouteCountArchive~')+1),
		patindex('%LadenMileageByRouteArchive%',right(dtt.attributes,len(dtt.attributes)-PATINDEX('%LadenMileageByRouteCountArchive~%',dtt.attributes)+1))-(len('LadenMileageByRouteCountArchive~')+2)
		)as int))  as Trips
	,
	cast(
	substring(right(dtt.attributes,
			len(dtt.attributes)-PATINDEX('%LoadingIdlesAuto~%',
				dtt.attributes)+1),
		(len('LoadingIdlesAuto~')+1),
		patindex('%LadenMileageByRoute%',right(dtt.attributes,len(dtt.attributes)-PATINDEX('%LoadingIdlesAuto~%',dtt.attributes)+1))-(len('LoadingIdlesAuto~')+2)
		)as int)  as LoadingIdlesAuto
	,
	cast(
	substring(right(dtt.attributes,
			len(dtt.attributes)-PATINDEX('%RepairsAuto~%',
				dtt.attributes)+1),
		(len('RepairsAuto~')+1),
		patindex('%LoadingIdlesAuto%',right(dtt.attributes,len(dtt.attributes)-PATINDEX('%RepairsAuto~%',dtt.attributes)+1))-(len('RepairsAuto~')+2)
		)as int)  as RepairsAuto		
		
	 FROM
	Navigation.dbo.Mn_DumptruckTasks dtt
	left join Objects o on o.id = dtt.DumptruckId
	left join Mn_WaysheetRoutes wsr on wsr.id = dtt.WaysheetRouteId
	where 
    wsr.WorkDate>=cast('01.11.2019' as date) 
	 /*and wsr.WorkDate<cast('22.11.2019' as date)*/
    and wsr.SM=1
 ) sel1
 where sel1.trips =0


SELECT /*top 10 */
	a.workdate, a.SM ,
	b.Name as DumpTruck,
    avg(a.Laden_mileage) as Laden_mileage_sm, 
	sum(a.Weight) as Weight_sm, 
	sum(a.Laden_mileage*a.Weight) as Tkm_sm
	
	FROM Navigation.dbo.Mn_ArchiveRounds a
		left join Navigation.dbo.objects b on a.dumpid = b.ID
		left join Navigation.dbo.objects c on a.Excavid = c.ID
		left join Navigation.dbo.Zones z_load on a.loadzone = z_load.ID
		left join Navigation.dbo.Zones z_unload on a.unloadzone = z_unload.ID
		left join Navigation.dbo.ZoneGroupToZone zgz_load on zgz_load.ZoneID = z_load.ID
		left join Navigation.dbo.ZoneGroups zg_load on zg_load.id = zgz_load.ZoneGroupID
		left join Navigation.dbo.ZoneGroupToZone zgz_unload on zgz_unload.ZoneID = z_unload.ID
		left join Navigation.dbo.ZoneGroups zg_unload on zg_unload.id = zgz_unload.ZoneGroupID
	
	where a.WorkDate>=cast('21.11.2019' as date) and a.WorkDate<cast('22.11.2019' as date)
	group by a.workdate , a.SM , b.Name
	
MileageLadenAuto~56.3769238977581
BeginAuto~20.11.2019 19:30:00
EndAuto~21.11.2019 7:30:00
FuelBeginAuto~306.923076923077
FuelEndAuto~257.205128205128
FillingsAuto~332.410256410256
FuelConsAuto~382.128205128205
LastFillingTime~20.11.2019 19:54:00
LastFillingVolume~332.410256410256
MileageAuto~115.944944845438
WorkTimeAuto~43200
MotoHoursAuto~41525
RepairsAuto~0
LoadingIdlesAuto~3882
LadenMileageByRoute~56.3769238977581
LadenMileageByRouteCount~28
MotoHoursByRoute~42469
FactCargoValuePlanRounds~1155.504
FactCargoValuePlanRoundsVolume~506.8
LadenMileageByRouteCountArchive~28
LadenMileageByRouteArchive~56.3769238977581
MotoHoursByRouteArchive~42469
SHTAK_Рудный склад ЗИФ Штабель 0~0
SHTAK_Рудный склад ЗИФ Штабель 1~0
SHTAK_Рудный склад ЗИФ Штабель 1в~0
SHTAK_Рудный склад ЗИФ Штабель 2~0
SHTAK_Рудный склад ЗИФ Штабель 3~0
SHTAK_Рудный склад ЗИФ Штабель 4~0
SHTAK_A_Рудный склад ЗИФ Штабель 0~0
SHTAK_A_Рудный склад ЗИФ Штабель 1~0
SHTAK_A_Рудный склад ЗИФ Штабель 1в~0
SHTAK_A_Рудный склад ЗИФ Штабель 2~0
SHTAK_A_Рудный склад ЗИФ Штабель 3~0
SHTAK_A_Рудный склад ЗИФ Штабель 4~0
FactCargoValuePlanRoundsArchive~1155.504
FactCargoValuePlanRoundsVolumeArchive~506.8
_cfactv~101.36
FactCargoValueUnplanRounds~0
FactCargoValueUnplanRoundsVolume~0
Idle_BVR~0
Idle_DVS~0
Idle_CHASSIS~0
Idle_ELECTR~0
Idle_TIRES~0
Idle_DRV_W~0
Idle_WORK_W~0
Idle_TO~0
Idle_EMERG~0
Idle_OTHERS~0
IdlesAuto~8206
