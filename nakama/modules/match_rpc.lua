local nakama = require("nakama")

local function get_match_id(_, _)
    local matches = nakama.match_list()
    local current_match = matches[1]

    -- TODO if no current match, create one; otherwise, join a pending one that doesn't include this user

    -- print("looping matches...", type(matches))
    -- -- for i,match in ipairs(matches) do
    -- for i=1,#matches do
    --     print(i,matches[i])
    -- end
    -- print("END")

    if current_match == nil then
        return nakama.match_create("match_control", {})
    else
        return current_match.match_id
    end
end

nakama.register_rpc(get_match_id, "get_match_id")