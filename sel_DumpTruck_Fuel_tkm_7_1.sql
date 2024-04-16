/*выборка удельного расхода самосвалов*/
/*норма л/ткм зимняя на 2019
0,125 - летняя
0,130 - зимняя*/
/*норма л/ткм зимняя на 2020
0,145 - летняя
0,152 - зимняя*/
/*с учётом рейсов без веса, пересчёт по удельному весу 2.28 и объёму 18.1*/
/*расчёт заправки и  расхода по остаткам на границах смены и пробегу с нормой 4л/км*/
/*27.02.2020 - исправление выборки по топливу и плечу пробега, была ошибка преобразования varchar В float*/

use navigation;
select sel2.DumpTruck as 'Самосвал',sel2.WorkDate as 'Дата',sel2.SM as 'Смена'
    , sel2.FuelBegin as 'Топливо на начало'
    ,sel2.FuelEnd as 'Топливо на конец'
    ,sel2.FuelFillings as 'Заправка'
    ,sel2.FuelCons as 'Расход'
    ,sel2.Length as 'Пробег за смену'
    ,sel2.MotoHours as 'Моточасы в рейсах'
    , (case when sel_tkm.Laden_mileage_sm >0 then sel_tkm.Laden_mileage_sm else 0 end) as 'Длина рейса'
    , (case when sel_tkm.Weight_sm>0  
        then sel_tkm.Weight_sm 
        else sel2.Trips*18.1*2.28 end) as 'Вес за смену'
    , (case when sel_tkm.Tkm_sm>0 
        then sel_tkm.Tkm_sm 
        else sel2.Trips*18.1*2.28*(case when sel_tkm.Laden_mileage_sm> 0 then sel_tkm.Laden_mileage_sm else 0 end) end) as 'Грузоборот за смену, ткм'
    , (case when sel_tkm.Tkm_sm>0 
        then sel2.FuelCons/sel_tkm.Tkm_sm 
        else 
            (case when sel_tkm.Tkm_sm=0 and sel2.Trips>0
                then sel2.FuelCons/(sel2.Trips*18.1*2.28*sel_tkm.Laden_mileage_sm)
                else 0 end) end) /*as Fuel_Tkm*/ as 'Удельный расход, л/ткм'
    , (case when sel2.Length>0 
        then sel2.FuelCons/sel2.Length 
        else 0 end) /*as Fuel_Length*/ as 'Удельный расход, л/км'
/*, (case when sel2.MotoHours> 0 then sel2.FuelCons/sel2.MotoHours else 0 end) as Fuel_MotoHours --из-за пустых моточасов иногда в сменном задании*/
    ,sel2.Trips as 'Рейсы'
    , (case when sel2.Trips>0 THEN 
        (case when sel_tkm.Weight_sm>0  
            then sel_tkm.Weight_sm/sel2.Trips
            else sel2.Trips*18.1*2.28/sel2.Trips end)
        else 0 end) as 'Средний вес'
    ,(case when sel2.WorkDate >= cast('2019-09-01' as date) then 
		(case when sel2.WorkDate >= cast('2019-09-01' as date) and sel2.WorkDate < cast('2020-01-01' as date) then 0.130 else
        (case when sel2.WorkDate >= cast('2020-01-01' as date) and sel2.WorkDate< cast('2020-05-01' as date) then 0.152
		else 0.145 end)
        end)
	else 0.125 end) /*0.130*/ as 'Норма расхода, л/ткм'
    ,sel2.LoadingIdlesAuto as 'Простои ожидания загрузки, с'
	/*,round(sel_tkm.LoadingIdles*24,2) as 'Простои ожидания загрузки, ч'*/
