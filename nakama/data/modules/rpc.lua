local nk = require("nakama")

local name = "nuts"
local collection = "ranking"
local key = "elo"
local fields = { "elo", "rank" } -- Only objects containing any of these keys and respective values are indexed.
local maxEntries = 1000

local err = nk.register_storage_index(name, collection, key, fields, fields, maxEntries)


local function create_match(_, payload)
    local json = nk.json_decode(payload)
    local params = {
        limit = json.limit,
        name = json.nm
    }

    local match_id = nk.match_create("game1", params)

    return match_id
end


local function get_matches(_, payload)
    local matches = nk.match_list(10, true, payload, 0, 7)
    local matchidarray = {}
    for i, match in ipairs(matches) do
        matchidarray[i] = match
    end

    return nk.json_encode(matchidarray)
end


local function initialize_user(context, payload)
    if payload.created then
        local write = {
            { collection = "ranking", key = "elo", user_id = context.user_id, value = { elo = 0, rank = 0 }, permission_read = 2, permission_write = 0 }
        }


        nk.storage_write(write)
    end
end


local function get_elo(context, payload)
    local get = {
        { collection = "ranking", key = "elo", user_id = context.user_id }
    }
    local object = nk.storage_read(get)

    for _, r in ipairs(object) do
        return nk.json_encode(r.value.elo)
    end
end

nk.register_req_after(initialize_user, "AuthenticateEmail")
nk.register_rpc(get_elo, "get_elo")
nk.register_rpc(create_match, "create_match")
nk.register_rpc(get_matches, "get_matches")
