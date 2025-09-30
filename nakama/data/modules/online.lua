local M = {}
local nk = require("nakama")

local deckList = {
    [-1] = 2,
    [0] = 2,
    [1] = 4,
    [2] = 4,
    [3] = 4,
    [4] = 4,
    [5] = 4,
    [6] = 4,
    [7] = 4,
    [8] = 4,
    [9] = 4,
    [10] = 4,
    [11] = 4,
    [12] = 4,
    [13] = 2
}

local generate_deck = function(dList)
    local deck = {}
    for k, v in deckList do
        for i = 1, v do
            table.insert(deck, k) --appends to deck array
        end
    end

    return deck
end

local reshuffle = function(deck, discard)

end

local can_add = function(addingbox, wazoo) -- adding box must have at least 1 element
    -- make it so that when you call this function for a normal flip you make the one card you are flipping the only card in addingbox
    if #addingbox == 1 then
        return addingbox[0][-1] == wazoo                    -- returns true or false for normal flip
    else
        return addingbox[0][-1] + addingbox[1][-1] == wazoo -- returns true or false for add
    end
    return false                                            -- should never run but just in case
end

local GameStateCodes = {
    created = 0,
    playing = 1,
    endscreen = 2
}

local OpCodes = {

}

local PlayerStateCodes = {
    neutral = 0,   -- not their turn
    drawncard = 1, -- apon drawing a card
    postdraw = 2,  -- after they have done something with the drawn card on their turn and have no ability
    peekself = 3,  -- after discarding a 7 or 8
    peekother = 4, -- after discarding a 9 or 10
    forceswap = 5, -- after discarding a non-king face card
    optionswap = 6 -- after discarding a king
}

local ActionCodes = {

}

local EligableActions = {

}

function M.match_init(_, params)
    local state = {                     -- initialize match state
        name = params.name,
        presences = {},                 -- nakama presences
        names = {},                     -- usernames
        deck = generate_deck(deckList), -- end of array is top of the deck
        discard = {},                   -- end of array is the top of the discard pile
        hands = {},                     -- each player has 2d array of card values dealt apon joining the match and put on the bottom of discard pile apon leaving
        addboxes = {},                  -- arrays for each player will contain up to 2 arrays of 3 values including row, collumn, and card value
        pstates = {},                   -- the state each player is in to determine if they are eligable to do certain actions
        mstate = GameStateCodes.created,
        limit = 4,
        empty_ticks = 0
    }


    local tick_rate = 10                --times per second match loop runs
    local label = tostring(params.name) --searchable label
    return state, tick_rate, label
end

function M.match_join_attempt(context, dispatcher, tick, state, presence, metadata)
    if state.presences[presence.user_id] ~= nil then
        return state, false, "User already in."
    end

    local p = 0
    for i, v in pairs(state.presences) do --count players
        p = p + 1
    end
    if p >= state.limit then
        return state, false, "Match is full" --reject join if the match is full
    end

    if state.mstate ~= GameStateCodes.created then
        return state, false, "Match is currently playing"
    end

    return state, true
end
