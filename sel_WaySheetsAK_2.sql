use navigation;
SELECT /*TOP (100) */
      ws.Date as 'Дата'
      ,ws.Sm as 'Смена'
      ,o.Name as 'Транспорт', w.ShortName as 'ФИО водителя', w1.ShortName as 'ФИО второго водителя'
      ,ws.Num as 'Путевой лист'
      ,u.Name as 'ФИО диспетчера'

      ,ws.StartTimeGraf as 'Время выезда по графику'
      ,ws.EndTimeGraf as 'Время заезда по графику'
      ,ws.StartTimeFact as 'Время выезда по факту'
      ,ws.EndTimeFact as 'Время заезда по факту'
      ,ws.StartTimeFactManual as 'Время выезда ручное'
      ,ws.EndTimeFactManual as 'Время заезда ручное'
      ,ws.StartTotalMileage as 'Пробег на начало'
      --,ws.EndTotalMileage as 'Пробег на конец'
      ,ws.StartTotalMileage+ws.MileageFact as 'Пробег на конец'
      ,ws.MileageFact as 'Пробег'
      ,ws.MileageFactAuto as 'Пробег авто'
      ,ws.StartFuel as 'Топливо на начало'
      ,ws.StartFuelAuto as 'Топливо на начало авто'
      ,ws.EndFuel as 'Топливо на конец'
      ,ws.EndFuelAuto as 'Топливо на конец авто'
      ,ws.Filling as 'Заправка'
      ,ws.FillingAuto as 'Заправка авто'
      ,ws.FuelSpendFact as 'Расход ручное'
      ,ws.FuelSpendFactAuto as 'Расход авто'
      --,ws.FuelFilled as 'Заправка'
      ,ws.FuelSpendNorm as 'Расход по норме'
      ,ws.TimeWorkSpec as 'Работа спецоборудования'
      ,ws.TimeWorkEngine as 'Работа ДВС'
      ,ws.TimeMotion as 'Время движения'
      ,ws.StandTime as 'Время простоев'
      ,ws.RepairTime as 'Время ремонтов'
      ,ws.StartMotoHours as 'Моточасы на начало'
      ,ws.StartMotoHours+ws.MotoHoursFact as 'Моточасы на конец'
      ,ws.MotoHoursFact as 'Отработано моточасов по факту'
      
      /*,ws.* */
  FROM [Navigation].[dbo].[WaySheets] ws
    left join Objects o  on o.id = ws.IdObject
    left join Workers w on w.id = ws.IdDriver
    left join Workers w1 on w1.id = ws.IdSubDriver
    left join Users u on u.ID=ws.IdDispatcher
  /*where date = cast('22.02.2020' as date)*/
  --  and o.Name = 'Вахта 722'
  order by ws.Date,ws.Sm, o.Name,ws.StartTimeGraf