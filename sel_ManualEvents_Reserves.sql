use Navigation;

select * from (
SELECT
		/*r.ID,
		r.IdObject,*/ o.Name as NameTS,
		m.Name as ModelTS,
		r.DateBegin,
		iif(r.DateEnd is null,
			getdate(),
			r.DateEnd) as DateEnd,	
		iif(r.DateEnd is null,
			round(cast(DATEDIFF(SECOND, r.DateBegin, getdate()) as float)/3600,2),
			round(cast(DATEDIFF(SECOND, r.DateBegin, r.DateEnd) as float)/3600,2)) as ReserveTimeHours,
		r.DateCreate,
		r.DateEdit,
		/*r.RealUnset,*/
		r.Info,
		/*r.IdUserAdd*/ u.Name as UserAdd,
		/*r.IdUserEdit*/ u1.Name as UserEdit,
		/*r.IdCause*/
		rc.text
		/*,(case
			when rc.text is null then 1
			when left(rc.text,3)= '4.4' then 0
			else 1
		end) as ktg*/
	FROM Reserves r
		left join Objects o on r.IdObject = o.ID
		left join models m on m.id = o.model
		left join reservecauses rc on r.idcause = rc.id
		left join users u on r.IdUserAdd = u.id
		left join users u1 on r.IdUserAdd = u1.id

union
SELECT
		/*r.ID,
		r.IdObject,*/ o.Name as NameTS,
		m.Name as ModelTS,
		me.DateBegin as DateBegin,
		iif(me.DateEnd > getdate() /*is null*/,
			getdate(),
			me.DateEnd) as DateEnd,	
        iif(me.DateEnd > getdate()--is null
            ,round(cast(DATEDIFF(SECOND, me.DateBegin, getdate()) as float)/3600,2)
            ,round(cast(DATEDIFF(SECOND, me.DateBegin, me.DateEnd) as float)/3600,2))  as ReserveTimeHours,
		me.DateCreate,
        me.DateEdit,
		/*r.RealUnset,*/
		me.Info,
		/*r.IdUserAdd*/ u.Name as UserAdd,
		/*r.IdUserEdit*/ u1.Name as UserEdit,
		/*r.IdCause*/
		ec.name as causes
        /*,
		(case
			when rc.text is null then 1
			--when left(rc.text,3)= '4.4' then 0
			else 1
		end) as kio*/
      FROM [Navigation].[dbo].[ManualEvents] me
  		left join Objects o on me.MObject = o.ID
		left join models m on m.id = o.model
		left join ManualEventCauses ec on me.idcause = ec.id
		left join users u on me.IdUserCreator = u.id
		left join users u1 on me.IdUserEditor = u1.id
        left join ManualEventTypes met on met.ID = ec.IdType
    where met.Code='RESERVE'
    ) sel1
	order by sel1.DateBegin;