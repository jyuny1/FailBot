function FailBot_OnLoad()
FailBot_Options = {
	["enabled"] = true,
	["enabledstatustext"] = "|cff00ff00Enabled|r",
	["announce"] = "RAID",
	["announcestatustext"] = "Raid",
	["resetonrelog"] = true,
	["resetonrelogstatustext"] = "|cff00ff00Enabled|r",
	["resetoncombat"] = false,
	["resetoncombatstatustext"] = "|cffff0000Disabled|r",
	["showbombbots"] = true,
	["showbombbotsstatustext"] = "|cff00ff00Enabled|r",
};
FailBot_Frame:RegisterEvent("ADDON_LOADED");
FailBot_Frame:RegisterEvent("PLAYER_REGEN_DISABLED");
SlashCmdList["FAILBOT"]=FailBot_Command
SLASH_FAILBOT1="/failbot"
SLASH_FAILBOT2="/fb"
FailBot_LastEvent1 = {}
FailBot_LastEvent2 = {}
FailBot_ChargeCounter = {}
FailBot_ThaddiusAlive = true;
FailBot_WightLastAction = 0
end

function FailBot_Command(cmd)
cmd = string.lower(cmd)
if cmd=="enable" then
	FailBot_Options["enabled"] = true
	FailBot_Options["enabledstatustext"] = "|cff00ff00Enabled|r"
	DEFAULT_CHAT_FRAME:AddMessage("丁丁現形器啟動。");
	FailBot_Frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
elseif cmd=="disable" then
	FailBot_Options["enabled"] = false
	FailBot_Options["enabledstatustext"] = "|cffff0000Disabled|r"
	DEFAULT_CHAT_FRAME:AddMessage("丁丁現形器關閉。");
	FailBot_Frame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
elseif cmd=="announce raid" then
	FailBot_Options["announce"] = "RAID"
	FailBot_Options["announcestatustext"] = "Raid"
	DEFAULT_CHAT_FRAME:AddMessage("丁丁行為將發佈於團隊頻道。");
elseif cmd=="announce party" then
	FailBot_Options["announce"] = "PARTY"
	FailBot_Options["announcestatustext"] = "Party"
	DEFAULT_CHAT_FRAME:AddMessage("丁丁行為將發佈於隊伍頻道。");
elseif cmd=="announce say" then
	FailBot_Options["announce"] = "SAY"
	FailBot_Options["announcestatustext"] = "Say"
	DEFAULT_CHAT_FRAME:AddMessage("丁丁行為將發佈於一般頻道。");
elseif cmd=="announce yell" then
	FailBot_Options["announce"] = "YELL"
	FailBot_Options["announcestatustext"] = "Yell"
	DEFAULT_CHAT_FRAME:AddMessage("丁丁行為將發佈於大喊頻道。");
elseif cmd=="announce guild" then
	FailBot_Options["announce"] = "GUILD"
	FailBot_Options["announcestatustext"] = "Guild"
	DEFAULT_CHAT_FRAME:AddMessage("丁丁行為將發佈於公會頻道。");
elseif cmd=="announce officer" then
	FailBot_Options["announce"] = "OFFICER"
	FailBot_Options["announcestatustext"] = "Officer"
	DEFAULT_CHAT_FRAME:AddMessage("丁丁行為將發佈於幹部頻道。");
elseif cmd=="announce self" then
	FailBot_Options["announce"] = "SELF"
	FailBot_Options["announcestatustext"] = "Self"
	DEFAULT_CHAT_FRAME:AddMessage("丁丁行為將只有使用者能看到。");
elseif string.find(cmd,"announce channel") then
	for channel in string.gmatch(cmd,"announce channel (.+)") do
		FailBot_Options["channelnumber"] = tonumber(channel)
		if (FailBot_Options["channelnumber"] == nil) or (FailBot_Options["channelnumber"] < 1) or (FailBot_Options["channelnumber"] > 10) then
			DEFAULT_CHAT_FRAME:AddMessage("請輸入頻道型態，通常為1或者0。");
			return;
		end
		FailBot_Options["announce"] = "CHANNEL"
		FailBot_Options["announcestatustext"] = "Channel "..FailBot_Options["channelnumber"]..""
		DEFAULT_CHAT_FRAME:AddMessage("丁丁行為將發佈於頻道： "..FailBot_Options["channelnumber"]..".");
		return;
	end
	DEFAULT_CHAT_FRAME:AddMessage("請輸入頻道型態，通常為1或者0。");
	return;
