use navigation;
SELECT /*ws.*,*/
		ws.date, ws.sm, ws.datecreate, /*ws.IdDriver, */ 
		ws.starttimegraf, ws.starttimefact, ws.starttimefactmanual,
		ws.starttotalmileage, ws.startfuel,
		ws.endtimegraf, ws.endtimefact, ws.endtimefactmanual,
		ws.endtotalmileage, ws.endfuel,
		ws.mileagefact, 
		/*ws.timemotion,*/ STUFF(CONVERT(VARCHAR,DATEADD(SECOND,ws.timemotion,0),8),1,2,ws.timemotion/(60*60)) as timemotion,
		/*ws.timeworkspec, */ STUFF(CONVERT(VARCHAR,DATEADD(SECOND,ws.timeworkspec,0),8),1,2,ws.timeworkspec/(60*60)) As timeworkspec,
		/*ws.timeworkengine,*/ STUFF(CONVERT(VARCHAR,DATEADD(SECOND,ws.timeworkengine,0),8),1,2,ws.timeworkengine/(60*60)) as timeworkengine,
		ws.fuelspendfact, ws.fuelfilled, ws.fuelgiven, ws.fuelspendnorm,
		ws.startfuelauto, ws.EndFuelAuto, ws.filling, ws.fillingauto,
		ws.fuelspendfactauto,ws.mileagefactauto,
		/*ws.standtime,*/ STUFF(CONVERT(VARCHAR,DATEADD(SECOND,ws.standtime,0),8),1,2,ws.standtime/(60*60)) as standtime,
		/*ws.RepairTime,*/ STUFF(CONVERT(VARCHAR,DATEADD(SECOND,ws.RepairTime,0),8),1,2,ws.RepairTime/(60*60)) as RepairTime,
		/*ws.worktime,*/ STUFF(CONVERT(VARCHAR,DATEADD(SECOND,ws.worktime,0),8),1,2,ws.worktime/(60*60)) as worktime,
		ws.startmotohours, ws.motohoursfact,
		u.Name as Dispatcher, w.ShortName as Driver, o.Name as TS
	FROM WaySheets ws
		left join users u on u.id = ws.IdDispatcher
		left join workers w on w.id = ws.Iddriver
		left join objects o on o.id = ws.Idobject
	WHERE ws.datecreate >= cast('01.08.2019' as date)
		/*IdDispatcher = '1E462439-B904-49E4-B7DD-FF15CD06EE9E'*/;

/*SELECT STUFF(CONVERT(VARCHAR,DATEADD(SECOND,@T,0),8),1,2,@T/(60*60)); --перевод секунд в часы*/