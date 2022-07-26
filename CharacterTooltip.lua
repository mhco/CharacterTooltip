local _, CharacterTooltip = ...

local AddonColor = "|cFF2E8CFF"

-- Sets slash commands.
function initSlash ()
    SLASH_CHARACTERTOOLTIP1 = "/charactertooltip"
    SlashCmdList["CHARACTERTOOLTIP"] = function(msg)
        msg = msg:lower()
        if (msg == '' or msg == 'version' or msg == 'v') then
            local version = GetAddOnMetadata("CharacterTooltip", "Version");
            print(AddonColor .. "Character Tooltip|r version " .. version .. ". Type '/charactertooltip help' for more info.")
		elseif (msg == 'help' or msg == 'h') then
            print(AddonColor .. "Chracter Tooltip:|r\n"
                    .. "/charactertooltip both work to control the addon.\n"
                    .. "/charactertooltip startup - toggles the 'Character Tooltip loaded!' message when your UI loads.\n"
                    .. "/charactertooltip guildrank - toggles the number after the guild rank.\n"
                    .. "/charactertooltip version - displays current version of the addon.")
		elseif msg == "startup" then
			toggleStartupMessage()
			return
        elseif (msg == 'index' or msg == 'rank' or msg == 'ranks' or msg == 'guildrank' or msg == 'guildranks') then
			toggleGuildRankIndex()
		elseif (msg ~= '') then
			print(AddonColor .. "Character Tooltip |rcouldn't recognize what you wanted to do. Please look at your typing and try again.")
        end

		return
    end
end

-- Toggles the startup message on or off.
function toggleStartupMessage ()
    CharacterTooltipOptions.showStartupMessage = not CharacterTooltipOptions.showStartupMessage
    if CharacterTooltipOptions.showStartupMessage then
        print(AddonColor .. "Character Tooltip|r startup message enabled")
    else
        print(AddonColor .. "Character Tooltip|r startup message disabled")
    end
end

-- Toggles the startup message on or off.
function toggleGuildRankIndex ()
    CharacterTooltipOptions.guildRankIndex = not CharacterTooltipOptions.guildRankIndex
    if CharacterTooltipOptions.guildRankIndex then
        print(AddonColor .. "Character Tooltip:|r guild rank index enabled")
    else
        print(AddonColor .. "Character Tooltip:|r guild rank index disabled")
    end
end

function Character_Tooltip (self, event, ...)
	if (event == "ADDON_LOADED") then
        if ... == "CharacterTooltip" then
			CharacterTooltipOptions = CharacterTooltipOptions == nil and {} or CharacterTooltipOptions
			CharacterTooltipOptions.showStartupMessage = CharacterTooltipOptions.showStartupMessage == nil and true or CharacterTooltipOptions.showStartupMessage
			CharacterTooltipOptions.guildRankIndex = CharacterTooltipOptions.guildRankIndex == nil and true or CharacterTooltipOptions.guildRankIndex
		
			-- Startup message to show users how to use the addon
			if CharacterTooltipOptions.showStartupMessage then
				print(AddonColor .. "Character Tooltip|r loaded! Type '/charactertooltip help' for commands and controls.")
			end

			initSlash()

            self:UnregisterEvent("ADDON_LOADED")
		end
	elseif (event ~= "UPDATE_MOUSEOVER_UNIT") then
		print(event)
	end

	if (UnitIsPlayer("mouseover")) then
		local name = UnitName("mouseover");
		local raceName, raceFile, raceID = UnitRace("mouseover");
		local description = ""
		local isOk = 0; -- check for "Party/Player Options" tooltip

		local lines = GameTooltip:NumLines(true);
		for i = 1, lines do
			local lineText = _G["GameTooltipTextLeft"..i]:GetText();

			if (string.match(lineText, name) or string.match(lineText, raceName)) then
				isOk = isOk + 1;
			end

			if (i > 1 and (string.match(lineText, "%)") or string.match(lineText, raceName))) then
				description = lineText;
			end
		end

		if (isOk >= 2) then
			local CLASS_COLORS = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS;
			local _, class = UnitClass("mouseover");
			local color = CLASS_COLORS[class];
			local guildName, guildRank, guildRankIndex = GetGuildInfo("mouseover");
			local englishFaction, localizedFaction = UnitFactionGroup("mouseover");
			
			_G["GameTooltipTextLeft1"]:SetTextColor(color.r, color.g, color.b);

			local line = _G["GameTooltipTextLeft2"];

			if (guildName ~= nil) then
				if CharacterTooltipOptions.guildRankIndex then
					line:SetText(guildRank .. ' (' .. guildRankIndex .. ') |cFFFFFFFFof |r<' .. guildName .. '>');
				else
					line:SetText(guildRank .. ' |cFFFFFFFFof |r<' .. guildName .. '>');
				end

				if (englishFaction == "Alliance") then
					line:SetTextColor(0.18, 0.55, 1);
				else
					line:SetTextColor(1, 0.2, 0);
				end
			end

			if (guildName ~= nil) then
				if (lines < 3) then
					GameTooltip:AddLine(description, 1, 1, 1, nil);
				else
					line = _G["GameTooltipTextLeft3"];
					line:SetText(description);
					--line:SetTextColor(1, 0.82, 0);
				end

				if (lines < 4 and UnitIsPVP("mouseover")) then
					GameTooltip:AddLine("PvP", 1, 1, 1, nil);
				end
			end

			GameTooltip:Show()
		end
	end
end
