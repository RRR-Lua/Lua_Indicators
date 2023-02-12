package.path = getScriptPath() .. '/?.lua;' .. package.path
local utils = require('utils')
local RankedWatchList = {
  list = nil,
  info = nil
}
function RankedWatchList:new (securitiesList, settings)
  local daysBack = settings.daysBack or 0
  local period = settings.period
  local public = {}
    function public:refresh ()
  
    self.list = {}
    self.info = {}
  --------------------------------------------- открытые источники данных для ценных бумаг в списке
    for classCode, secCodes in pairs(securitiesList) do
      for _, secCode in ipairs(secCodes) do
        local datasource = CreateDataSource(classCode, secCode, INTERVAL_D1)
        datasource:SetEmptyCallback()
                      local n=0
                      while(datasource:Size()==0)and(n<100)do sleep(100) n=n+1 end --если не успевает отобразить увеличить sleep 100
        table.sinsert(self.list, {
          classCode = classCode,
          secCode = secCode,
          datasource = datasource,
          params = utils.getSecurityParams(classCode, secCode)
        })
      end
    end
    sleep(1000)
-------------------------------------------------------------------------создаём таблицу
    for _, security in ipairs(self.list) do
        local datasource = security.datasource
        local lastCandleIndex = datasource:Size() - daysBack
      if not self.info.reportDateTime then 
        self.info.reportDateTime = datasource:T(lastCandleIndex)
      end
        local periodAgoCandleIndex = lastCandleIndex - period
      if not self.info.periodAgoDateTime then 
        self.info.periodAgoDateTime = datasource:T(periodAgoCandleIndex)
      end
        local closePeriodAgo = datasource:C(periodAgoCandleIndex)
      local closeTwoPeriodsAgo = datasource:C(periodAgoCandleIndex - period)
        local twoPeriods = 2 * period
      local avgDailyVolSum = 0.0
      for i = lastCandleIndex, lastCandleIndex - twoPeriods + 1, -1 do
        avgDailyVolSum = avgDailyVolSum + math.abs(utils.getPercentDiff(datasource:C(i - 1), datasource:C(i)))
      end
      local avgDailyVol = avgDailyVolSum / twoPeriods
        local close = datasource:C(lastCandleIndex)
        datasource:Close()
      security.datasource = nil
      security.close = close
      security.closePeriodAgo = closePeriodAgo
      security.difference = utils.getPercentDiff(closePeriodAgo, close)
      security.differencePeriodAgo = utils.getPercentDiff(closeTwoPeriodsAgo, closePeriodAgo)
      security.avgDailyVol = avgDailyVol
      security.stopLoss = utils.calculateStopLossPrice({close = close, avgDailyVol = avgDailyVol})
    end
     table.ssort(self.list, function (a, b) return a.differencePeriodAgo > b.differencePeriodAgo end)
    for i, entry in ipairs(self.list) do
      entry.prevRank = i
    end
     table.ssort(self.list, function (a, b) return a.difference > b.difference end)
      return self
  end
  function public:renderToTable(tId)
      Clear(tId)
      local nowDateTimeAsString = utils.formatDateTime()
      local reportDateAsString
    if daysBack == 0 then
      reportDateAsString = nowDateTimeAsString
    else
      reportDateAsString = utils.formatDate(self.info.reportDateTime)
    end
    SetWindowCaption(tId, string.format("[%s] Лучшие акции от %s до %s", nowDateTimeAsString, utils.formatDate(self.info.periodAgoDateTime), reportDateAsString)) -- Выдаёт ошибку в названии от и до не вводится от которой даты считает
     for rank, security in ipairs(self.list) do
      local rowId = InsertRow(tId, -1)                      --Заполним столбцы данными
      SetCell(tId, rowId, 0, security.secCode)
      SetCell(tId, rowId, 1, tostring(security.close), security.close)
      SetCell(tId, rowId, 2, string.format("%."..tostring(security.params.scale).."f", security.stopLoss), security.stopLoss)   --ОШИБКА   _invalid option '%.' to 'format')
      SetCell(tId, rowId, 3, tostring(security.closePeriodAgo), security.closePeriodAgo)
      SetCell(tId, rowId, 4, string.format("%.2f", security.difference), security.difference)
      SetCell(tId, rowId, 5, tostring(rank), rank)
      SetCell(tId, rowId, 6, tostring(security.prevRank), security.prevRank)
      SetCell(tId, rowId, 7, string.format("%.2f", security.avgDailyVol), security.avgDailyVol)
      local color = nil
      if rank > settings.top then                          --Окраска в соответствии изменений
        if security.prevRank <= settings.top then 
          color = settings.color.out
        end
      else
        if security.prevRank > settings.top then 
          color = settings.color.new
        else
          color = settings.color.old
        end    
      end
  if color then SetColor(tId, rowId, QTABLE_NO_INDEX, color, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR) end
    end
  end
    setmetatable(public, self)
    self.__index = self
    public:refresh()
    return public
end
    return RankedWatchList
