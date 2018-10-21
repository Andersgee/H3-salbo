ready(botname) = sendcommands([botname])
sendcommands(cmds::Vector{String}) = println(join(cmds, " "))

function update_frame!(g::GameMap, s::IO)
    turn = parse_turnnumber(readline(s))
    for _ in 1:length(g.players)
        player_id = parse(Int, readuntil(s, " "))
        update_player!(g.players[player_id], s)
    end
    update_halite!(g.halite, s)
    return turn
end


function init(s::IO)::GameMap
    load_constants(readline(s))

    nr_of_players, my_player_id = parse_num_players_and_id(readline(s))

    players = parse_player.(readnlines(s, nr_of_players))

    cols,rows = parse_map_size(readline(s))
    M = parse_map(readnlines(s, rows))

    #manually remove halite from under shipyards.
    for i=1:nr_of_players
        M[players[i].shipyard.x, players[i].shipyard.y] = 0
    end

    return GameMap(my_player_id, M, players)
end
