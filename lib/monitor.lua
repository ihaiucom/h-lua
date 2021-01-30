--- 监听器是一种工具，用于管理周期性操作
---@class hmonitor 监听器
hmonitor = { monitors = {} }

--- 创建一个监听器
---@alias monAction fun(object: any):void
---@alias monRemoveFilter fun(object: any):boolean
---@param key string 唯一key
---@param frequency number 周期间隔，每个周期会把受监听对象回调
---@param action monAction | "function(object) end" 监听操作
---@param removeFilter nil|monRemoveFilter | "function(object) end" 移除监听对象的适配条件
hmonitor.create = function(key, frequency, action, removeFilter)
    if (type(key) ~= "string" or type(frequency) ~= "number" or type(action) ~= "function") then
        return
    end
    if (removeFilter ~= nil and type(removeFilter) ~= "function") then
        return
    end
    if (hmonitor.monitors[key] ~= nil) then
        return
    end
    local obj = Mapping:new()
    local timer = htime.setInterval(frequency, function(_)
        obj:forEach(function(o, oi)
            if (removeFilter == nil or removeFilter(o) ~= true) then
                action(o)
            else
                print_mb("???=" .. key .. hunit.getName(o))
                obj:del(o)
            end
        end)
    end)
    hmonitor.monitors[key] = { object = obj, timer = timer }
end

--- 毁灭一个监听器
---@param key string 唯一key
hmonitor.destroy = function(key)
    if (hmonitor.monitors[key] ~= nil) then
        htime.delTimer(hmonitor.monitors[key].timer)
        hmonitor.monitors[key] = nil
    end
end

--- 检查一个对象是否正在受到监听
---@param key string 唯一key
---@param obj any 监听对象
---@return boolean
hmonitor.isMonitoring = function(key, obj)
    if (hmonitor.monitors[key] ~= nil) then
        return 9527 == hmonitor.monitors[key].object:get(obj)
    end
    return false
end

--- 往监听器添加受监听对象
---@param key string 唯一key
---@param obj any 监听对象
hmonitor.insert = function(key, obj)
    local monitor = hmonitor.monitors[key]
    if (monitor ~= nil) then
        monitor.object:set(obj, 9527)
    end
end

--- 往监听器剔除受监听对象
---@param key string 唯一key
---@param obj any 监听对象
hmonitor.remove = function(key, obj)
    local monitor = hmonitor.monitors[key]
    if (monitor ~= nil) then
        monitor.object:del(obj)
    end
end