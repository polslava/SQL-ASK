use navigation;

SELECT /*TOP (1000) 
aa.[Id]
      ,aa.[IdClass]*/
      ac.Name
      --,aa.[IdObject]
      ,o.Name
      ,aa.[BeginDate]
      ,aa.[EndDate]
      ,aa.[DateReg]
      ,aa.[IdUser]
      ,aa.[IdSensor]
  FROM [Navigation].[dbo].[AlertApprove] aa
    left join Objects o on o.ID = aa.IdObject
    left join AlertClasses ac on aa.IdClass=ac.Id
      where [begindate] >= cast('21.11.2019 20:00:00' as datetime)
        and o.Name = 'БелАЗ 05'
      
    order by [begindate]