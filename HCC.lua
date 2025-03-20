-- HCC - Hardcore Challenges addon

-- Saved variables for each character's challenge status
HCC_Settings = HCC_Settings or {}

-- Create event frame
local HCC_Frame = CreateFrame("Frame")
HCC_Frame:Hide() -- Hide the frame initially
local initialized = false

-- Debug function to ensure messages appear
local function HCC_Debug(msg)
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("[HCC] " .. msg, 1.0, 1.0, 0.0)
    end
end

-- Registering events
local events = {
    "VARIABLES_LOADED",
    "PARTY_INVITE_REQUEST",
    "AUCTION_HOUSE_SHOW",
    "TRADE_SHOW",
    "MAIL_SHOW",
    "DUEL_REQUESTED"
}

for _, event in ipairs(events) do
    HCC_Frame:RegisterEvent(event)
    HCC_Debug("Registered event: " .. event)
end

-- Ensure the frame is visible for event handling
HCC_Frame:Show()

HCC_Frame:SetScript("OnEvent", function()
    local event = event
    if not event then
        HCC_Debug("ERROR: Event name is nil!")
        return
    end

    if event == "VARIABLES_LOADED" then
        initialized = true
        HCC_Debug("Addon initialized.")
        return
    end

    if not initialized then
        HCC_Debug("Ignoring event: " .. event .. " (not initialized)")
        return
    end

    HCC_Debug("Event triggered: " .. event)
    
    if event == "PARTY_INVITE_REQUEST" and HCC_Settings.lonewolf then
        HCC_Debug("Declining party invite...")
        StaticPopup_Hide("PARTY_INVITE")
        DeclineGroup()
        HCC_Debug("Party invite declined and popup hidden due to 'Lone Wolf' challenge.")
    elseif event == "AUCTION_HOUSE_SHOW" and HCC_Settings.killtrader then
        HCC_Debug("Closing Auction House...")
        CloseAuctionHouse()
    elseif event == "TRADE_SHOW" and HCC_Settings.myprecious then
        HCC_Debug("Declining trade...")
        CloseTrade()
    elseif event == "MAIL_SHOW" and HCC_Settings.specialdeliveries then
        HCC_Debug("Closing mailbox...")
        CloseMail()
    elseif event == "DUEL_REQUESTED" and HCC_Settings.lonewolf then
        HCC_Debug("Declining duel...")
        CancelDuel()
    end
end)

-- Slash command registration
SLASH_HCC1 = "/hcc"

SlashCmdList["HCCCHECK"] = function()
    local playerName = UnitName("player")
    HCC_Debug("[HCC] Challenge Status for " .. playerName .. ":")
    for challenge, status in pairs(HCC_Settings) do
        HCC_Debug("- " .. challenge .. ": " .. (status and "Enabled" or "Disabled"))
    end
end

SLASH_HCCCHECK1 = "/hcccheck"
SLASH_HCCCHECK2 = "/hccc"

SlashCmdList["HCC"] = function(msg)
    local command, option = strsplit(" ", msg or "", 2)
    if not command or command == "" then command = "check" end
    
        local command, option = strsplit(" ", msg or "", 2)
    
    if not command or command == "" then command = "check" end
    
    if command == "all" then
        local enable = (option == "on")
        for k in pairs(HCC_Settings) do
            HCC_Settings[k] = enable
        end
        HCC_Debug("All challenges " .. (enable and "enabled" or "disabled") .. ".")
        return
    end
    
    if HCC_Settings[command] ~= nil then
        if option == "on" then
            HCC_Settings[command] = true
            HCC_Debug(command .. " challenge enabled.")
        elseif option == "off" then
            HCC_Settings[command] = false
            HCC_Debug(command .. " challenge disabled.")
        else
            HCC_Debug("Usage: /hcc " .. command .. " on|off")
        end
    else
        HCC_Debug("Usage: /hcc [killertrader|lonewolf|myprecious|specialdeliveries|all|check] on|off")
    end
end

