use navigation;

SELECT TOP (1000) 
/*ar.[Id]*/
/*      ar.[IdClass]*/
    /*  ,ar.[IdObject]*/
    /*  ,ar.[IdSensor]*/
      ar.[BeginDate] as 'Времая начала простоя'
      ,ar.[EndDate] as 'Времая конца простоя'
      /*,ar.[IdCause]*/
      ,ar.[DateReg] as 'Времая отметки простоя'
      /*,ar.[IdUser]*/
      /*,ar.[CauseDetails]*/
      , ac.Name as 'Группа простоя'
      ,acs.Name as 'Подгруппа простоя'
      ,o.name as 'Имя ТС'
      ,u.Name as 'Имя пользователя'
  FROM [Navigation].[dbo].[AlertReactions] ar
    left join AlertClasses ac on ar.IdClass = ac.Id
    left join AlertCauses acs on ar.IdCause = acs.Id
    left join Objects o on ar.IdObject = o.ID
    left join Users u on ar.IdUser = u.ID
    where ar.BeginDate >= '2019-01-12'
    /*and ar.IdClass not in (8, 48, 9, 30,31,28,29,21,6,26)*/
        and ac.Code='STANDS'
    