, round(cast(sel2.LoadingIdlesAuto as float)/3600,2) as 'Простои ожидания загрузки, ч'
	/*,cast(STUFF(CONVERT(VARCHAR,DATEADD(SECOND,sel_tkm.LoadingIdles,0),8),1,2,sel_tkm.LoadingIdles/(60*60)) as time) as 'Простои ожидания загрузки'*/
    ,sel2.RepairsAuto as 'Простои по ремонту, с'
	,round(cast(sel2.RepairsAuto as float)/(60*60),2) as 'Простои по ремонту, ч'
    from (
select sel1.DumpTruck,sel1.WorkDate,sel1.SM, sel1.FuelBegin,sel1.FuelEnd,
(case when sel1.FuelFillings=0 and sel1.FuelCons<=0
        then sel1.Length*4+sel1.FuelEnd-sel1.FuelBegin
        else sel1.FuelFillings end) as FuelFillings, /*расчёт заправки*/
(case when sel1.FuelCons<=0 and sel1.Length>0
        then sel1.Length*4 
        else (case when sel1.FuelCons=0 and sel1.Length<10 then 0 else sel1.FuelCons end)
        end) as FuelCons,  /*расчёт расхода*/
sel1.Length,sel1.MotoHours,
sum(sel1.trips) as Trips, round(sum(sel1.cargolength),1) as CargoLength, round(sum(tonnes),1) as Tonnes
	/*, cast(STUFF(CONVERT(VARCHAR,DATEADD(SECOND,sel1.LoadingIdlesAuto,0),8),1,2,sel1.LoadingIdlesAuto/(60*60)) as time) as LoadingIdlesAuto
    , cast(STUFF(CONVERT(VARCHAR,DATEADD(SECOND,sel1.RepairsAuto,0),8),1,2,sel1.RepairsAuto/(60*60)) as time)  as RepairsAuto*/
	,LoadingIdlesAuto, RepairsAuto /*для Excel*/
from (
SELECT /*top 10*/
/*dtt.BeginTime, */
o.Name as DumpTruck,
wsr.workdate, wsr.sm
,
cast (substring(
    substring(dtt.attributes,
			PATINDEX('%FuelBeginAuto~%',dtt.attributes)+len('FuelBeginAuto~'),
		    CHARINDEX(char(10),dtt.attributes,PATINDEX('%FuelBeginAuto~%',dtt.attributes))-PATINDEX('%FuelBeginAuto~%', dtt.attributes)-len('FuelBeginAuto~')),
    0,2+CHARINDEX('.',substring(dtt.attributes,
			PATINDEX('%FuelBeginAuto~%',dtt.attributes)+len('FuelBeginAuto~'),
		    CHARINDEX(char(10),dtt.attributes,PATINDEX('%FuelBeginAuto~%',dtt.attributes))-PATINDEX('%FuelBeginAuto~%', dtt.attributes)-len('FuelBeginAuto~')))) as float)
as FuelBegin
    

/*cast(
substring(dtt.attributes,
			PATINDEX('%FuelBeginAuto~%',dtt.attributes)+len('FuelBeginAuto~'),
		    CHARINDEX(char(10),dtt.attributes,PATINDEX('%FuelBeginAuto~%',dtt.attributes))-PATINDEX('%FuelBeginAuto~%', dtt.attributes)-len('FuelBeginAuto~')) as float) */
/*
	round(cast(
	substring(dtt.attributes,
			PATINDEX('%FuelBeginAuto~%',dtt.attributes)+len('FuelBeginAuto~'),
		    CHARINDEX(char(10),dtt.attributes,PATINDEX('%FuelBeginAuto~%',dtt.attributes))-PATINDEX('%FuelBeginAuto~%', dtt.attributes)-len('FuelBeginAuto~')
		)as float),1)  as FuelBegin*/
,

cast (substring(
    substring(dtt.attributes,
			PATINDEX('%FuelEndAuto~%',dtt.attributes)+len('FuelEndAuto~'),
		    CHARINDEX(char(10),dtt.attributes,PATINDEX('%FuelEndAuto~%',dtt.attributes))-PATINDEX('%FuelEndAuto~%', dtt.attributes)-len('FuelEndAuto~')),
    0,2+CHARINDEX('.',substring(dtt.attributes,
			PATINDEX('%FuelEndAuto~%',dtt.attributes)+len('FuelEndAuto~'),
		    CHARINDEX(char(10),dtt.attributes,PATINDEX('%FuelEndAuto~%',dtt.attributes))-PATINDEX('%FuelEndAuto~%', dtt.attributes)-len('FuelEndAuto~')))) as float)
as FuelEnd

	/*round(cast(
	substring(dtt.attributes,
			PATINDEX('%FuelEndAuto~%',dtt.attributes)+len('FuelEndAuto~'),
		    CHARINDEX(char(10),dtt.attributes,PATINDEX('%FuelEndAuto~%',dtt.attributes))-PATINDEX('%FuelEndAuto~%', dtt.attributes)-len('FuelEndAuto~')
		)as float),1) as FuelEnd
*/
,
cast (substring(
    substring(dtt.attributes,
			PATINDEX('%FillingsAuto~%',dtt.attributes)+len('FillingsAuto~'),
		    CHARINDEX(char(10),dtt.attributes,PATINDEX('%FillingsAuto~%',dtt.attributes))-PATINDEX('%FillingsAuto~%', dtt.attributes)-len('FillingsAuto~')),
    0,2+CHARINDEX('.',substring(dtt.attributes,
			PATINDEX('%FillingsAuto~%',dtt.attributes)+len('FillingsAuto~'),
		    CHARINDEX(char(10),dtt.attributes,PATINDEX('%FillingsAuto~%',dtt.attributes))-PATINDEX('%FillingsAuto~%', dtt.attributes)-len('FillingsAuto~')))) as float)
as FuelFillings
/*
	round(cast(
	substring(dtt.attributes,
			PATINDEX('%FillingsAuto~%',dtt.attributes)+len('FillingsAuto~'),
		    CHARINDEX(char(10),dtt.attributes,PATINDEX('%FillingsAuto~%',dtt.attributes))-PATINDEX('%FillingsAuto~%', dtt.attributes)-len('FillingsAuto~')
		)as float),1)  as FuelFillings*/
        
,
cast (substring(
    substring(dtt.attributes,
					PATINDEX('%FuelConsAuto~%',	dtt.attributes)+len('FuelConsAuto~'),
					CHARINDEX(char(10),dtt.attributes,PATINDEX('%FuelConsAuto~%',dtt.attributes))-PATINDEX('%FuelConsAuto~%', dtt.attributes)-len('FuelConsAuto~')),
    0,2+CHARINDEX('.',
    substring(dtt.attributes,
					PATINDEX('%FuelConsAuto~%',	dtt.attributes)+len('FuelConsAuto~'),
					CHARINDEX(char(10),dtt.attributes,PATINDEX('%FuelConsAuto~%',dtt.attributes))-PATINDEX('%FuelConsAuto~%', dtt.attributes)-len('FuelConsAuto~')))) as float)
as FuelCons
/*
	
				round(cast(
				substring(dtt.attributes,
					PATINDEX('%FuelConsAuto~%',	dtt.attributes)+len('FuelConsAuto~'),
					CHARINDEX(char(10),dtt.attributes,PATINDEX('%FuelConsAuto~%',dtt.attributes))-PATINDEX('%FuelConsAuto~%', dtt.attributes)-len('FuelConsAuto~')
					) as float),1)
	as FuelCons*/
, 
cast (substring(
    substring(dtt.attributes,
			PATINDEX('%MileageAuto~%',dtt.attributes)+len('MileageAuto~'),
		CHARINDEX(char(10),dtt.attributes,PATINDEX('%MileageAuto~%',dtt.attributes))-PATINDEX('%MileageAuto~%', dtt.attributes)-len('MileageAuto~')),
    0,2+CHARINDEX('.',
    substring(dtt.attributes,
			PATINDEX('%MileageAuto~%',dtt.attributes)+len('MileageAuto~'),
		CHARINDEX(char(10),dtt.attributes,PATINDEX('%MileageAuto~%',dtt.attributes))-PATINDEX('%MileageAuto~%', dtt.attributes)-len('MileageAuto~')))) as float)
as Length
	
    /*round(cast(
	substring(dtt.attributes,
			PATINDEX('%MileageAuto~%',dtt.attributes)+len('MileageAuto~'),
		CHARINDEX(char(10),dtt.attributes,PATINDEX('%MileageAuto~%',dtt.attributes))-PATINDEX('%MileageAuto~%', dtt.attributes)-len('MileageAuto~')
		)as float),1)  as Length*/
,
	round(cast(
	substring(dtt.attributes,
		PATINDEX('%MotoHoursAuto~%',dtt.attributes)+len('MotoHoursAuto~'),
		CHARINDEX(char(10),dtt.attributes,PATINDEX('%MotoHoursAuto~%',dtt.attributes))-PATINDEX('%MotoHoursAuto~%', dtt.attributes)-len('MotoHoursAuto~')
		)
		 as float)/3600,2)  as MotoHours	
,
	 
		 (cast(
	substring(dtt.attributes,
			PATINDEX('%LadenMileageByRouteCountArchive~%', dtt.attributes)+len('LadenMileageByRouteCountArchive~'),
		CHARINDEX(char(10),dtt.attributes,PATINDEX('%LadenMileageByRouteCountArchive~%',dtt.attributes))-PATINDEX('%LadenMileageByRouteCountArchive~%',	dtt.attributes)-len('LadenMileageByRouteCountArchive~')
		)as int))  as Trips
,
	round(cast(
	substring(dtt.attributes,
		PATINDEX('%LadenMileageByRouteArchive~%', dtt.attributes)+len('LadenMileageByRouteArchive~'),
		CHARINDEX(char(10),dtt.attributes,PATINDEX('%LadenMileageByRouteArchive~%',dtt.attributes))-PATINDEX('%LadenMileageByRouteArchive~%', dtt.attributes)-len('LadenMileageByRouteArchive~')
		)as float),1)  as CargoLength
,
	round(cast(
	substring(dtt.attributes,
			PATINDEX('%FactCargoValuePlanRounds~%', dtt.attributes)+len('FactCargoValuePlanRounds~'),
		CHARINDEX(char(10),dtt.attributes,PATINDEX('%FactCargoValuePlanRounds~%',dtt.attributes))-PATINDEX('%FactCargoValuePlanRounds~%',	dtt.attributes)-len('FactCargoValuePlanRounds~')
		)as float),1)  as Tonnes
,
	cast(
	substring(dtt.attributes,
		PATINDEX('%LoadingIdlesAuto~%', dtt.attributes)+len('LoadingIdlesAuto~'),
		CHARINDEX(char(10),dtt.attributes, PATINDEX('%LoadingIdlesAuto~%',dtt.attributes))-PATINDEX('%LoadingIdlesAuto~%', dtt.attributes)-len('LoadingIdlesAuto~'))
		 as int)  as LoadingIdlesAuto
,
	cast(
	substring(dtt.attributes,
			PATINDEX('%RepairsAuto~%', dtt.attributes)+len('RepairsAuto~'),
			CHARINDEX(char(10),dtt.attributes,PATINDEX('%RepairsAuto~%',dtt.attributes))-PATINDEX('%RepairsAuto~%',	dtt.attributes)-len('RepairsAuto~')
		)as int)  as RepairsAuto
		 /*--,dtt.attributes*/
FROM
	Navigation.dbo.Mn_DumptruckTasks dtt
	left join Objects o on o.id = dtt.DumptruckId
	left join Mn_WaysheetRoutes wsr on wsr.id = dtt.WaysheetRouteId
	where 
	len(dtt.attributes)> 0 and
	wsr.WorkDate >= cast('01.06.2019' as date)
	and dtt.BeginTime >= cast('01.06.2019' as date)
    /*wsr.WorkDate>=cast('21.11.2019' as date) and wsr.WorkDate<cast('22.11.2019' as date)*/
	/*BeginTime >= cast('01.08.2019' as date)*/
		/*and dtt.attributes like '%FillingsAuto~0%';*/
	/*order by dtt.BeginTime, o.Name;*/
	) sel1
group by sel1.DumpTruck,sel1.workdate,sel1.sm, sel1.fuelbegin,sel1.fuelend,sel1.fuelfillings,sel1.fuelcons,sel1.length,sel1.motohours
    ,sel1.LoadingIdlesAuto,sel1.RepairsAuto) sel2

