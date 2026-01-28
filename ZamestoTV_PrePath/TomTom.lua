------------------------------------------------------------
-- Addon Init
------------------------------------------------------------
local addonName = ...
local ADDON = CreateFrame("Frame", addonName)

------------------------------------------------------------
-- Locale
------------------------------------------------------------
local LOCALE = GetLocale()
local function GetLocalizedName(rare)
    if LOCALE == "ruRU" and rare.name.ru then
        return rare.name.ru
    elseif LOCALE == "deDE" and rare.name.de then
        return rare.name.de
    end
    return rare.name.en
end

------------------------------------------------------------
-- Data
------------------------------------------------------------
PreData = {}
PreData.MAP_ID = 241

PreData.RARES = {
    { vignetteID=7007, name={ru="Красноглаз Черепоглод",en="Redeye the Skullchewer",de="Rotauge der Schädelbeißer"} },
    { vignetteID=7043, name={ru="Т'аавихан Освобожденный",en="T'aavihan the Unbound",de="T'aavihan der Ungebundene"} },
    { vignetteID=6995, name={ru="Скат Гнили",en="Ray of Putrescence",de="Fäulnisstrahl"} },
    { vignetteID=6997, name={ru="Икс Кровопадший",en="Ix the Bloodfallen",de="Ix der Blutgefallene"} },
    { vignetteID=6998, name={ru="Командир Икс'ваарта",en="Commander Ix'vaarha",de="Kommandant Ix'vaarha"} },
    { vignetteID=7004, name={ru="Шарфади Бастион Ночи",en="Sharfadi, Bulwark of the Night",de="Sharfadi, Bollwerk der Nacht"} },
    { vignetteID=7001, name={ru="Из'Хаадош Лиминал",en="Ez'Haadosh the Liminality",de="Ez'Haadosh die Liminalität"} },
    { vignetteID=6755, name={ru="Берг Чаробой",en="Berg the Spellfist",de="Berg die Zauberfaust"} },
    { vignetteID=6761, name={ru="Глашатай сумрака Корла",en="Corla, Herald of Twilight",de="Corla, Botin des Zwielichts"} },
    { vignetteID=6988, name={ru="Ревнительница Бездны Девинда",en="Void Zealot Devinda",de="Leerenzelotin Devinda"} },
    { vignetteID=6994, name={ru="Азира Убийца Зари",en="Asira Dawnslayer",de="Asira Dämmerschlächter"} },
    { vignetteID=6996, name={ru="Архиепископ Бенедикт",en="Archbishop Benedictus",de="Erzbischof Benedictus"} },
    { vignetteID=7008, name={ru="Недранд Глазоед",en="Nedrand the Eyegorger",de="Nedrand der Augenschlinger"} },
    { vignetteID=7042, name={ru="Палач Линтельма",en="Executioner Lynthelma",de="Scharfrichterin Lynthelma"} },
    { vignetteID=7005, name={ru="Густаван Глашатай Финала",en="Gustavan, Herald of the End",de="Gustavan, Herold des Untergangs"} },
    { vignetteID=7009, name={ru="Коготь Бездны – проклинарий",en="Voidclaw Hexathor",de="Leerenklaue Hexathor"} },
    { vignetteID=7006, name={ru="Зеркалвайз",en="Mirrorvise",de="Spiegelzwicker"} },
    { vignetteID=7003, name={ru="Салигрум Наблюдатель",en="Saligrum the Observer",de="Saligrum der Beobachter"} },
    { vignetteID=7340, name={ru="Глас Затмения",en="Voice of the Eclipse",de="Stimme der Finsternis"} },
}

------------------------------------------------------------
-- Fast lookup
------------------------------------------------------------
local RARE_BY_VIGNETTE = {}
for _, rare in ipairs(PreData.RARES) do
    RARE_BY_VIGNETTE[rare.vignetteID] = rare
end

------------------------------------------------------------
-- TomTom
------------------------------------------------------------
local activeWaypoints = {}

local function AddWaypoint(mapID, x, y, vignetteID)
    if not TomTom then return end
    if activeWaypoints[vignetteID] then return end

    local rare = RARE_BY_VIGNETTE[vignetteID]
    if not rare then return end

    local uid = TomTom:AddWaypoint(mapID, x, y, {
        title = GetLocalizedName(rare),
        persistent = false,
        minimap = true,
        world = true,
    })

    activeWaypoints[vignetteID] = uid
end

local function RemoveWaypoint(vignetteID)
    if not TomTom then return end

    local uid = activeWaypoints[vignetteID]
    if uid then
        TomTom:RemoveWaypoint(uid)
        activeWaypoints[vignetteID] = nil
    end
end

------------------------------------------------------------
-- Vignette scanning
------------------------------------------------------------
local activeVignettes = {}

local function ScanVignettes()
    local seen = {}

    for _, guid in ipairs(C_VignetteInfo.GetVignettes()) do
        local info = C_VignetteInfo.GetVignetteInfo(guid)
        if info and RARE_BY_VIGNETTE[info.vignetteID] then
            seen[info.vignetteID] = true

            if not activeVignettes[info.vignetteID] then
                local pos = C_VignetteInfo.GetVignettePosition(guid, PreData.MAP_ID)
                if pos then
                    local x, y = pos:GetXY()
                    AddWaypoint(PreData.MAP_ID, x, y, info.vignetteID)
                    activeVignettes[info.vignetteID] = true
                end
            end
        end
    end

    -- remove disappeared rares
    for vignetteID in pairs(activeVignettes) do
        if not seen[vignetteID] then
            RemoveWaypoint(vignetteID)
            activeVignettes[vignetteID] = nil
        end
    end
end

------------------------------------------------------------
-- Events
------------------------------------------------------------
ADDON:RegisterEvent("VIGNETTES_UPDATED")
ADDON:RegisterEvent("VIGNETTE_MINIMAP_UPDATED")

ADDON:SetScript("OnEvent", function()
    ScanVignettes()
end)

