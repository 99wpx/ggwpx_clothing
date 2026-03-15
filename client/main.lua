local QBCore = exports['qb-core']:GetCoreObject()
local menuOpen = false
local activeItems = {}
local originalClothing = {}

local function PlayClothingAnimation(type)
    local anim = Config.Animations[type] or { dict = "clothingtie", anim = "try_tie_positive_a", dur = 1200 }
    local ped = PlayerPedId()
    
    RequestAnimDict(anim.dict)
    while not HasAnimDictLoaded(anim.dict) do Wait(10) end
    
    TaskPlayAnim(ped, anim.dict, anim.anim, 3.0, 3.0, anim.dur, 51, 0, false, false, false)
    Wait(anim.dur)
end

local function GetPedGender()
    local ped = PlayerPedId()
    local hash = GetEntityModel(ped)
    if hash == `mp_m_freemode_01` then return "male" end
    return "female"
end

local function GetCurrentPedState()
    local ped = PlayerPedId()
    local gender = GetPedGender()
    local state = {}
    
    for type, info in pairs(Config.ComponentMap) do
        local currentDrawable, currentTexture
        if info.type == "component" then
            currentDrawable = GetPedDrawableVariation(ped, info.id)
            currentTexture = GetPedTextureVariation(ped, info.id)
        elseif info.type == "prop" then
            currentDrawable = GetPedPropIndex(ped, info.id)
            currentTexture = GetPedPropTextureIndex(ped, info.id)
        elseif info.type == "overlay" then
            local success, overlayValue, colourType, firstColour, secondColour, overlayOpacity = GetPedHeadOverlayData(ped, info.id)
            currentDrawable = overlayValue
        end
        
        local emptyValue = Config.EmptyValues[gender][info.type][info.id]
        
        -- If it matches the "empty" value, it's NOT active (missing)
        if info.type == "component" then
            state[type] = (currentDrawable ~= emptyValue)
        elseif info.type == "prop" then
            state[type] = (currentDrawable ~= -1 and currentDrawable ~= emptyValue)
        elseif info.type == "overlay" then
            state[type] = (currentDrawable ~= 255 and currentDrawable ~= emptyValue)
        end
    end
    return state
end

local function ToggleClothingItem(type, active)
    local ped = PlayerPedId()
    local gender = GetPedGender()
    local info = Config.ComponentMap[type]
    
    if not info then return end
    
    -- Animation in background
    CreateThread(function()
        PlayClothingAnimation(type)
    end)
    
    if active then
        -- Restore original or default
        local original = originalClothing[type]
        if original then
            if info.type == "component" then
                SetPedComponentVariation(ped, info.id, original.drawable, original.texture, 0)
            elseif info.type == "prop" then
                SetPedPropIndex(ped, info.id, original.drawable, original.texture, true)
            elseif info.type == "overlay" then
                SetPedHeadOverlay(ped, info.id, original.drawable, original.opacity or 1.0)
            end
        end
    else
        -- Save original state if not already saved (or if current is NOT empty)
        local current = GetCurrentPedState()[type]
        if current then
            if info.type == "component" then
                originalClothing[type] = { drawable = GetPedDrawableVariation(ped, info.id), texture = GetPedTextureVariation(ped, info.id) }
            elseif info.type == "prop" then
                originalClothing[type] = { drawable = GetPedPropIndex(ped, info.id), texture = GetPedPropTextureIndex(ped, info.id) }
            elseif info.type == "overlay" then
                local success, overlayValue, colourType, firstColour, secondColour, overlayOpacity = GetPedHeadOverlayData(ped, info.id)
                originalClothing[type] = { drawable = overlayValue, opacity = overlayOpacity }
            end
        end
        
        -- Set to empty
        local emptyValue = Config.EmptyValues[gender][info.type][info.id]
        if info.type == "component" then
            SetPedComponentVariation(ped, info.id, emptyValue, 0, 0)
        elseif info.type == "prop" then
            if emptyValue == -1 then
                ClearPedProp(ped, info.id)
            else
                SetPedPropIndex(ped, info.id, emptyValue, 0, true)
            end
        elseif info.type == "overlay" then
            SetPedHeadOverlay(ped, info.id, emptyValue, 0.0)
        end
    end
    
    -- Sync back immediately for UI update
    activeItems = GetCurrentPedState()
    SendNUIMessage({
        action = "updateButtons",
        activeItems = activeItems
    })
end

local cam = nil

local function CreateClothingCam()
    local ped = PlayerPedId()
    local coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 2.0, 0.5) -- Slightly higher
    
    if not cam then
        cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        SetCamCoord(cam, coords.x, coords.y, coords.z)
        PointCamAtEntity(cam, ped, 0.0, 0.0, 0.2, true) -- Point at chest/neck
        SetCamActive(cam, true)
        RenderScriptCams(true, true, 500, true, true)
    end
end

local function DestroyClothingCam()
    if cam then
        RenderScriptCams(false, true, 500, true, true)
        SetCamActive(cam, false)
        DestroyCam(cam, true)
        cam = nil
    end
end

local function CoordinateSyncThread()
    CreateThread(function()
        while menuOpen do
            local ped = PlayerPedId()
            local boneCoords = {}
            local canSync = true

            for row, boneId in pairs(Config.Bones) do
                local worldCoords = GetPedBoneCoords(ped, boneId, 0.0, 0.0, 0.0)
                local onScreen, screenX, screenY = GetScreenCoordFromWorldCoord(worldCoords.x, worldCoords.y, worldCoords.z)
                
                if onScreen then
                    boneCoords[tostring(row)] = { x = screenX * 100, y = screenY * 100 }
                else
                    canSync = false
                end
            end

            if canSync then
                SendNUIMessage({
                    action = "updateBoneCoords",
                    coords = boneCoords
                })
            end
            Wait(10) -- Fast enough for smooth movement
        end
    end)
end

RegisterCommand(Config.Command, function()
    if menuOpen then return end
    
    local ped = PlayerPedId()
    activeItems = GetCurrentPedState()
    
    -- Cache current clothing values that are NOT empty
    for type, info in pairs(Config.ComponentMap) do
        if activeItems[type] then
            if info.type == "component" then
                originalClothing[type] = { drawable = GetPedDrawableVariation(ped, info.id), texture = GetPedTextureVariation(ped, info.id) }
            elseif info.type == "prop" then
                originalClothing[type] = { drawable = GetPedPropIndex(ped, info.id), texture = GetPedPropTextureIndex(ped, info.id) }
            elseif info.type == "overlay" then
                local success, overlayValue, colourType, firstColour, secondColour, overlayOpacity = GetPedHeadOverlayData(ped, info.id)
                originalClothing[type] = { drawable = overlayValue, opacity = overlayOpacity }
            end
        end
    end

    menuOpen = true
    CreateClothingCam()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "show",
        activeItems = activeItems,
        themeColor = Config.DefaultThemeColor
    })
    CoordinateSyncThread()
end)

RegisterKeyMapping(Config.Command, Config.KeybindDescription, 'keyboard', Config.DefaultKeybind)

RegisterNUICallback('toggleItem', function(data, cb)
    ToggleClothingItem(data.type, data.active)
    cb('ok')
end)

RegisterNUICallback('reset', function(data, cb)
    for type, _ in pairs(Config.ComponentMap) do
        if activeItems[type] == false then
            ToggleClothingItem(type, true)
        end
    end
    cb('ok')
end)

RegisterNUICallback('close', function(data, cb)
    menuOpen = false
    DestroyClothingCam()
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = "hide"
    })
    cb('ok')
end)

