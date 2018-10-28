randpos(sz) = CartesianIndex(rand(1:sz[1]), rand(1:sz[2]))

dummyShip(owner, sz, id, halite=rand(1:H.MAX_HALITE)) = H.Ship(owner, id, randpos(sz), halite)

dummyDropOff(owner, sz, id) = H.DropOff(owner, id, randpos(sz))

function dummyPlayer(id, sz)
    shipyard = randpos(sz)
    return H.Player(
        id,
        shipyard,
        1234,
        dummyShip.(id, (sz,), 1:10),
        dummyDropOff.(id, (sz,), 1:10))
end

function dummyGameMap(sz = (32, 32), n_players = 4)
    halite = H.WrappedMatrix(rand(1:1000, sz))
    return H.GameMap(
        rand(1:n_players),
        halite,
        Dict(i => dummyPlayer(i, sz) for i in 1:n_players))
end
