
--Starts the runtime check
Starttime = tmr.now

ESP8266_STATUS 
INITIALIZED (1<<0)

function init_ESP8266()

	--init hardware
	GPIO2 = 4 --pushbutton for apmode
	GPIO0 = 2 --should be changed, is the pin for DHT22
	
	--initialize the GPIO for pushbutton
	gpio.mode(GPIO2,gpio.INT,gpio.PULLUP)

	--Maybe works?????????
	ESP8266_STATUS = ESP8266_STATUS | INITIALIZED
	
end

function save_setting(name, value)
  file.open(name, 'w') -- you don't need to do file.remove if you use the 'w' method of writing
  file.writeline(value)
  file.close()
  print("Value on save setting: ")
  print(value)
  return
  
end

function read_setting(name)
  file.open(name)
  result = string.sub(file.readline(value), 1, -2) -- to remove newline character
  file.close()
  return result
end

function save_temp(sensor_data, current_time)
	file.open(data, 'w')
	file.writeline(current_time)
	file.writeline(': ')
	file.writeline(sensor_data)
	file.newline()
	file.close()
end

function get_time()

	conn=net.createConnection(net.TCP, 0) 

	conn:on("connection",function(conn, payload)
				conn:send("HEAD / HTTP/1.1\r\n".. 
						  "Host: google.com\r\n"..
						  "Accept: */*\r\n"..
						  "User-Agent: Mozilla/4.0 (compatible; esp8266 Lua;)"..
						  "\r\n\r\n") 
				end)
				
	conn:on("receive", function(conn, payload)
		print('\nRetrieved in '..((tmr.now()-t)/1000)..' milliseconds.')
		print('Google says it is '..string.sub(payload,string.find(payload,"Date: ")
			   +6,string.find(payload,"Date: ")+35))
		conn:close()
		end) 
	t = tmr.now()    
	conn:connect(80,'google.com') 
	
	--extract the hours
	--convert to a number
	--add 2 modulos 24, or if add 2>24, subtract 24
	--convert the modulo result back to a string
	--insert the string back in to the hour position
	
	--print(tostring(completeTime))
	
	
	return payload

end

function apmode()
	
	print("Starting in AP-mode")
	
	TRUE = 1
	FALSE = 0
	
	while saved == FALSE do
		wifi.setmode(wifi.SOFTAP)
		-- led1 = 3 -- GPIO 0
		-- led2 = 4 -- GPIO 2
		-- gpio.mode(led1, gpio.OUTPUT)
		-- gpio.mode(led2, gpio.OUTPUT)
		srv=net.createServer(net.TCP)
		srv:listen(80,function(conn)
		conn:on("receive", function(client,request)
			local buf = "";
			local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
			if(method == nil)then
				_, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
			end
			local _GET = {}
			if (vars ~= nil)then
				for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
					_GET[k] = v
				end
			end
			data = "<title>Setup for sensor</title>";
			data = data.."<center><h1>Here set the settings for connection and messurements.</h1>";
			data = data.."<h1> format is 192.168.2.1/ssid=(yourssid)&pass=(yourpass)!<br><br>Don't forget the exclamation!!!!</h1>"
			data = data.."<p>GPIO0 - (Pin3) <a href=\"?req=ON1\"><button>ON</button></a>&nbsp;<a href=\"?req=OFF1\"><button>OFF</button></a></p>";
			data = data.."<p>GPIO2 - (Pin4) <a href=\"?req=ON2\"><button>ON</button></a>&nbsp;<a href=\"?req=OFF2\"><button>OFF</button></a></p>";   
			--addfunction to save name of sensor..
			data = data.."<p>Save? <a href=\"?req=SAVED\"><button>YES</button></a>&nbsp";
			local _on,_off = "",""
			if(_GET.req == "ON1")then
				  save_setting('SSID', 10)
			elseif(_GET.req == "OFF1")then
				  save_setting('PASS', 15)
			elseif(_GET.req == "ON2")then
				  save_setting('timer', 100)
			elseif(_GET.req == "OFF2")then
				  save_setting('start', 5)
				  save_setting('end', 2)
			elseif(_GET.rew == "SAVED")then
					saved = TRUE
			end
			client:send(data);
			client:close();
			collectgarbage();
			--add a savebutton, that will exit the program from apmode and runn the maincode.
			end)
		end)
	end
	
	--maybe add some form of check, so if this is the first time the
	--program is run and no settings is initialized, it will automatically
	--start in ap mode
	return
	
end

function senddata()

	print("Sending data")
	
	wifi.setmode(wifi.STATION)
	wifi.sta.config(read_setting(SSID), read_setting(PASS))
	
	--Initialize DHT22 module
	dht22 = require("dht22")
	dht22.read(PIN)
	
	t = dht22.getTemperature()
	h = dht22.getHumidity()
	
	print("temp: ")
	print(t)
	print("humidity: ")
	print(h)
	
	-- release module
	dht22 = nil
	package.loaded["dht22"]=nil

	--NOT FINNISHED
	--Send data from temmp and humiditysensor
	
	print("data sent")
	
	return

end

--Checks if the module is initialized
if ESP8266_STATUS != 0x01 then
	print("Initializing hardware")
	init_ESP8266()
end

--If button is pressed, go in to AP-mode
gpio.trig(GPIO2, 'up', apmode)

--Sends temp and humidity data to server
senddata()
	
--print("Time to sleep zzz") --not implemented yet
--system_deep_sleep((read_setting(start)-read_setting(end)))	
	
CompleteTime = (tmr.now()-startTime)/(1000)
	
--Updates time	
Currenttime = currencttime + CompleteTime




