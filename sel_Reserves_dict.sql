SELECT /*TOP (10)*/ mec.[ID]
      ,mec.[IdType]
      ,mec.[Name]
      ,[Parent]
      ,[Enterprise]
      ,mec.[Code]
      ,[Attributes]
  
  ,PATINDEX('%KTG~%',	mec.attributes)
  ,PATINDEX('%KIO~%',	mec.attributes)
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

  FROM [Navigation].[dbo].[ManualEventCauses] mec
/*    left join ManualEventTypes met on met.ID = mec.IdType
    where met.Code='RESERVE'

*/