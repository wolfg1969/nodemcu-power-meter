local domoticz = {}

domoticz.updateEnergyCounter = function(apiURL, user, pass, deviceId, sValue)

  local auth_code = crypto.toBase64(user .. ":" .. pass)
  
  http.get(apiURL .. "?type=command&param=udevice&idx=" .. deviceId .. "&nvalue=0&svalue=" .. sValue,
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

