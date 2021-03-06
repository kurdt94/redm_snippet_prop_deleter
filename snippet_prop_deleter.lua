---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by kurdt94(https://github.com/kurdt94)
--- DateTime: 11/07/2020 21:26
--- :: ONLY SUPPORTS DELETING ENTITY WHO IS NOT A PED :: ---
local ListActive = true
local PropList = {}

-- {x,y,z}, float, number|str
function newPropDelete(loc,range,model)

    object = {}
    object.pos = {}
    object.pos.x = loc.x
    object.pos.y = loc.y
    object.pos.z = loc.z
    object.range = range
    object.model = model
    object.volume = Citizen.InvokeNative(0xB3FB80A32BAE3065, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, object.range, object.range, object.range) -- _CREATE_VOLUME_SPHERE
    object.itemset = CreateItemset(1)
    object.active = true

    if type(model) ~= 'number' and type(model) == 'string' then
        object.model = GetHashKey(model)
    end

    function object:getPos()
        return  object.pos
    end

    function object:getRange()
        return  object.range
    end

    function object:inRange()
        local player = PlayerPedId()
        local pcoords = GetEntityCoords(player)
        local dist = Vdist(pcoords.x,pcoords.y,pcoords.z,object.pos.x,object.pos.y,object.pos.z)
        if dist < 100 then
            return true
        else
            return false
        end
    end

    function object:getModel()
        return  object.model
    end

    function object:isActive()
        return object.active
    end

    function object:delete()

        ItemsToDelete = {}

        Citizen.CreateThread(function()
            while true do
                Wait(2000)

                if object.volume then
                    Citizen.InvokeNative(0x541B8576615C33DE, object.volume, object.pos.x, object.pos.y, object.pos.z) -- SET_VOLUME_COORDS
                    local itemsFound = Citizen.InvokeNative(0x886171A12F400B89, object.volume, object.itemset, 3)
                    -- 3: Entities
                    if itemsFound then
                        n = 0
                        while n < itemsFound do
                            local item = GetIndexedItemInItemset(n, object.itemset)
                            local model_hash = GetEntityModel(item)
                            if tostring(model_hash) == tostring(object.model) then
                                ItemsToDelete[item] = true
                                print('propDeleter : ' .. object.model .. " deleted!")
                                object.active = false
                            end
                            n = n + 1
                        end

                        for item,active in pairs(ItemsToDelete) do
                            if active then
                                SetEntityAsMissionEntity(item, true, true)
                                while DoesEntityExist(item) do
                                DeleteEntity(item)
                                    Wait(100)
                                end
                                ItemsToDelete[item] = false
                            end
                        end
                        Citizen.InvokeNative(0x20A4BF0E09BEE146, object.itemset) -- _EMPTY_ITEM_SET? [SpanSer]
                    end

                end

            end
            Citizen.InvokeNative(0x43F867EF5C463A53, object.volume) -- _DELETE_VOLUME
        end)
    end

    return object
end

function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

function addPropDelete(prop)
    _prop = prop
    PropList[#PropList+1] = _prop
    ListActive = true
end

Citizen.CreateThread(function ()
    while ListActive do
        Wait(4000)
        if tablelength(PropList) > 0 then
            for k,v in pairs(PropList) do
                if v.isActive() and v.inRange() then
                    v.delete()
                    Wait(1000)
                end
            end
        end
    end
end)

-- int: { X , Y , Z }, float: range, int: model
local prop01 = newPropDelete({x=-236.5215,y=665.1873,z=112.3183},2.0, -1385780198)
addPropDelete(prop01) -- -1385780198 | P_WATERTROUGHSML01X in Valentine [ worth stable ]
