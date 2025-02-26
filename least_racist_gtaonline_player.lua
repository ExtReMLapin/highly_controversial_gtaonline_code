util.require_natives(1681379138)
local status, natives = pcall(require, "natives-1681379138")
if not status then
    error("Could not natives lib. Make sure it is selected under Stand > Lua Scripts > Repository > natives-1663599433")
end

local status, json = pcall(require, "json")
if not status then
    error("Could not load json lib. Make sure it is selected under Stand > Lua Scripts > Repository > json")
end



local headsMelaninLevel = {
    [0] = 0.04054980880708785,
    [1] = 0.08189821208790185,
    [2] = 0.9897873859654068,
    [3] = 0.9814444225222431,
    [4] = 0.4338904704191211,
    [5] = 0.41373770399391185,
    [6] = 0.2584627526142224,
    [7] = 0.32760224358070966,
    [8] = 0.6805434200512979,
    [9] = 0.572798932701974,
    [10] = 0.45255879064611,
    [11] = 0.46888769882653575,
    [12] = 0.0,
    [13] = 0.023694767796912607,
    [14] = 0.9393819818296267,
    [15] = 1.0,
    [16] = 0.372304743651174,
    [17] = 0.27718744421582714,
    [18] = 0.2535772334808384,
    [19] = 0.6347604686340277,
    [20] = 0.4053383691761323,
    [21] = 0.006711345596273501,
    [22] = 0.0,
    [23] = 0.9792385569656351,
    [24] = 0.9366034507343505,
    [25] = 0.5334093825752173,
    [26] = 0.5052141261466799,
    [27] = 0.30170635486477476,
    [28] = 0.2530633585246446,
    [29] = 0.5830029944388991,
    [30] = 0.6457436189932981,
    [31] = 0.4239079804173201,
    [32] = 0.4083273919863111,
    [33] = 0.002357526498407494,
    [34] = 0.009458624459337508,
    [35] = 1.0,
    [36] = 0.9085507866343456,
    [37] = 0.5060221493416986,
    [38] = 0.49990969152526255,
    [39] = 0.24277769855981743,
    [40] = 0.3007937639621655,
    [41] = 0.46058272731593686,
    [42] = 0.03730845476666967,
    [43] = 0.06811541099429702,
    [44] = 0.10798876330599338
}

local function get_player_skin_data(playerPed)

    -- Define the headBlendData struct
    local headBlendData = {
        shapeFirst = 0,
        shapeSecond = 0,
        shapeThird = 0,
        skinFirst = 0,
        skinSecond = 0,
        skinThird = 0,
        shapeMix = 0,
        skinMix = 0,
        thirdMix = 0
    }

    -- Allocate memory for the headBlendData struct
    local headBlendDataPointer = memory.alloc(80)
    local old_Garbage = memory.read_binary_string(headBlendDataPointer, 64)
    PED.GET_PED_HEAD_BLEND_DATA(playerPed, headBlendDataPointer)
    headBlendData.shapeFirst = memory.read_int(headBlendDataPointer + 0)
    headBlendData.shapeSecond = memory.read_int(headBlendDataPointer + 8)
    headBlendData.skinFirst = memory.read_int(headBlendDataPointer + 24)
    headBlendData.skinSecond = memory.read_int(headBlendDataPointer + 32)
    headBlendData.skinThird = memory.read_int(headBlendDataPointer + 40)
    headBlendData.shapeMix = memory.read_float(headBlendDataPointer + 48)
    headBlendData.skinMix = memory.read_float(headBlendDataPointer + 56)
    headBlendData.thirdMix = memory.read_float(headBlendDataPointer + 64)

    return headBlendData

end

local function getBlacknessLevel(pedID)
    local skinData = get_player_skin_data(pedID)

    local skin1, skin2 = skinData.skinFirst, skinData.skinSecond
    local skinSelector = skinData.skinMix -- 0 -> entirely skin 1, 1 -> enterely skin 2, 0.5 -> mix of two

    if headsMelaninLevel[skin1] == nil or headsMelaninLevel[skin2] == nil then
        return 0.0
    end

    local skin1MelaninLevel = headsMelaninLevel[skin1]
    local skin2MelaninLevel = headsMelaninLevel[skin2]

    local MelaninLevel = ((1 - skinSelector) * skin1MelaninLevel) + (skinSelector * skin2MelaninLevel)
    return MelaninLevel

end

local function rankMelanins()

    local playerList = players.list(true, true, true)
    for k, v in ipairs(playerList) do
        local ped_id = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(v)
        local name = players.get_name(v)

        playerList[k] = {
            id = v,
            name = name,
            Melanin = getBlacknessLevel(ped_id),
            ped_id = ped_id
        }
    end

    table.sort(playerList, function(a, b)
        return a.Melanin < b.Melanin
    end)

    return playerList

end

--CommandRef|CommandUniqPtr menu.list_select(CommandRef parent, Label menu_name, table<any, string> command_names, Label help_text, table<int, table> options, int default_value, function on_change)



menu.action(menu.my_root(), "Announce Melanins", {}, "", function()
    local Melanins = rankMelanins()

    local len = #Melanins

    local startIndex = math.max(1, len - 2)
    chat.send_message("Top 3 black players by score of 'blackness' to target for police brutality : ", false, true, true)

    while startIndex <= len do
        local text = string.format("Rank #%i : %s with a score of %.2f", len - startIndex + 1, Melanins[startIndex].name,
            Melanins[startIndex].Melanin)
        print(text)
        chat.send_message(text, false, true, true)

        startIndex = startIndex + 1
    end

end)


local tracked_blips = {}

menu.action(menu.my_root(), "Mark bascketball americans", {}, "", function()
    local Melanins = rankMelanins()

    for k, blip in ipairs(tracked_blips) do
        HUD.SET_BLIP_ALPHA(blip,0)
    end

    for k, Melanin in ipairs(Melanins) do
        if Melanin.Melanin > 0.8 then

            local this_blip = HUD.ADD_BLIP_FOR_ENTITY(Melanin.ped_id)
            HUD.SET_BLIP_SPRITE(this_blip, 149)
            HUD.SET_BLIP_COLOUR(this_blip, 47)
            HUD.SET_BLIP_ALPHA(this_blip,255)
            table.insert(tracked_blips, this_blip)
        end
    end
end)


menu.action(menu.my_root(), "KICK Melanins", {}, "", function()
    local Melanins = rankMelanins()

   

    for k, Melanin in ipairs(Melanins) do
        if Melanin.Melanin > 0.7 then


            menu.trigger_commands("kick " .. Melanin.name)

           
        end
    end
end)





menu.action(menu.my_root(), "List Melanins in console", {}, "", function()
    local Melanins = rankMelanins()
    for k, Melanin in ipairs(Melanins) do

        print(string.format("%s %.2f", Melanin.name, Melanin.Melanin))
    end
end)