elseif cmd=="wipe" or cmd=="pause" then
	DEFAULT_CHAT_FRAME:AddMessage("六十秒內不回報丁丁錯誤。");
	FailBot_Frame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	Chronos.scheduleByName("ResumeFailReporting", 60, FailBot_OnEvent, "ResumeFailReporting");
elseif cmd=="reset" then
	FailBot_FailCount = {}
	DEFAULT_CHAT_FRAME:AddMessage("丁丁計數器已重置。");
elseif cmd=="resetonrelog enable" then
	FailBot_Options["resetonrelog"] = true
	FailBot_Options["resetonrelogstatustext"] = "|cff00ff00Enabled|r"
	DEFAULT_CHAT_FRAME:AddMessage("現在開始，每次重新登入都將重置丁丁計數器。");
elseif cmd=="resetonrelog disable" then
	FailBot_Options["resetonrelog"] = false
	FailBot_Options["resetonrelogstatustext"] = "|cffff0000Disabled|r"
	DEFAULT_CHAT_FRAME:AddMessage("丁丁計數器將沿用於各區段。");
elseif cmd=="resetoncombat enable" then
	FailBot_Options["resetoncombat"] = true
	FailBot_Options["resetoncombatstatustext"] = "|cff00ff00Enabled|r"
	DEFAULT_CHAT_FRAME:AddMessage("進入戰鬥後將重置丁丁計數器。");
elseif cmd=="resetoncombat disable" then
	FailBot_Options["resetoncombat"] = false
	FailBot_Options["resetoncombatstatustext"] = "|cffff0000Disabled|r"
	DEFAULT_CHAT_FRAME:AddMessage("丁丁計數器將沿用於各區段。");
elseif cmd=="showbombbots enable" then
	FailBot_Options["showbombbots"] = true
	FailBot_Options["showbombbotsstatustext"] = "|cff00ff00Enabled|r"
	DEFAULT_CHAT_FRAME:AddMessage("將顯示米米倫炸彈機器人訊息。");
elseif cmd=="showbombbots disable" then
	FailBot_Options["showbombbots"] = false
	FailBot_Options["showbombbotsstatustext"] = "|cffff0000Disabled|r"
	DEFAULT_CHAT_FRAME:AddMessage("不再顯示米米倫炸彈機器人訊息。");
else
	DEFAULT_CHAT_FRAME:AddMessage("丁丁現形器指令：");
	DEFAULT_CHAT_FRAME:AddMessage("/fb |cff00ccffenable|r/|cff00ccffdisable|r: 開啟或者關閉丁丁計數器。 ("..FailBot_Options["enabledstatustext"]..")");
	DEFAULT_CHAT_FRAME:AddMessage("/fb |cff00ccffannounce|r [|cff00ccffraid|r/|cff00ccffparty|r/|cff00ccffsay|r/|cff00ccffyell|r/|cff00ccffguild|r/|cff00ccffofficer|r/|cff00ccffself|r/|cff00ccffchannel|r (|cff00ccff1|r-|cff00ccff10|r)]: 將丁丁回報於頻道 (|cff00ff00"..FailBot_Options["announcestatustext"].."|r)");
	DEFAULT_CHAT_FRAME:AddMessage("/fb |cff00ccffwipe|r: 停止丁丁回報六十秒。");
	DEFAULT_CHAT_FRAME:AddMessage("/fb |cff00ccffreset|r: 重置所有丁丁計數器。");
	DEFAULT_CHAT_FRAME:AddMessage("/fb |cff00ccffresetonrelog|r [|cff00ccffenable|r/|cff00ccffdisable|r]: 每次上線都重置丁丁計數器。 ("..FailBot_Options["resetonrelogstatustext"]..")");
	DEFAULT_CHAT_FRAME:AddMessage("/fb |cff00ccffresetoncombat|r [|cff00ccffenable|r/|cff00ccffdisable|r]: 每次進入戰鬥都重置丁丁計數器。 ("..FailBot_Options["resetoncombatstatustext"]..")");
	DEFAULT_CHAT_FRAME:AddMessage("/fb |cff00ccffshowbombbots|r [|cff00ccffenable|r/|cff00ccffdisable|r]: 開啟或者關閉米米倫炸彈機器人訊息。 ("..FailBot_Options["showbombbotsstatustext"]..")");
