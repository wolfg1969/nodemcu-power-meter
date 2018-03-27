local config = require("config")
local domoticz = {}

domoticz.updateDevice = function(deviceId, sValue)

  local auth_code = crypto.toBase64(config.DOMOTICZ_USER .. ":" .. config.DOMOTICZ_PASSWD)
  
  http.get(config.DOMOTICZ_API_URL .. "?type=command&param=udevice&idx=" .. deviceId .. "&nvalue=0&svalue=" .. tostring(sValue),
    "Authorization: Basic " .. auth_code .. "\r\n",
    function(code, data)
      if (code < 0) then
        print("HTTP request failed")
      else
        print(code, data)
      end
    end
  )
end

return domoticz