left JOIN (
SELECT /*top 10 */
	a.workdate, a.SM ,
	b.Name as DumpTruck,
    avg(a.Laden_mileage) as Laden_mileage_sm, 
	sum(a.Weight) as Weight_sm, 
	sum(a.Laden_mileage*a.Weight) as Tkm_sm
	, sum(cast(a.load_beg - a.wait_beg as float)) as LoadingIdles

	
	FROM Navigation.dbo.Mn_ArchiveRounds a
		left join Navigation.dbo.objects b on a.dumpid = b.ID
		/*left join Navigation.dbo.objects c on a.Excavid = c.ID
		left join Navigation.dbo.Zones z_load on a.loadzone = z_load.ID
		left join Navigation.dbo.Zones z_unload on a.unloadzone = z_unload.ID
		left join Navigation.dbo.ZoneGroupToZone zgz_load on zgz_load.ZoneID = z_load.ID
		left join Navigation.dbo.ZoneGroups zg_load on zg_load.id = zgz_load.ZoneGroupID
		left join Navigation.dbo.ZoneGroupToZone zgz_unload on zgz_unload.ZoneID = z_unload.ID
		left join Navigation.dbo.ZoneGroups zg_unload on zg_unload.id = zgz_unload.ZoneGroupID*/
	
	where a.WorkDate>=cast('01.06.2019' as date)
	/* and a.WorkDate<cast('22.11.2019' as date)*/
		and Active>0 /*Уч. - первая галочка для рейсов к учёту, для исключения красных рейсов*/
		and Archived>0 /*Исп. - вторая галочка для рейсов по маршруту*/	
	group by a.workdate , a.SM , b.Name) sel_tkm
    on sel2.workdate=sel_tkm.workdate and sel2.sm=sel_tkm.sm and sel2.DumpTruck=sel_tkm.DumpTruck
    
