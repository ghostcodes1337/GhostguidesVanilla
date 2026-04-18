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
    if self.acceptInProgress or not GLV.QuestTracker then
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
    if self.turninInProgress or not GLV.QuestTracker then
        return
    end

    if not IsQuestCompletable or not IsQuestCompletable() then
        return
    end

    self.turninInProgress = true

    local questTitle = GetTitleText() or ""
    if GLV.Debug then
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[AutoTurnin]|r Completing quest: " .. questTitle)
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
    if questId then
        return tonumber(questId)
    end

    local acceptedId = GLV.QuestTracker:FindAcceptedIdByTitle(questTitle)
    if acceptedId then
        return tonumber(acceptedId)
    end

    local dbId = GLV:GetQuestIDByName(questTitle)
    if dbId then
        return tonumber(dbId)
    end

    return nil
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
    if not GetNumActiveQuests or not SelectActiveQuest or not GetActiveTitle then
        return false
    end

    local numActive = GetNumActiveQuests()
    if not numActive or numActive <= 0 then
        return false
    end

    local fallbackIndex = 1

    for i = 1, numActive do
        local titleData = { GetActiveTitle(i) }
        local isComplete = self:GetCompletionFlagFromValues(titleData, 1, table.getn(titleData))

        if isComplete then
            if GLV.Debug then
                DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[AutoTurnin]|r Opening greeting quest #" .. tostring(i) .. " for auto turn-in")
            end
            SelectActiveQuest(i)
            return true
        end
    end

    if GLV.Debug then
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00[AutoTurnin]|r No explicit completed flag found, opening first active greeting quest")
    end

    SelectActiveQuest(fallbackIndex)
    return true
end

function AutoAccept:TrySelectGossipQuest()
    if not GetNumGossipActiveQuests or not SelectGossipActiveQuest or not GetGossipActiveQuests then
        return false
    end

    local numActive = GetNumGossipActiveQuests()
    if not numActive or numActive <= 0 then
        return false
    end

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

        if isComplete then
            if GLV.Debug then
                DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[AutoTurnin]|r Opening gossip quest #" .. tostring(i) .. " for auto turn-in")
            end
            SelectGossipActiveQuest(i)
            return true
        end
    end

    return false
end

function AutoAccept:ContinueDialogTurnins()
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
    if not GLV.QuestTracker then
        return
    end

    local questTitle = GetTitleText()
    if not questTitle or questTitle == "" then
        self.turninInProgress = false
        return
    end

    local numChoices = GetNumQuestChoices and GetNumQuestChoices() or 0
    local questId = self:ResolveQuestIdForTurnin(questTitle)

    if questId then
        local store = GLV.QuestTracker.store or GLV.Settings:GetOption({"QuestTracker"}) or {}
        if not store.Completed then
            store.Completed = {}
        end
        store.Completed[questId] = { title = questTitle, timestamp = time() }
        if store.Accepted and store.Accepted[questId] then
            store.Accepted[questId] = nil
        end
        GLV.Settings:SetOption(store, {"QuestTracker"})

        GLV.QuestTracker:HandleQuestAction(questId, questTitle, "TURNIN")
    end

    if GLV.Debug then
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[AutoTurnin]|r Turning in quest: " .. questTitle .. " (" .. tostring(questId) .. ")")
    end

    if numChoices and numChoices > 0 then
        GetQuestReward(1)
    else
        GetQuestReward()
    end

    GLV.Ace:ScheduleEvent("GLV_AutoTurninCompleteUnlock", function()
        self.turninInProgress = false
    end, 0.2)

    self:ScheduleDialogContinue(0.4)
end

function AutoAccept:OnGossipShow()
    self:ScheduleDialogContinue(0.05)
end

function AutoAccept:OnQuestGreeting()
    self:ScheduleDialogContinue(0.05)
end

function AutoAccept:OnQuestFinished()
    self.turninInProgress = false
    self:ScheduleDialogContinue(0.1)
end
