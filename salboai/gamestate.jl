struct GameState
    ship_dropoff_turn::Dict{Int,Int}
end

GameState() = GameState(Dict{Int,Int}())

function update_game_state!(S::GameState, h::H.GameMap, turn::Int)
    # clear killed ships
    ship_ids = [ship.id for (id,player) in h.players for ship in player.ships]
    delete!(S.ship_dropoff_turn, setdiff(collect(keys(S.ship_dropoff_turn)), ship_ids))

    # update dropoff ticks
    for (id,player) in h.players
        dropoffs = [d.p for d in player.dropoffs]
        push!(dropoffs, player.shipyard)
        for ship in player.ships
            if ship.p ∈ dropoffs || !haskey(S.ship_dropoff_turn, ship.id)
                S.ship_dropoff_turn[ship.id] = turn
            end
        end
    end

    S
end