end
end






function FailBot_OnEvent(event,...)
local timestamp, type, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags = select(1,...)

if event=="ResumeFailReporting" then
	DEFAULT_CHAT_FRAME:AddMessage("繼續回報丁丁錯誤");
	FailBot_Frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	return;
end

if event=="ADDON_LOADED" then
	if arg1=="FailBot" then
		if FailBot_Options["resetoncombat"] == nil then
			FailBot_Options["resetoncombat"] = false
			FailBot_Options["resetoncombatstatustext"] = "|cffff0000Disabled|r"
		end
		if FailBot_Options["showbombbots"] == nil then
			FailBot_Options["showbombbots"] = true
			FailBot_Options["showbombbotsstatustext"] = "|cff00ff00Enabled|r"
		end
		if FailBot_Options["enabled"] then
			FailBot_Frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
		end
		if FailBot_Options["resetonrelog"] then
			FailBot_FailCount = {}
		end
	end
	return;
end

if (event=="PLAYER_REGEN_DISABLED") then -- entering combat
	if FailBot_Options["resetoncombat"] then
		FailBot_FailCount = {}
	end
	return;
end
	
if (sourceName=="Mirror Image") or (destName=="Mirror Image") then
	return;
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--4/29 22:38:40.135  SPELL_ENERGIZE,0x0000000000000000,nil,0x80000000,0x0500000002BFA226,"Cimsir",0x514,63337,"Saronite Vapors",0x20,12800,0
--4/29 22:38:40.135  SPELL_DAMAGE,0x0000000000000000,nil,0x80000000,0x0500000002BFA226,"Cimsir",0x514,63338,"Saronite Vapors",0x20,20480,8387,32,5120,0,0,nil,nil,nil
if (type=="SPELL_ENERGIZE") then
	local spellName,_,amount = select(10,...)
	if (spellName=="薩倫煙霧") then
		if bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 then
			if (amount == 12800) then
				FailBot_AddFail(destName,"薩倫煙霧")
			end
		end
	end
end












