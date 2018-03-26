local config = require('config')
local domoticz = require("domoticz")

local countdown = config.REPORT_INTERVAL

local data = {
  power = "0",
  energy = "0"
}

function reportToDomoticz()
  domoticz.updateEnergyCounter(
    config.DOMOTICZ_API_URL, 
    config.DOMOTICZ_USER,
    config.DOMOTICZ_PASSWD,
    config.DOMOTICZ_DEVICE_ID,
    data.power .. ";" .. data.energy
  )
end

function measure()
  print("measure")
  
  --[[
  tmr.alarm(1, measureTimeout, tmr.ALARM_SINGLE,
    function()
      --uart.alt(0)
      uart.setup(0, 115200, 8, uart.PARITY_NONE, uart.STOPBITS_1, 1)
      uart.on("data")
      print("Timed out. Restored UART.")
    end
  )
  print("timeout timer is set up")
  --]]

  --uart.alt(1)
  uart.setup(0, 4800, 8, uart.PARITY_NONE, uart.STOPBITS_1, 0)

  uart.on("data", 37,
    function(rawData)
      --tmr.stop(1)

      -- unregister uart.on callback
      uart.on("data")
      --uart.alt(0)
      uart.setup(0, 115200, 8, uart.PARITY_NONE, uart.STOPBITS_1, 1)
      print("uart restored")
      
      --local d3, d4, d5, d6 = string.byte(rawData, 4, 7)
      --local d7, d8, d9, d10 = string.byte(rawData, 8, 11)
      local d11, d12, d13, d14 = string.byte(rawData, 12, 15)
      local d15, d16, d17, d18 = string.byte(rawData, 16, 19)

      --local v = bit.bor(bit.lshift(d3, 24), bit.lshift(d4, 16), bit.lshift(d5, 8), d6)
      --local c = bit.bor(bit.lshift(d7, 24), bit.lshift(d8, 16), bit.lshift(d9, 8), d10)
      
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
      
      print(data.power .. "," .. data.energy)

      countdown = countdown - 1
      if countdown == 0 then
        countdown = config.REPORT_INTERVAL 
        reportToDomoticz() 
      end
      --[[
      --]]
    end,
    0
  )

  -- send query command to sensor
  uart.write(0, 0x01, 0x03, 0x00, 0x48, 0x00, 0x08, 0xc4, 0x1a)
end

tmr.alarm(0, 1000, tmr.ALARM_AUTO, measure)  -- every second
