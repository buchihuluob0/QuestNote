local q = LibStub("AceAddon-3.0"):NewAddon("QuestNote", "AceHook-3.0")
if not q then return end


local BFQuest_TestPatterns;
local BFQuest_QUEST_PROGRESS;
local BFQuest_QUEST_COMPLETED;
local BFQCompletedMatchPattern;

if (GetLocale() == "zhCN") then
	BFQuest_TestPatterns = "(.*)：%s*([-%d]+)%s*/([-%d]+)%s*";
	BFQuest_QUEST_PROGRESS = "大脚任务进度提示: ";
	BFQuest_QUEST_COMPLETED = " (任务完成)";
	BFQCompletedMatchPattern = "（完成）";
	BFQCompletedSuffix = "(完成)";

	TEAMNOTICE_CLASS={
		["DEATHKNIGHT"]='] "冰冷视界审视灵魂，死亡领域压迫众生"。',
		["DRUID"]='] "沉睡在翡翠的梦境之中"。',
		["WARLOCK"]='] "现恶魔之能，执混乱之箭，行厄运之灾"。',
		["WARRIOR"]='] "天堂在左，战神在右；在荣耀之路上无所畏惧"。',
		["HUNTER"]='] "各位观众，狩猎开始"！',
		["MAGE"]='] "让敌人感受冰与火的洗礼吧"！',
		["PRIEST"]='] "左手光明、右手暗影。正、邪只在一念间"。',
		["PALADIN"]='] "手握圣光，却望不到天堂"。',
		["SHAMAN"]='] "愿元素之力顾佑着你"。',
		["ROGUE"]='] "心跳做伴，利刃为伍，死亡与暗影之舞者"。',
	};

	Raid_Ad_Text = "欢迎加入本团队，希望我们合作愉快，拥有一次快乐的冒险旅程。";
	TEAMNOTICE_SET_PARTY_COMMENT = "请输入要发送的小队公告信息";
	TEAMNOTICE_SET_ADD_COMMENT = "请输入要发送的团队公告信息";
	TEAMNOTICE_PARTY = "<大脚组队提示>";
	TEAMNOTICE_RAID = "<大脚团队提示>";
	TEAMNOTICE_JOIN = "欢迎新的小队成员  [";
	Info_Text_Ad = "|cff00adef您可通过大脚组队工具设置选项自定义团队公告。|r";
elseif (GetLocale() == "zhTW") then
	BFQuest_TestPatterns = "(.*):%s*([-%d]+)%s*/([-%d]+)%s*";
	BFQuest_QUEST_PROGRESS = "大腳任務進度提示: ";
	BFQuest_QUEST_COMPLETED = " (任務完成)";
	BFQCompletedMatchPattern = "%(完成%)";
	BFQCompletedSuffix = "(完成)";

	TEAMNOTICE_CLASS={
		["DEATHKNIGHT"]='] "冰冷視界審視靈魂，死亡領域壓迫眾生"。',
		["DRUID"]='] "沉睡在翡翠的夢境之中"。',
		["WARLOCK"]='] "現惡魔之能，執混亂之箭，行厄運之災"。',
		["WARRIOR"]='] "天堂在左，戰神在右；在榮耀之路上無所畏懼"。',
		["HUNTER"]='] "各位觀眾，狩獵開始"！',
		["MAGE"]='] "讓敵人感受冰與火的洗禮吧"！',
		["PRIEST"]='] "左手光明、右手暗影。正、邪只在一念間"。',
		["PALADIN"]='] "手握聖光，卻望不到天堂"。',
		["SHAMAN"]='] "愿元素之力顧佑著你"。',
		["ROGUE"]='] "心跳做伴，利刃為伍，死亡與暗影之舞者"。',
	};

	Raid_Ad_Text = "歡迎加入本團隊，希望我們合作愉快，擁有一次快樂的冒險旅程。"
	TEAMNOTICE_SET_PARTY_COMMENT = "請輸入要發送的小隊公告信息";
	TEAMNOTICE_SET_ADD_COMMENT = "請輸入要發送的團隊公告信息";
	TEAMNOTICE_PARTY = "<大腳小隊提示>";
	TEAMNOTICE_RAID = "<大腳團隊提示>";
	TEAMNOTICE_JOIN = "歡迎新的小隊成員  [";
	Info_Text_Ad = "|cff00adef您可通過大腳組隊工具設置選項自定義團隊公告。|r";