if (type=="SPELL_DAMAGE") then
	local spellName = select(10,...)
	if bit.band(sourceFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 then
		if (spellName=="裂光彈") then
			if FailBot_ChargeCounter[sourceName] == nil then
				FailBot_ChargeCounter[sourceName] = 1
				FailBot_LastEvent1[sourceName] = timestamp
			else
				if (timestamp - FailBot_LastEvent1[sourceName]) > 5 then
					FailBot_ChargeCounter[sourceName] = 1
				elseif (timestamp - FailBot_LastEvent1[sourceName]) > 1 then
					FailBot_ChargeCounter[sourceName] = FailBot_ChargeCounter[sourceName] + 1
				end
				FailBot_LastEvent1[sourceName] = timestamp
			end
			if FailBot_ChargeCounter[sourceName] == 3 then
				FailBot_AddFail(sourceName,"裂光彈")
				FailBot_ChargeCounter[sourceName] = 0
			end
		end
	end
end








if (type=="SPELL_DAMAGE") then
	local spellName = select(10,...)
	if bit.band(sourceFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 then
		if (spellName=="重力彈") then
			if FailBot_ChargeCounter[sourceName] == nil then
				FailBot_ChargeCounter[sourceName] = 1
				FailBot_LastEvent1[sourceName] = timestamp
			elseif (timestamp - FailBot_LastEvent1[sourceName]) < 1 then
				FailBot_ChargeCounter[sourceName] = FailBot_ChargeCounter[sourceName] + 1
				FailBot_LastEvent1[sourceName] = timestamp
			else
				FailBot_ChargeCounter[sourceName] = 1
				FailBot_LastEvent1[sourceName] = timestamp
			end
			if FailBot_ChargeCounter[sourceName] == 2 then
				FailBot_AddFail(sourceName,"重力彈")
				FailBot_ChargeCounter[sourceName] = 0
			end
		end
	end
end













--4/28 19:52:13.198  SPELL_DAMAGE,0x0000000000000000,nil,0x80000000,0x05000000027ED384,"Shinen",0x514,64733,"Devouring Flame",0x4,9471,0,4,1002,0,0,nil,nil,nil
if (type=="SPELL_DAMAGE") then
	local spellName = select(10,...)
	if (spellName=="吞噬烈焰") then
		if bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 then
			if FailBot_LastEvent1[destName] == nil then
				FailBot_LastEvent1[destName] = timestamp
				FailBot_AddFail(destName,"fire")
			else
				if (timestamp - FailBot_LastEvent1[destName]) > 4 then
					FailBot_AddFail(destName,"吞噬烈焰")
				end
				FailBot_LastEvent1[destName] = timestamp
			end
		end
	end
end


if (type=="SPELL_DAMAGE") then
	local spellName = select(10,...)
	if (spellName=="滲洩野性精華") then
		if bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 then
			if FailBot_LastEvent1[destName] == nil then
				FailBot_LastEvent1[destName] = timestamp
				FailBot_AddFail(destName,"滲洩野性精華")
			else
				if (timestamp - FailBot_LastEvent1[destName]) > 4 then
					FailBot_AddFail(destName,"滲洩野性精華")
				end
				FailBot_LastEvent1[destName] = timestamp
			end
		end
	end
end




if (type=="SPELL_DAMAGE") then
	local spellName = select(10,...)
	if (spellName=="熾焰") then
		if bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 then
			if FailBot_LastEvent1[destName] == nil then
				FailBot_LastEvent1[destName] = timestamp
				FailBot_AddFail(destName,"熾焰")
			else
				if (timestamp - FailBot_LastEvent1[destName]) > 4 then
					FailBot_AddFail(destName,"熾焰")
				end
				FailBot_LastEvent1[destName] = timestamp
			end
		end
	end
end



--Line 435383 : 4/17 19:50:50.740  SPELL_DAMAGE,0x0000000000000000,nil,0x80000000,0x05000000027ECAFC,"Turyia",0x514,63884,"Death Ray",0x8,14400,0,8,2000,0,0,nil,nil,nil
--Line 435447 : 4/17 19:50:51.493  SPELL_DAMAGE,0x0000000000000000,nil,0x80000000,0x05000000027ECAFC,"Turyia",0x514,63884,"Death Ray",0x8,12800,3981,8,4000,0,0,nil,nil,nil
if (type=="SPELL_DAMAGE") then
	local spellName = select(10,...)
	if (spellName=="死亡射線") then
		if bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 then
			if FailBot_LastEvent1[destName] == nil then
				FailBot_LastEvent1[destName] = timestamp
				FailBot_AddFail(destName,"死亡射線")
			else
				if (timestamp - FailBot_LastEvent1[destName]) > 3 then
					FailBot_AddFail(destName,"死亡射線")
				end
				FailBot_LastEvent1[destName] = timestamp
			end
		end
	end
end




--4/16 18:50:56.578  SPELL_DAMAGE,0x0000000000000000,nil,0x80000000,0x05000000027ECB89,"Logicalness",0x514,64875,"Sapper Explosion",0x40,67542,45099,64,28421,0,0,nil,nil,nil
if (type=="SPELL_DAMAGE") then
	local spellName = select(10,...)
	if (spellName=="工兵爆炸") then
		if bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 then
			FailBot_AddFail(destName,"工兵爆炸")
		end
	end
end



--4/16 21:10:24.039  SPELL_DAMAGE,0xF1300083EC02D966,"Faceless Horror",0x10a48,0x05000000027ECC71,"Boniface",0x514,63721,"Shadow Crash",0x20,8103,0,32,2457,0,0,nil,nil,nil
--4/16 22:06:17.885  SPELL_DAMAGE,0xF1300081F702D928,"General Vezax",0x10a48,0x05000000027FCDFE,"Kosie",0x514,62659,"Shadow Crash",0x20,9413,0,32,2285,0,0,nil,nil,nil
if (type=="SPELL_DAMAGE") then
	local spellName = select(10,...)
	if (spellName=="暗影暴擊") then
		if bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 then
			FailBot_AddFail(destName,"暗影暴擊")
		end
	end
end





--4/16 18:20:24.295  SPELL_DAMAGE,0xF130008061018374,"Thorim",0x8010a48,0x0500000001E8AF39,"Thefeint",0x514,62466,"Lightning Charge",0x8,8977,0,8,3966,0,0,nil,nil,nil
if (type=="SPELL_DAMAGE") then
	local spellName = select(10,...)
	if (spellName=="閃電充能") and sourceName=="索林姆" then
		if bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 then
			FailBot_AddFail(destName,"閃電充能")
		end
	end
end







--4/16 16:22:38.229  SPELL_DISPEL,0x05000000027EF48C,"Veev",0x511,0xF13000824A00E5AD,"Corrupted Servitor",0x8010a48,47488,"Shield Slam",0x1,63559,"Bind Life",8,BUFF
if (type=="SPELL_DISPEL") then
	local extraSpellName = select(13,...)
	if (extraSpellName=="束縛生命") then
		FailBot_AddFail(sourceName,"驅散束縛生命")
	end
end







--4/16 01:06:26.414  SPELL_DAMAGE,0x0000000000000000,nil,0x80000000,0x05000000027ECA9C,"Cn",0x514,62465,"Runic Smash",0x4,6544,0,4,3116,0,0,nil,nil,nil
if (type=="SPELL_DAMAGE") then
	local spellName = select(10,...)
	if (spellName=="符能潰擊") then
		if bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 then
			if FailBot_LastEvent1[destName] == nil then
				FailBot_LastEvent1[destName] = timestamp
				FailBot_AddFail(destName,"符能潰擊")
			else
				if (timestamp - FailBot_LastEvent1[destName]) > 4 then
					FailBot_AddFail(destName,"符能潰擊")
				end
				FailBot_LastEvent1[destName] = timestamp
			end
		end
	end
end







--3/20 19:22:43.389  SPELL_DAMAGE,0xF130008059000703,"Stormcaller Brundir",0x8000a48,0x01000000007C5537,"Vanen",0x512,61878,"Overload",0x8,17460,0,8,2000,0,0,nil,nil,nil
if (type=="SPELL_DAMAGE") then
	local spellName = select(10,...)
	if (spellName=="超載") and sourceName=="風暴召喚者布倫迪爾" then
		if bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 then
			FailBot_AddFail(destName,"超載")
		end
	end
end

--3/16 19:50:05.275  SPELL_INTERRUPT,0x0000000000000000,nil,0x80000000,0x01000000007CED8E,"Mute",0x514,62681,"Flame Jets",0x4,49238,"Lightning Bolt",8
if (type=="SPELL_INTERRUPT") then
	local spellName = select(10,...)
	if (spellName=="烈焰噴洩") or spellName=="地面震顫" then
		if bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 then
			FailBot_AddFail(destName,"被斷法")
		end
	end
end







--2/26 20:15:03.498  SPELL_AURA_APPLIED,0x0000000000000000,nil,0x80000000,0x01000000007C66FF,"Museedad",0x4000514,61969,"Flash Freeze",0x10,DEBUFF
--add a check for hodir's room name
if (type=="SPELL_AURA_APPLIED") then
	local spellName = select(10,...)
	if (spellName=="閃霜") then
		if bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 then
			if (GetMinimapZoneText()=="The Halls of Winter") then -- makes sure not on yogg
				FailBot_AddFail(destName,"閃霜")
			end
		end
	end
end



--3/13 20:56:28.111  SPELL_DAMAGE,0xF1300084FF001E10,"Rocket Strike",0xa48,0x01000000007C088D,"Veev",0x511,63041,"Rocket Strike",0x4,676800,657890,4,200000,0,0,nil,nil,nil
if (type=="SPELL_DAMAGE") then
	local spellName = select(10,...)
	if (spellName=="火箭攻擊") then
		if bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 then
			FailBot_AddFail(destName,"火箭攻擊")
		end
	end
end


--3/13 21:05:11.205  SPELL_DAMAGE,0xF1500083730020DC,"VX-001",0x10a48,0x01000000007F4785,"Lawlpurge",0x514,63293,"P3Wx2 Laser Barrage",0x40,19400,1821,64,0,0,0,nil,nil,nil
if (type=="SPELL_DAMAGE") then
	local spellName = select(10,...)
	if (spellName=="P3Wx2雷射彈幕") then
		if bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 then
			if FailBot_LastEvent1[destName] == nil then
				FailBot_LastEvent1[destName] = timestamp
				FailBot_AddFail(destName,"P3Wx2雷射彈幕")
			else
				if (timestamp - FailBot_LastEvent1[destName]) > 3 then
					FailBot_AddFail(destName,"P3Wx2雷射彈幕")
				end
				FailBot_LastEvent1[destName] = timestamp
			end
		end
	end
end


--3/13 21:17:23.756  SPELL_DAMAGE,0xF150008298002210,"Leviathan Mk II",0x10a48,0xF1300007AC0025A9,"Treant",0x1114,63631,"Shock Blast",0x8,97000,92908,8,0,0,0,nil,nil,nil
if (type=="SPELL_DAMAGE") then
	local spellName = select(10,...)
	if (spellName=="Shock Blast") then
		if bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 then
			FailBot_AddFail(destName,"震爆")
		end
	end
end

--hit by big bot = fails at kiting ?

--4/16 13:16:23.167  SPELL_DAMAGE,0xF13000863A00929D,"Proximity Mine",0xa48,0x05000000027ECCF4,"Hotalicious",0x512,63009,"Explosion",0x4,22500,16608,4,2500,0,0,nil,nil,nil
if (type=="SPELL_DAMAGE") then
	local spellName = select(10,...)
	if (spellName=="爆炸") and (sourceName=="環罩地雷") then
		if bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 then
			if FailBot_LastEvent1[destName] == nil then
				FailBot_LastEvent1[destName] = timestamp
				FailBot_AddFail(destName,"地雷爆炸")
			else
				if (timestamp - FailBot_LastEvent1[destName]) > 2 then
					FailBot_AddFail(destName,"地雷爆炸")
				end
				FailBot_LastEvent1[destName] = timestamp
			end
		end
	end
end





--4/16 13:35:12.750  SPELL_DAMAGE,0xF13000842C0094E3,"Bomb Bot",0xa48,0x05000000027ECCA5,"Naddia",0x512,63801,"Bomb Bot",0x4,20216,4025,4,5054,0,0,nil,nil,nil
if (type=="SPELL_DAMAGE") then
	local spellName = select(10,...)
	if (spellName=="炸彈機器人") then
		if (GetMinimapZoneText()=="The Spark of Imagination") then
			if FailBot_Options["showbombbots"] then
				if bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 then
					FailBot_AddFail(destName,"炸彈機器人")
				end
			end
		end
	end
end

















-------------------------------------

--[[
if (type=="SPELL_DISPEL") then
	local extraSpellName = select(13,...)
	if (extraSpellName=="Mutating Injection") then
		SendChatMessage(""..sourceName.." fails at not dispelling.","RAID");
	end
end
--]]



if (type=="SPELL_DAMAGE") then
	local spellName = select(10,...)
	if (spellName=="Flame Tsunami") then
		if bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 then
			if FailBot_LastEvent1[destName] == nil then
				FailBot_LastEvent1[destName] = timestamp
				FailBot_AddFail(destName,"lava waves")
			else
				if (timestamp - FailBot_LastEvent1[destName]) > 10 then
					FailBot_AddFail(destName,"lava waves")
				end
				FailBot_LastEvent1[destName] = timestamp
			end
		end	
	elseif (spellName=="Eruption") then
		if bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 then
			if FailBot_LastEvent1[destName] == nil then
				FailBot_LastEvent1[destName] = timestamp
				FailBot_AddFail(destName,"dancing")
			else
				if (timestamp - FailBot_LastEvent1[destName]) > 2 then
					FailBot_AddFail(destName,"dancing")
				end
				FailBot_LastEvent1[destName] = timestamp
			end
		end
		
	elseif (spellName=="Focused Eyebeam") then
		if bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 then
			if FailBot_LastEvent1[destName] == nil then
				FailBot_LastEvent1[destName] = timestamp
				FailBot_AddFail(destName,"eyebeams")
			else
				if (timestamp - FailBot_LastEvent1[destName]) > 5 then
					FailBot_AddFail(destName,"eyebeams")
				end
				FailBot_LastEvent1[destName] = timestamp
			end
		end
		
	end	
end

if (type=="SPELL_DAMAGE") then
	local spellName = select(10,...)
	if (spellName=="Void Blast") or (spellName=="Frost Breath") or (spellName=="Explode") then
		if (string.find(sourceName,"Fissure")) or (sourceName=="Sapphiron") or (sourceName=="Living Poison") then
			if (spellName=="Void Blast") then
				FailBot_FailType = "void zones"
			elseif (spellName=="Frost Breath") then
				FailBot_FailType = "ice blocks"
			elseif (spellName=="Explode") then
				FailBot_FailType = "frogger"
			end
			if bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 then
				FailBot_AddFail(destName,FailBot_FailType)
			end
		end
	end
end

if (type=="SPELL_CAST_START") then
	local spellName = select(10,...)
	if (spellName=="Polarity Shift") then
		if (sourceName=="Thaddius") then
			FailBot_ChargeCounter = {}
			FailBot_ThaddiusAlive = true;
		end
	end
end

if (type=="UNIT_DIED") then
	if (destName=="Thaddius") then
		FailBot_ThaddiusAlive = false;
	end
end

if (destName=="Stalagg") or (destName=="Feugen") then
	FailBot_WightLastAction = timestamp
end

if (FailBot_ThaddiusAlive) then
	if (type=="SPELL_DAMAGE") then
		local spellName = select(10,...)
		if bit.band(sourceFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 then
			if (spellName=="Positive Charge") or (spellName=="Negative Charge") then
				if FailBot_ChargeCounter[sourceName] == nil then
					FailBot_ChargeCounter[sourceName] = 1
					FailBot_LastEvent1[sourceName] = timestamp
				elseif (timestamp - FailBot_LastEvent1[sourceName]) < 2 then
					FailBot_ChargeCounter[sourceName] = FailBot_ChargeCounter[sourceName] + 1
					FailBot_LastEvent1[sourceName] = timestamp
				else
					FailBot_ChargeCounter[sourceName] = 1
					FailBot_LastEvent1[sourceName] = timestamp
				end
				if FailBot_ChargeCounter[sourceName] == 3 then
					FailBot_AddFail(sourceName,"polarity")
				end
			end
		end
	end
end

--add in actual check for mob death here, raid emote since it doesnt generate combat one
if (timestamp - FailBot_WightLastAction) < 60 then
	if (type=="SPELL_AURA_APPLIED") then
		local spellName = select(10,...)
		if (spellName=="Slime") then
			if bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 then
				FailBot_WightLastAction = timestamp
				if FailBot_LastEvent2[destName] == nil then
					FailBot_AddFail(destName,"jumping")
				elseif (timestamp - FailBot_LastEvent2[destName]) > 5 then
					FailBot_AddFail(destName,"jumping")
				end
			end
		end
	elseif (type=="SPELL_AURA_REMOVED") then
		local spellName = select(10,...)
		if (spellName=="Slime") then
			if bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 then
				FailBot_LastEvent2[destName] = timestamp
			end
		end
	end
end

end

function FailBot_AddFail(name,failure)
if FailBot_FailCount[name] == nil then
	FailBot_FailCount[name] = 1
else
	FailBot_FailCount[name] = FailBot_FailCount[name] + 1
end

if FailBot_Options["announce"] == "SELF" then
	DEFAULT_CHAT_FRAME:AddMessage(""..name.." 目前為止因 "..failure.." 丁丁了 ("..FailBot_FailCount[name]..") 次！");
elseif FailBot_Options["announce"] == "CHANNEL" then
	SendChatMessage(""..name.." ！別又犯 "..failure.." 丁丁錯誤啊！("..FailBot_FailCount[name]..")",FailBot_Options["announce"],nil,FailBot_Options["channelnumber"]);
else
	SendChatMessage(""..name.." ！別又犯 "..failure.." 丁丁錯誤啊！("..FailBot_FailCount[name]..")",FailBot_Options["announce"]);
end

end
