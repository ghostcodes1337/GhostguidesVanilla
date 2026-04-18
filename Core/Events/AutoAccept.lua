--[[
Ghostguides Vanilla

Description:
Auto-accept for the exact current display step, plus broad auto-turnin.
Designed for WoW 1.12.1 APIs and reacts to QUEST_DETAIL, QUEST_PROGRESS,
QUEST_COMPLETE, and gossip quest menus using only Vanilla-safe quest functions.
]]--

local GLV = LibStub("GhostguidesVanilla")

local AutoAccept = {}
GLV.AutoAccept = AutoAccept

function AutoAccept:SetHoldDisabled(disabled)
    self.holdDisabled = disabled == true
end

function AutoAccept:IsEnabled()
    if self.holdDisabled then
        return false
    end

    return GLV.Settings and GLV.Settings:GetOption({"Automation", "AutoQuestDialogs"}) == true
end

function AutoAccept:Init()
    if not GLV.Ace then
        return
    end

    self.acceptInProgress = false
    self.turninInProgress = false
    self.gossipSelectionInProgress = false
    GLV.Ace:RegisterEvent("QUEST_DETAIL", function()
        self:OnQuestDetail()
    end)
    GLV.Ace:RegisterEvent("QUEST_PROGRESS", function()
        self:OnQuestProgress()
    end)
    GLV.Ace:RegisterEvent("QUEST_COMPLETE", function()
        self:OnQuestComplete()
    end)
    GLV.Ace:RegisterEvent("QUEST_GREETING", function()
        self:OnQuestGreeting()
    end)
    GLV.Ace:RegisterEvent("QUEST_FINISHED", function()
        self:OnQuestFinished()
    end)
    GLV.Ace:RegisterEvent("GOSSIP_SHOW", function()
        self:OnGossipShow()
    end)
end

function AutoAccept:GetCurrentStepQuestId(questTitle, actionType)
    if not questTitle or not GLV.CurrentDisplaySteps or not GLV.QuestTracker then
        return nil
    end

    local currentGuideId = GLV.Settings:GetOption({"Guide", "CurrentGuide"}) or "Unknown"
    local currentStep = GLV.Settings:GetOption({"Guide", "Guides", currentGuideId, "CurrentStep"}) or 0
    if currentStep <= 0 then
        return nil
    end

    local step = GLV.CurrentDisplaySteps[currentStep]
    if not step or not step.questTags or table.getn(step.questTags) == 0 then
        return nil
    end

    for _, questTag in ipairs(step.questTags) do
        if questTag.tag == actionType then
            local questId = tonumber(questTag.questId)
            local expectedTitle = questId and GLV:GetQuestNameByID(questId) or nil

            if expectedTitle and GLV.QuestTracker:QuestNamesMatch(questTitle, expectedTitle) then
                if actionType == "ACCEPT" then
                    if GLV.QuestTracker.store and GLV.QuestTracker.store.Accepted and GLV.QuestTracker.store.Accepted[questId] then
                        return nil
                    end

                    if GLV.QuestTracker:IsQuestCompleted(questId) then
                        return nil
                    end
                end

                return questId
            end
        end
    end

    return nil
end

function AutoAccept:OnQuestDetail()
    if not self:IsEnabled() or self.acceptInProgress or not GLV.QuestTracker then
        return
    end

    local questTitle = GetTitleText()
    if not questTitle or questTitle == "" then
        return
    end

    local questId = self:GetCurrentStepQuestId(questTitle, "ACCEPT")
    if not questId then
        return
    end

    self.acceptInProgress = true

    if GLV.Debug then
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[AutoAccept]|r Accepting current-step quest: " .. questTitle .. " (" .. questId .. ")")
    end

    -- Mirror the existing button-hook flow: mark/track first, then call WoW's accept.
    GLV.QuestTracker:TrackAccepted(questId, questTitle)
    AcceptQuest()

    GLV.Ace:ScheduleEvent("GLV_AutoAcceptUnlock", function()
        self.acceptInProgress = false
    end, 0.2)
