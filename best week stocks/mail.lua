package.path = getScriptPath() .. '/?.lua;' .. package.path
local RankedWatchList = require('ranked_watch_list')
local settings = {
  color = {
    new = RGB(0, 128, 0),
    old = RGB(225, 255, 0),
    out = RGB(200, 0, 0)  },
    daysBack = 0,
    top = 8,               --Количество лучших которое будем искать
    period = 5,            -- Период за который будем считать
}
local getWatchList = function ()  -- Список акций для отбора добавляем в ручную
  return {
    TQBR = {                    
      "SBER",
"GAZP",
"SPBE",
"PLZL",
"LKOH",
"ALRS",
"LIFE",
"MGNT",
"MOEX",
"GMKN",
"VTBR",
"NVTK",
"SBERP",
"OZON",
"SNGS",
"AFLT",
"CHMF",
"YNDX",
"POLY",
"TCSG",
"ROSN",
"NLMK",
"VKCO",
"MTSS",
"AFKS",
"SNGSP",
"RUAL",
"PIKK",
"MAGN",
"ISKJ",
"TATN",
"IRKT",
"CIAN",
"POSI",
"SIBN",
"PHOR",
"RASP",
"AMEZ",
"TRMK",
"SGZH",
"SELG",
"TRNFP",
"MTLR",
"ETLN",
"SMLT",
"CBOM",
"MTLRP",
"FIVE",
"IRAO",
"BELU",
    }---------------------------------------- или TQBR для реала
  }
end
function main ()
  local tId = AllocTable()
  AddColumn(tId, 0, "Ticker", true, QTABLE_STRING_TYPE, 8) -- акции 
  AddColumn(tId, 1, "Close", true, QTABLE_DOUBLE_TYPE, 8) -- цена закрытия
  AddColumn(tId, 2, "StopLoss", true, QTABLE_DOUBLE_TYPE, 8) -- рекомендуемая цена стоп-лоса
  AddColumn(tId, 3, "Prev. close", true, QTABLE_DOUBLE_TYPE, 10) -- звкрытие на прошлой неделе
  AddColumn(tId, 4, "% diff", true, QTABLE_DOUBLE_TYPE, 6) -- % изменения
  AddColumn(tId, 5, "Rank", true, QTABLE_INT_TYPE, 5) -- классифицирование
  AddColumn(tId, 6, "Prev. Rank", true, QTABLE_INT_TYPE, 9) -- предыдущее значение, классификация
  AddColumn(tId, 7, "Avg. daily vol", true, QTABLE_DOUBLE_TYPE, 13) -- средн.суточный объем за 2 недели
    CreateWindow(tId)
        local rankedWatchList = RankedWatchList:new(getWatchList(), settings)
        rankedWatchList:renderToTable(tId)
end