else
	BFQuest_TestPatterns = "(.*):%s*([-%d]+)%s*/([-%d]+)%s*";
	BFQuest_QUEST_PROGRESS = "Quest progress: ";
	BFQuest_QUEST_COMPLETED = " (Quest Completed)";
	BFQCompletedMatchPattern = "%(Complete%)";
	BFQCompletedSuffix = "(Complete)";

	TEAMNOTICE_CLASS={
		["DEATHKNIGHT"]='] "DEATHKNIGHT"',
		["DRUID"]='] "DRUID"',
		["WARLOCK"]='] "WARLOCK"',
		["WARRIOR"]='] "WARRIOR"',
		["HUNTER"]='] "Let the hunt begin"',
		["MAGE"]='] "MAGE"',
		["PRIEST"]='] "PRIEST"',
		["PALADIN"]='] "PALADIN"',
		["SHAMAN"]='] "SHAMAN"',
		["ROGUE"]='] "ROGUE"',
	};

	Raid_Ad_Text = "Welcome to the team, I hope we can cooperate happily, with a happy adventure."
	TEAMNOTICE_SET_PARTY_COMMENT = "Input to send the Team announced information";
	TEAMNOTICE_SET_ADD_COMMENT = "Input to send the Raid announced information";
	TEAMNOTICE_PARTY = "<BF Party hint>";
	TEAMNOTICE_RAID = "<BF Raid hint>";
	TEAMNOTICE_JOIN = "Welcome to the new team members  [";
	Info_Text_Ad = "|cff00adefYou can set BF team tools options to customize the team announcement.|r";
end

-- 小队通报模块
local broad = q:NewModule("Broadcast","AceEvent-3.0")
broad:Enable()
local FastQuestInfo = true;
local FastQuestTable = {};

local function BFQuest_GetTable()
	local tempTable={}
	for i=1, GetNumQuestLogEntries(), 1 do
		local questLogTitleText, _, _, _, _, isComplete = GetQuestLogTitle(i);
		if questLogTitleText then
			tempTable[questLogTitleText]=isComplete
		end
	end
	return tempTable
end

local function BFQuest_SendNotification(silent)
	if not silent then
		local uQuestTable={}
		DelayCall(function()
			uQuestTable =BFQuest_GetTable();
			for key,value in pairs(uQuestTable) do
				if FastQuestTable then
					if not FastQuestTable[key] then
						SendChatMessage(key..BFQuest_QUEST_COMPLETED, (IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT") or (IsInRaid() and "RAID") or "PARTY");
						break;
					end
				end
			end
			FastQuestTable=uQuestTable
		end,
		1)
	else
		DelayCall(function()
			FastQuestTable = BFQuest_GetTable();
		end,
		1)
	end
end

function broad:UI_INFO_MESSAGE(...)
	local arg = {...};
	if arg[3] then
		local message = arg[3];
		if message then
			if GetNumGroupMembers() == 0 then
				BFQuest_SendNotification(1);
			elseif string.find(message, BFQuest_TestPatterns) then
				local _,num1,num2=string.match(message, BFQuest_TestPatterns);
				if FastQuestInfo then
					if num1 == num2 then
						SendChatMessage(BFQuest_QUEST_PROGRESS..message..BFQCompletedSuffix, (IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT") or (IsInRaid() and "RAID") or "PARTY");
						BFQuest_SendNotification()
					else
						SendChatMessage(BFQuest_QUEST_PROGRESS..message, (IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT") or (IsInRaid() and "RAID") or "PARTY");
					end
				elseif num1 and num1 == num2 then
					SendChatMessage(BFQuest_QUEST_PROGRESS..message..BFQCompletedSuffix, (IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT") or (IsInRaid() and "RAID") or "PARTY");
					BFQuest_SendNotification()
				end
			elseif string.find(message, BFQCompletedMatchPattern) then
				SendChatMessage(BFQuest_QUEST_PROGRESS..message, (IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT") or (IsInRaid() and "RAID") or "PARTY");
				BFQuest_SendNotification()
			end
		end
	end
end

function broad:QUEST_ACCEPTED(...)
	BFQuest_SendNotification(1);
end

function broad:OnEnable()
	self:RegisterEvent("UI_INFO_MESSAGE");
	self:RegisterEvent("QUEST_ACCEPTED");
	DelayCall(function()
		FastQuestTable =BFQuest_GetTable();
	end,
	1)
end

function broad:OnDisable()
	self:UnregisterAllEvents()
end