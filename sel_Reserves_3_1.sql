use Navigation;
SELECT
		/*r.ID,
		r.IdObject,*/ o.Name as NameTS,
		m.Name as ModelTS,
		r.DateBegin,
		iif(r.DateEnd is null,
			getdate(),
			r.DateEnd) as DateEnd,	
		/*day(r.DateEnd - r.DateBegin) as ReserveTime,
		month(r.DateEnd - r.DateBegin),*/
		/*iif(r.DateEnd is null,
			concat(DATEPART(year,(getdate() - r.DateBegin))-1900,'лет ', DATEPART(month,(getdate() - r.DateBegin))-1,'мес. ', DATEPART(day,(getdate() - r.DateBegin)), 'дн. '),
			concat(DATEPART(year,(r.DateEnd - r.DateBegin))-1900,'лет ', DATEPART(month,(r.DateEnd - r.DateBegin))-1,'мес. ', DATEPART(day,(r.DateEnd - r.DateBegin)), 'дн. ')) As ReserveDaysLong,
		iif(r.DateEnd is null,
			DATEPART(year,(getdate() - r.DateBegin))-1900,
			DATEPART(year,(r.DateEnd - r.DateBegin))-1900) as ReserveYear,
		iif(r.DateEnd is null,
			DATEPART(month,(getdate() - r.DateBegin))-1,
			DATEPART(month,(r.DateEnd - r.DateBegin))-1) as ReserveMonth,
		iif(r.DateEnd is null,
			DATEPART(day,(getdate() - r.DateBegin)),
			DATEPART(day,(r.DateEnd - r.DateBegin))) as ReserveDay,
		iif(r.DateEnd is null,
			cast((getdate() - r.DateBegin) as time),
			cast((r.DateEnd - r.DateBegin) as time)) as ReserveTime,
		(r.DateEnd - r.DateBegin) as ReserveTime1,*/
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
		rc.text,
		(case
			when rc.text is null then 1
			when left(rc.text,3)= '4.4' then 0
			else 1
		end) as ktg
	FROM Reserves r
		left join Objects o on r.IdObject = o.ID
		left join models m on m.id = o.model
		left join reservecauses rc on r.idcause = rc.id
		left join users u on r.IdUserAdd = u.id
		left join users u1 on r.IdUserAdd = u1.id

	order by r.DateBegin;