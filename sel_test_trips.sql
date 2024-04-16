/*выборка из сменных заданий смен с отрицательной статистикой по рейсам*/

select
dtt.BeginTime,
/*  (cast(
	substring(dtt.attributes,
			PATINDEX('%LadenMileageByRouteCountArchive~%', dtt.attributes)+len('LadenMileageByRouteCountArchive~'),
		CHARINDEX(char(10),dtt.attributes,PATINDEX('%LadenMileageByRouteCountArchive~%',dtt.attributes))-PATINDEX('%LadenMileageByRouteCountArchive~%',	dtt.attributes)-len('LadenMileageByRouteCountArchive~')
		)as int))
 as Trips
 ,*/
 CHARINDEX(char(10),dtt.attributes,PATINDEX('%LadenMileageByRouteCountArchive~%',dtt.attributes)),
 PATINDEX('%LadenMileageByRouteCountArchive~%',	dtt.attributes),
 CHARINDEX(char(10),dtt.attributes,PATINDEX('%LadenMileageByRouteCountArchive~%',dtt.attributes))-PATINDEX('%LadenMileageByRouteCountArchive~%',	dtt.attributes)-len('LadenMileageByRouteCountArchive~')
FROM
    Mn_DumptruckTasks dtt
    where dtt.BeginTime < cast('2019-11-30' as date)
    and  CHARINDEX(char(10),dtt.attributes,PATINDEX('%LadenMileageByRouteCountArchive~%',dtt.attributes))-PATINDEX('%LadenMileageByRouteCountArchive~%',	dtt.attributes)-len('LadenMileageByRouteCountArchive~') <0
    order by dtt.BeginTime desc