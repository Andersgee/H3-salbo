parse_map_size(s) = str2ints(s)
parse_map(S) = hcat(str2ints.(S)...)'

parse_num_players_and_id(s) = str2ints(s)

type Position
    x::Int
    y::Int
end

type Ship

end

type Player
    id::Int
    shipyard::Position
    halite_amount::Int
    ships::Dict{Int,Ship}
    dropoffs::Array{Position}
    #dropoffs::Array
    #ships::Dict{Int, Ship}
    #minerals::Int
end

parse_player(s::String) = parse_player(str2ints(s))
parse_player(s::Array{Int}) = Player(s[1], Position(s[2],s[3]))

#=
self.id = player_id
self.shipyard = shipyard
self.halite_amount = halite
self._ships = {}
self._dropoffs = {}
=#
