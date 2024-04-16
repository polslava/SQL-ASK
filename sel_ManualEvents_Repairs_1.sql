/*
выгрузка ремонтов --, объединённая из старого и нового редактора
только из нового так как признак КИО и КТГ используется
*/

use Navigation;


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
            ,round(cast(DATEDIFF(SECOND, me.DateBegin, me.DateEnd) as float)/3600,2))  as RepairTimeHours,
		me.DateCreate,
        me.DateEdit,
		/*r.RealUnset,*/
		me.Info,
		/*r.IdUserAdd*/ u.Name as UserAdd,
		/*r.IdUserEdit*/ u1.Name as UserEdit,
		/*r.IdCause*/
		mec.name as causes
        /*,
		(case
			when rc.text is null then 1
			--when left(rc.text,3)= '4.4' then 0
			else 1
		end) as kio*/
		,(case when PATINDEX('%KTG~%',	mec.attributes)>0 then 
    substring(mec.attributes,
					PATINDEX('%KTG~%',	mec.attributes)+len('KTG~'),
					CHARINDEX(char(10),mec.attributes,PATINDEX('%KTG~%',mec.attributes))-PATINDEX('%KTG~%', mec.attributes)-len('KTG~')) 
          else 0
          end)
as aff_KTG
,(case when PATINDEX('%KIO~%',	mec.attributes)>0 then 
    substring(mec.attributes,
					PATINDEX('%KIO~%',	mec.attributes)+len('KIO~'),
					CHARINDEX(char(10),mec.attributes,PATINDEX('%KIO~%',mec.attributes))-PATINDEX('%KIO~%', mec.attributes)-len('KIO~')) 
          else 0
          end)
as aff_KIO
      FROM [Navigation].[dbo].[ManualEvents] me
  		left join Objects o on me.MObject = o.ID
		left join models m on m.id = o.model
		left join ManualEventCauses mec on me.idcause = mec.id
		left join users u on me.IdUserCreator = u.id
		left join users u1 on me.IdUserEditor = u1.id
        left join ManualEventTypes met on met.ID = mec.IdType
    where met.Code='REPAIR'

   order by DateBegin;