local function update(self, arg0)
    for _, func in pairs(self.funcList) do
        func(self, arg0)
    end
end

---@class UpdateFrame : Frame
local updateFrame = CreateFrame("Frame")
updateFrame.funcList = {}
updateFrame:SetScript("OnUpdate", update)

function DelayCall(func, delaySec, ...)
    if (not updateFrame.callroutine) then
        updateFrame.callroutine = {};
    end
    local tables = {};
    local args = { ... };
    tables["func"] = func;
    tables["delay"] = delaySec;
    tables["lastUpdate"] = 0;
    tables.arg = args;
    table.insert(updateFrame.callroutine, tables);
end

