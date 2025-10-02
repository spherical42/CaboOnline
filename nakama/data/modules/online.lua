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

local draw = function(state)
    return table.remove(state.deck) -- pops back of deck
end

local discard = function(card, state)
    table.insert(state.discard, card) -- puts value on top of discard pile
end

local deal_hand = function(num, state)
    local hand = { {}, {} }
    local rowsize = num / 2
    for i in hand do
        for j = 0, rowsize - 1 do
            hand[i][j] = draw(state)
        end
    end
    return hand
end

local get_hand_lengths = function(hand)
    local row_lengths = {}
    for x in hand do
        table.insert(row_lengths, #x)
    end
    return row_lengths -- returns lengths of rows in the hand
end


local reshuffle = function(state)

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
    join = 0,
    sendbottrow = 1,
    reveal = 2
}

local PlayerStateCodes = {
    preready = 0,   -- after joining the game and before they ready
    neutral = 1,    -- not their turn
    drawncard = 2,  -- apon drawing a card
    peekself = 3,   -- after discarding a 7 or 8
    peekother = 4,  -- after discarding a 9 or 10
    forceswap = 5,  -- after discarding a non-king face card
    optionswap = 6, -- after discarding a king
    endphase = 7    -- after having done all turn-exclusive actions
}

local ActionCodes = {
    add = 0,
    replace = 1, -- only for drawn card and own card
    swap = 2,    -- used for both forced and optional
    discard = 3, -- only for drawn card
    peek = 4,    -- used for both own and other
    ready = 5,   -- used after viewing own cards at the beginning of the game
    endturn = 6, -- used to advance turn order
    cabo = 7     -- call cabo
}

local EligableActions = {
    [PlayerStateCodes.preready] = { ActionCodes.ready },
    [PlayerStateCodes.neutral] = { ActionCodes.add },
    [PlayerStateCodes.drawncard] = { ActionCodes.discard, ActionCodes.replace, ActionCodes.add },
    [PlayerStateCodes.peekself] = { ActionCodes.peek, ActionCodes.add, ActionCodes.endturn, ActionCodes.cabo },
    [PlayerStateCodes.peekother] = { ActionCodes.peek, ActionCodes.add, ActionCodes.endturn, ActionCodes.cabo },
    [PlayerStateCodes.forceswap] = { ActionCodes.swap, ActionCodes.add },
    [PlayerStateCodes.optionswap] = { ActionCodes.swap, ActionCodes.add, ActionCodes.endturn, ActionCodes.cabo },
    [PlayerStateCodes.endphase] = { ActionCodes.add, ActionCodes.endturn, ActionCodes.cabo }
}

function M.match_init(_, params)
    local state = {                     -- initialize match state
        name = params.name,
        dealsize = params.numcards,     -- number of cards dealt to players when they join
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

function M.match_join(context, dispatcher, tick, state, presences)
    for _, presence in ipairs(presences) do -- initialize the new player
        state.presences[presence.user_id] = presence
        state.names[presence.user_id] = presence.username
        state.hands[presence.user_id] = deal_hand(state.dealsize)
        state.addboxes[presence.user_id] = {}
        state.pstates[presence.user_id] = PlayerStateCodes.preready
        local data = { -- data to broadcast to everybody
            ["id"] = presence.user_id,
            ["name"] = presence.username,
            ["handdim"] = get_hand_lengths(state.hands[presence.user_id]) -- gets an array of {toprowlength, bottomrolength}
        }
        local encoded = nk.json_encode(data)
        dispatcher.broadcast_message(OpCodes.join, encoded)
        local hdata = {
            ["bottrow"] = state.hands[presence.user_id][0]
        }
        local hencoded = nk.json_encode(hdata)
        dispatcher.broadcast_message(OpCodes.sendbottrow, hencoded, { presence }) -- sends just bottom row values with opcode to reaveal those cards
    end

    return state
end

function M.match_leave(context, dispatcher, tick, state, presences)
    for _, presence in ipairs(presences) do

    end
    return state
end