end

function AutoAccept:OnQuestProgress()
    if not self:IsEnabled() or self.turninInProgress or not GLV.QuestTracker then
        return
    end

    if not IsQuestCompletable or not IsQuestCompletable() then
        return
    end

    local questTitle = GetTitleText() or ""
    local questId = self:GetCurrentStepQuestId(questTitle, "TURNIN")
    if not questId then
        return
    end

    self.turninInProgress = true

    if GLV.Debug then
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[AutoTurnin]|r Completing current-step quest: " .. questTitle)
    end

    CompleteQuest()

    GLV.Ace:ScheduleEvent("GLV_AutoTurninProgressUnlock", function()
        if not QuestFrameRewardPanel or not QuestFrameRewardPanel:IsVisible() then
            self.turninInProgress = false
        end
    end, 0.5)
end

function AutoAccept:ResolveQuestIdForTurnin(questTitle)
    if not questTitle or questTitle == "" or not GLV.QuestTracker then
        return nil
    end

    local questId = self:GetCurrentStepQuestId(questTitle, "TURNIN")
    return questId and tonumber(questId) or nil
end

function AutoAccept:ScheduleDialogContinue(delay)
    if not GLV.Ace then
        return
    end

    GLV.Ace:CancelScheduledEvent("GLV_AutoTurninDialogContinue")
    GLV.Ace:ScheduleEvent("GLV_AutoTurninDialogContinue", function()
        self:ContinueDialogTurnins()
    end, delay or 0.2)
end

function AutoAccept:GetCompletionFlagFromValues(values, startIndex, count)
    local booleans = {}

    for i = startIndex, startIndex + count - 1 do
        if type(values[i]) == "boolean" then
            table.insert(booleans, values[i])
        end
    end

    if table.getn(booleans) >= 2 then
        return booleans[2]
    end

    if table.getn(booleans) == 1 then
        return booleans[1]
    end

    return false
end

function AutoAccept:TrySelectGreetingQuest()
    if not self:IsEnabled() then
        return false
    end

    if not GetNumActiveQuests or not SelectActiveQuest or not GetActiveTitle then
        return false
    end

    local numActive = GetNumActiveQuests()
    if numActive and numActive > 0 then
        for i = 1, numActive do
            local titleData = { GetActiveTitle(i) }
            local title = titleData[1]
            local isComplete = self:GetCompletionFlagFromValues(titleData, 1, table.getn(titleData))
            local questId = self:GetCurrentStepQuestId(title, "TURNIN")

            if isComplete and questId then
                if GLV.Debug then
                    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[AutoTurnin]|r Opening greeting quest #" .. tostring(i) .. " for auto turn-in")
                end
                SelectActiveQuest(i)
                return true
            end
        end
    end

    if not GetNumAvailableQuests or not SelectAvailableQuest or not GetAvailableTitle then
        return false
    end

    local numAvailable = GetNumAvailableQuests()
    if not numAvailable or numAvailable <= 0 then
        return false
    end

    for i = 1, numAvailable do
        local titleData = { GetAvailableTitle(i) }
        local title = titleData[1]
        local questId = self:GetCurrentStepQuestId(title, "ACCEPT")

        if questId then
            if GLV.Debug then
                DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[AutoAccept]|r Opening greeting quest #" .. tostring(i) .. " for auto-accept")
            end
            SelectAvailableQuest(i)
            return true
        end
    end

    return false
end

