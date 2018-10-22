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

Base.getindex(a::Matrix{Int}, p::Position) = a[p.y, p.x]
Base.setindex!(a::Matrix{Int}, v::Int, p::Position) = a[p.y, p.x] = v

Player(id::Int, shipyard_position::Position) = Player(id, shipyard_position, 0, Ship[], DropOff[])
GameMap(my_player_id, halite::Matrix{Int}, players::Vector{Player}) = GameMap(my_player_id, halite, Dict(p.id => p for p in players))
me(g::GameMap) = g.players[g.my_player_id]
