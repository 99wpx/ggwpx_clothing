Config = {}

Config.Command = "clothing" -- Command name to open the menu
Config.DefaultKeybind = "Y" -- Default keybind
Config.KeybindDescription = "Open Clothing Toggle Menu"
Config.DefaultThemeColor = '#C8A96A' -- Gold (Default) #C8A96A

-- Mapping UI types to Game Component/Prop/Overlay IDs
Config.ComponentMap = {
    -- Components (SetPedComponentVariation)
    ["mask"] = { id = 1, type = "component" },
    ["hair"] = { id = 2, type = "component" },
    ["undershirt"] = { id = 8, type = "component" },
    ["vest"] = { id = 9, type = "component" },
    ["jacket"] = { id = 11, type = "component" },
    ["pants"] = { id = 4, type = "component" },
    ["shoes"] = { id = 6, type = "component" },
    ["gloves"] = { id = 3, type = "component" },
    ["bag"] = { id = 5, type = "component" },
    ["neck"] = { id = 7, type = "component" },
    ["beard"] = { id = 1, type = "overlay" }, -- Facial Hair
    
    -- Props (SetPedPropIndex)
    ["hat"] = { id = 0, type = "prop" },
    ["glasses"] = { id = 1, type = "prop" },
    ["ear"] = { id = 2, type = "prop" },
    ["watch"] = { id = 6, type = "prop" },
    ["bracelet"] = { id = 7, type = "prop" }
}

-- Default "Empty" values (may vary by ped model)
Config.EmptyValues = {
    male = {
        component = {
            [1] = 0, [2] = 0, [3] = 15, [4] = 21, [5] = 0, [6] = 34, [7] = 0, [8] = 15, [9] = 0, [11] = 15
        },
        prop = {
            [0] = -1, [1] = -1, [2] = -1, [6] = -1, [7] = -1
        },
        overlay = {
            [1] = 255 -- No facial hair
        }
    },
    female = {
        component = {
            [1] = 0, [2] = 0, [3] = 15, [4] = 15, [5] = 0, [6] = 35, [7] = 0, [8] = 15, [9] = 0, [11] = 15
        },
        prop = {
            [0] = -1, [1] = -1, [2] = -1, [6] = -1, [7] = -1
        },
        overlay = {
            [1] = 255
        }
    }
}

-- Animations
Config.Animations = {
    ["hat"] = { dict = "mp_masks@standard_car@ds@", anim = "put_on_mask", dur = 800 },
    ["mask"] = { dict = "mp_masks@standard_car@ds@", anim = "put_on_mask", dur = 800 },
    ["jacket"] = { dict = "missmic4", anim = "michael_tux_fidget", dur = 1500 },
    ["vest"] = { dict = "missmic4", anim = "michael_tux_fidget", dur = 1500 },
    ["undershirt"] = { dict = "missmic4", anim = "michael_tux_fidget", dur = 1500 },
    ["pants"] = { dict = "re@construction", anim = "out_of_breath", dur = 1300 },
    ["shoes"] = { dict = "random@domestic", anim = "pickup_low", dur = 1200 },
    ["gloves"] = { dict = "nmt_3_rcm-10", anim = "cs_nigel_dual-10", dur = 1200 },
    ["beard"] = { dict = "missheadheist_thirsty@waiting", anim = "idle_a", dur = 1200 }
}

-- Bone Mapping for the lines
Config.Bones = {
    [1] = 31086, -- Head
    [2] = 39317, -- Neck
    [3] = 24817, -- Spine2
    [4] = 18905, -- Left Hand
    [5] = 58271  -- Left Knee
}