function AutoAccept:TrySelectGossipQuest()
    if not self:IsEnabled() then
        return false
    end

    if not GetNumGossipActiveQuests or not SelectGossipActiveQuest or not GetGossipActiveQuests then
        return false
    end

    local numActive = GetNumGossipActiveQuests()
    if numActive and numActive > 0 then
        local gossipData = { GetGossipActiveQuests() }
        local total = table.getn(gossipData)
        local stride = 5

        if numActive > 0 and total >= (numActive * 4) then
            stride = math.floor(total / numActive)
            if stride < 4 then
                stride = 4
            end
            if stride > 5 then
                stride = 5
            end
        end

        for i = 1, numActive do
            local offset = ((i - 1) * stride) + 1
            local isComplete = self:GetCompletionFlagFromValues(gossipData, offset, stride)
            local title = gossipData[offset]
            local questId = self:GetCurrentStepQuestId(title, "TURNIN")

            if isComplete and questId then
                if GLV.Debug then
                    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[AutoTurnin]|r Opening gossip quest #" .. tostring(i) .. " for auto turn-in")
                end
                SelectGossipActiveQuest(i)
                return true
            end
        end
    end

    if not GetNumGossipAvailableQuests or not SelectGossipAvailableQuest or not GetGossipAvailableQuests then
        return false
    end

    local numAvailable = GetNumGossipAvailableQuests()
    if not numAvailable or numAvailable <= 0 then
        return false
    end

    local availableData = { GetGossipAvailableQuests() }
    local total = table.getn(availableData)
    local stride = 6

    if numAvailable > 0 and total >= (numAvailable * 5) then
        stride = math.floor(total / numAvailable)
        if stride < 5 then
            stride = 5
        end
        if stride > 6 then
            stride = 6
        end
    end

    for i = 1, numAvailable do
        local offset = ((i - 1) * stride) + 1
        local title = availableData[offset]
        local questId = self:GetCurrentStepQuestId(title, "ACCEPT")

        if questId then
            if GLV.Debug then
                DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[AutoAccept]|r Opening gossip quest #" .. tostring(i) .. " for auto-accept")
            end
            SelectGossipAvailableQuest(i)
            return true
        end
    end

    return false
end

function AutoAccept:ContinueDialogTurnins()
    if not self:IsEnabled() then
        return
    end

    if self.gossipSelectionInProgress then
        return
    end

    if QuestFrameGreetingPanel and QuestFrameGreetingPanel:IsVisible() then
        self.gossipSelectionInProgress = true
        if self:TrySelectGreetingQuest() then
            GLV.Ace:ScheduleEvent("GLV_AutoTurninGreetingUnlock", function()
                self.gossipSelectionInProgress = false
            end, 0.3)
            return
        end
        self.gossipSelectionInProgress = false
    end

    if GossipFrame and GossipFrame:IsVisible() then
        self.gossipSelectionInProgress = true
        if self:TrySelectGossipQuest() then
            GLV.Ace:ScheduleEvent("GLV_AutoTurninGossipUnlock", function()
                self.gossipSelectionInProgress = false
            end, 0.3)
            return
        end
        self.gossipSelectionInProgress = false
    end
end

function AutoAccept:OnQuestComplete()
    if not self:IsEnabled() or not GLV.QuestTracker then
        return
    end

    local questTitle = GetTitleText()
    if not questTitle or questTitle == "" then
        self.turninInProgress = false
        return
    end

    local questId = self:ResolveQuestIdForTurnin(questTitle)
    if not questId then
        self.turninInProgress = false
        return
    end

    if GLV.Debug then
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00[AutoTurnin]|r Reward screen opened for current-step quest: " .. questTitle .. " (" .. tostring(questId) .. ")")
    end

    GLV.Ace:ScheduleEvent("GLV_AutoTurninCompleteUnlock", function()
        self.turninInProgress = false
    end, 0.2)
end

function AutoAccept:OnGossipShow()
    if self:IsEnabled() then
        self:ScheduleDialogContinue(0.05)
    end
end

function AutoAccept:OnQuestGreeting()
    if self:IsEnabled() then
        self:ScheduleDialogContinue(0.05)
    end
end

function AutoAccept:OnQuestFinished()
    self.turninInProgress = false
    if self:IsEnabled() then
        self:ScheduleDialogContinue(0.1)
    end
end
