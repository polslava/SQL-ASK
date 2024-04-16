/*выборка тревог с простым интерфейсом уведомления
*/

SELECT /*TOP (1000) [Id]
      ,[IdClass]*/
      ac.Name
      /*,[IdObject]*/
      ,o.Name
      ,a.[begin_date]
      ,a.[end_date]
      ,a.[DateCreate]
      ,a.[Lat]
      ,a.[Lon]
      ,a.[Descr]
      /*,a.[IdSensor]*/
      /*,(cast(a.[end_date]-a.[begin_date]) as time) as time_long*/
  FROM [navSections].[dbo].[Alerts_201911] a
    left join [Navigation].dbo.alertclasses ac
        on a.IdClass = ac.id
    left join [Navigation].dbo.Objects o
        on a.IdObject = o.id
    where a.[begin_date] >= cast('21.11.2019 20:00:00' as datetime)
        and o.Name='БелАЗ 09'
    order by a.[begin_date]