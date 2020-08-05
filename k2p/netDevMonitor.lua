#!/usr/bin/lua

local lsocket  = require("socket")
local http = require("socket.http")  
local ltn12 = require("ltn12")  

function mylog(log)
    local gFile = io.open("/tmp/netDevMonitor.log" ,"a");
    gFile:write("\n"..log)
    gFile:close()
end

function sleep(sec)
    lsocket.select(nil,nil, sec)
end

function HttpUtil()  
    local self = {}  
    -- get请求  
    self.httpget = function(u)  
        local t = {}  
        local r, c, h = http.request{  
            url = u,  
            -- 如果传入的是table的话， 就需要用一个容器来接收http body的内容， 也就是sink那个参数  
            sink = ltn12.sink.table(t)}  
        return r, c, h, table.concat(t)  
    end  
  
    self.httpPost = function(u, payload, t_cnt)  
        local response_body = {}  
        local cnt_type =  ((t_cnt == nil and "application/x-www-form-urlencoded") or "application/json")
        --print(cnt_type)
        local res, code = http.request{  
            url = u,  
            method = "POST",  
            headers =  {  
                ["Content-Type"] = cnt_type,
                ["Content-Length"] = #payload 
            },  
            source = ltn12.source.string(payload),  
            sink = ltn12.sink.table(response_body)  
        }  
        res = table.concat(response_body)  
        return res,code  
  
    end  
  
    return self  
end  

function mysplit(inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={} ; i=0
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            t[i] = str
            i = i + 1
    end
    return t
end

function filter(element) 
    element = string.upper(element)
    local tbl = {"00:BB:3A:79:67:D8"}
    for k, v in ipairs(tbl) do
        if v == element then
            return false
        end
    end
    return true
end

-- get the relationship between mac and dev-name from /var/dhcp.releases
--[[ $ cat /var/dhcp.leases
1545663178 bc:9f:ef:c7:b6:b3 192.168.2.128 iPhone 01:bc:9f:ef:c7:b6:b3
]]
function bind_mac_name()
    local tbl_mac_name = {}
    local file = io.open("/var/dhcp.leases" ,"r")
    for line in file:lines() do
        local res = mysplit(line, '%s')
        if (#res == 4) then  -- 1: mac, 2: ip, 3: name
            local mac = string.upper(res[1])
	    if (filter(mac)) then
            	tbl_mac_name[mac] = res[3]
            end
        end
    end
    return tbl_mac_name
end

function print_tbl(tbl) 
    if (tbl == nil) then
        return
    end
    for k, v in pairs(tbl) do
        if (type(v) == "table") then
            for k2 , v2 in pairs(v) do
                print(k2.." : "..v2)
            end
        else
            print(k.." : "..v)
        end
    end
end


--[[
   $ cat /proc/net/statsPerIp
Ip    mac     startTime   rxBytes    txBytes    rtInBytes    rtOutBytes IFTYPE
192.168.2.128 BC:9F:EF:C7:B6:B3 39300 57952385 2649959 404 349 1 
]]
function bind_mac_ip()
    local tbl_mac_ip = {}
    local file = io.open("/proc/net/statsPerIp", "r")
    for line in file:lines() do
        local ip, mac = string.match(line, "(%d+%.%d+%.%d+%.%d+)%s+(%S+)%s+.+")
        if (mac ~= nil and filter(mac)) then 
            tbl_mac_ip[string.upper(mac)] = ip
        end
    end
    file:close()
    return tbl_mac_ip    
end

--a 中有不存在于 b
function diff_mac_ip_tbl(ls_a, ls_b)
    local ls_leave = {}
    for mac, ip in pairs(ls_a) do
        if (ls_b[mac] == nil) then
            table.insert(ls_leave, mac)
        end
    end
    return ls_leave
end

function build_str(tbl_mac_name, ls_mac) 
    if #ls_mac == 0 then
        return nil
    end
    local tbl_name = {}
    for i, v in pairs(ls_mac) do  
        table.insert(tbl_name, ((tbl_mac_name[v] ~= nil and tbl_mac_name[v]) or v))
    end
    return table.concat(tbl_name, "-")
end

function send2ifttt(httputil, txt)
    local message = [[ {"value1": "]]..txt..[["}]]
    --print(message)
    local IFTTT_KEY = 'dV0Aizo1Ik-K95DdnpVlHJ'
    local IFTTT_EV = 'esphome'
    local ifttt_webhook_url = "https://maker.ifttt.com/trigger/"..IFTTT_EV.."/with/key/"..IFTTT_KEY
    local res,code = httputil.httpPost(ifttt_webhook_url, message, "json")  
    if code ~= 200 then  
          mylog("error; st_code:"..code.."; msg: "..res)
    end
end

local tbl_mac_name = bind_mac_name()
--print_tbl(tbl_mac_name)
local tbl_mac_ip = bind_mac_ip()
--print_tbl(tbl_mac_ip)

local httputil = HttpUtil() 
while( true ) do
    sleep(5)
    local tbl_mac_ip_old = tbl_mac_ip
    tbl_mac_ip = bind_mac_ip()
    local leave = diff_mac_ip_tbl(tbl_mac_ip_old, tbl_mac_ip)
    local new = diff_mac_ip_tbl(tbl_mac_ip, tbl_mac_ip_old)
    --print_tbl(leave)
    --print_tbl(new)
    if (#new >0) then
        tbl_mac_name = bind_mac_name()
    end
    local str_leave = build_str(tbl_mac_name, leave)
    local str_new = build_str(tbl_mac_name, new)
    if (str_leave ~= nil or str_new ~= nil) then
        local tm = os.date("%Y-%m-%d-%H:%M:%S", os.time())
        local msg = ((str_leave ~= nil and "  [Leave]"..str_leave) or "")
        msg = msg..((str_new ~= nil and "  [Join]"..str_new) or "")
        msg = msg.."["..tm.."]"
        --send2fangtang(httputil, msg)
        mylog(msg)
        send2ifttt(httputil, msg)
    end
end
--EOF
