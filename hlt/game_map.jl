struct Position
    x::Int
    y::Int
end


struct Ship
    owner::Int
    id::Int
    p::Position
    halite::Int
end


struct DropOff
    owner::Int
    id::Int
    p::Position
end


mutable struct Player
    id::Int
    shipyard::Position
    halite::Int
    ships::Vector{Ship}
    dropoffs::Vector{DropOff}
end


struct GameMap
    my_player_id::Int
    halite::Matrix{Int}
    players::Dict{Int,Player}
end


Player(id::Int, shipyard_position::Position) = Player(id, shipyard_position, 0, Ship[], DropOff[])
GameMap(my_player_id, halite::Matrix{Int}, players::Vector{Player}) = GameMap(my_player_id, halite, Dict(p.id => p for p in players))

parse_player(s::String) = parse_player(str2ints(s))
parse_player(s::Array{Int}) = Player(s[1], Position(s[2], s[3]))
parse_map_size(s) = str2ints(s)
parse_map(S) = Matrix(hcat(str2ints.(S)...)')
parse_turnnumber(s) = parse(Int, s)
parse_num_players_and_id(s) = str2ints(s)


function parse_ship(owner::Int, s::String)
    id, x, y, halite = str2ints(s)
    Ship(owner, id, Position(x, y), halite)
end


function parse_dropoff(owner::Int, s::String)
    id, x, y = str2ints(s)
    Ship(owner, id, Position(x, y))
end


function update_player!(p::Player, s::IO)
    num_ships, num_dropoffs, p.halite = str2ints(readline(s))
    p.ships = parse_ship.(p.id, readnlines(s, num_ships))
    p.dropoffs = parse_dropoff.(p.id, readnlines(s, num_dropoffs))
    p
end


function update_cell!(halite::Matrix{Int}, s::String)
    x, y, h = str2ints(s)
    halite[y,x] = h
end


function update_halite!(halite::Matrix{Int}, s::IO)
    n_updated_cells = parse(Int, readline(s))
    update_cell!.((halite,), readnlines(s, n_updated_cells))
    halite
end