order by sel2.workdate, sel2.sm, sel2.DumpTruck;

/*
BeginAuto~10.05.2019 7:45:07
EndAuto~10.05.2019 19:14:06
MileageLadenAuto~37.0308093987703
FuelBeginAuto~257.147741147741
FuelEndAuto~315.697191697192
FillingsAuto~372.078144078144
FuelConsAuto~313.528693528694
LastFillingTime~10.05.2019 7:49:11
LastFillingVolume~372.078144078144
MileageAuto~80.9966793429554
WorkTimeAuto~41339
MotoHoursAuto~38206
RepairsAuto~0
LoadingIdlesAuto~4185
FactCargoValuePlanRounds~1031.7
FactCargoValuePlanRoundsVolume~452.5
FactCargoValuePlanRoundsArchive~1072.968
FactCargoValuePlanRoundsVolumeArchive~470.6
FactCargoValueUnplanRounds~288.876
FactCargoValueUnplanRoundsVolume~126.7
IdlesAuto~6174
LadenMileageByRoute~29.3885804339647
LadenMileageByRouteCount~25
MotoHoursByRoute~29567
LadenMileageByRouteCountArchive~26
LadenMileageByRouteArchive~30.5628474969268
MotoHoursByRouteArchive~21212
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
_cfactv~113.125
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
*/