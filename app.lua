local config = require('config')
local domoticz = require("domoticz")

local countdown = config.REPORT_COUNTDOWN

local data = {
  power = "0",
  energy = "0"
}

function measure()

  uart.setup(0, 4800, 8, uart.PARITY_NONE, uart.STOPBITS_1, 0)

  uart.on("data", 37,
    function(rawData)
      -- unregister uart.on callback
      uart.on("data")
      uart.setup(0, 115200, 8, uart.PARITY_NONE, uart.STOPBITS_1, 1)
      
      --local d3, d4, d5, d6 = string.byte(rawData, 4, 7) -- voltage
      --local d7, d8, d9, d10 = string.byte(rawData, 8, 11)  -- current
      local d11, d12, d13, d14 = string.byte(rawData, 12, 15) -- active power
      local d15, d16, d17, d18 = string.byte(rawData, 16, 19) -- total energy
      --local d19, d20, d21, d22 = string.byte(rawData, 20, 23) -- power factor
      --local d23, d24, d25, d26 = string.byte(rawData, 24, 27) -- carbon emission

      --local voltage = bit.bor(bit.lshift(d3, 24), bit.lshift(d4, 16), bit.lshift(d5, 8), d6)
      --local current = bit.bor(bit.lshift(d7, 24), bit.lshift(d8, 16), bit.lshift(d9, 8), d10)
    
      -- power = data/10000, W
      data.power = bit.bor(
        bit.lshift(d11, 24), 
        bit.lshift(d12, 16), 
        bit.lshift(d13, 8), 
        d14
      ) / 10000
      -- energy = data/10000, kWh
      data.energy = bit.bor(
        bit.lshift(d15, 24), 
        bit.lshift(d16, 16), 
        bit.lshift(d17, 8), 
        d18
      ) / 10
      
      --print(data.power .. "," .. data.energy)

      countdown = countdown - 1
      if countdown<1 then
        countdown = config.REPORT_COUNTDOWN
        domoticz.updateDevice(config.DOMOTICZ_DEVICE_ID, data.power .. ";" .. data.energy)
      end
    end,
    0
  )

  -- send query command to sensor
  uart.write(0, 0x01, 0x03, 0x00, 0x48, 0x00, 0x08, 0xc4, 0x1a)
end

tmr.alarm(1, config.MEASURE_INTERVAL, tmr.ALARM_AUTO, measure)

