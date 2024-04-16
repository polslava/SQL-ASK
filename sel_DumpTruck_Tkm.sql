use navigation;

SELECT /*top 10 */
	a.workdate as 'Дата', a.SM as 'Смена',
	round(avg(a.Laden_mileage),1) as 'Среднее плечо', 
	round(sum(a.Weight),1) as 'Вес за смену', 
	b.Name as 'Самосвал',
	round(sum(a.Laden_mileage*a.Weight),1) as 'Грузооборот ткм'
	
	FROM Navigation.dbo.Mn_ArchiveRounds a
		left join Navigation.dbo.objects b on a.dumpid = b.ID
		left join Navigation.dbo.objects c on a.Excavid = c.ID
		left join Navigation.dbo.Zones z_load on a.loadzone = z_load.ID
		left join Navigation.dbo.Zones z_unload on a.unloadzone = z_unload.ID
		left join Navigation.dbo.ZoneGroupToZone zgz_load on zgz_load.ZoneID = z_load.ID
		left join Navigation.dbo.ZoneGroups zg_load on zg_load.id = zgz_load.ZoneGroupID
		left join Navigation.dbo.ZoneGroupToZone zgz_unload on zgz_unload.ZoneID = z_unload.ID
		left join Navigation.dbo.ZoneGroups zg_unload on zg_unload.id = zgz_unload.ZoneGroupID
	
	where a.WorkDate=cast('11.09.2019' as date)
		
	group by a.workdate , a.SM , b.Name