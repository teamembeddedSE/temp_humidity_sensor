
print("Booting")

GPIO2 = 4
TIMER = 0


gpio.mode(GPIO2,gpio.INT,gpio.PULLUP)



function save_setting(name, value)
  file.open(name, 'w') -- you don't need to do file.remove if you use the 'w' method of writing
  file.writeline(value)
  file.close()
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
	
	wifi.setmode(wifi.SOFTAP)
	led1 = 3 -- GPIO 0
	led2 = 4 -- GPIO 2
	gpio.mode(led1, gpio.OUTPUT)
	gpio.mode(led2, gpio.OUTPUT)
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
        data = "<title>Home Automation Using ESP</title>";
        data = data.."<center><h1>Robo India's <br> Tutorial on Home Automation</h1>";
        data = data.."<p>GPIO0 - (Pin3) <a href=\"?req=ON1\"><button>ON</button></a>&nbsp;<a href=\"?req=OFF1\"><button>OFF</button></a></p>";
        data = data.."<p>GPIO2 - (Pin4) <a href=\"?req=ON2\"><button>ON</button></a>&nbsp;<a href=\"?req=OFF2\"><button>OFF</button></a></p>";        
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
        end
        client:send(data);
        client:close();
        collectgarbage();
		--add a savebutton, that will exit the program from apmode and runn the maincode.
		end)
	end)
end

Starttime = tmr.now


--If button is pressed, go in to AP-mode
gpio.trig(GPIO2, 'up', apmode)

wifi.setmode(wifi.STATION)
wifi.sta.config(read_setting(SSID), read_setting(PASS))

--if the timer is met, save the tempvalue to the file
if TIMER == read_setting(timer) then
	--save_temp(sensordata, ((tmr.now()-startTime)/(1000)))
	end

	
Currenttime update



