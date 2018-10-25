function simulate1(m, ship, shipyard)
  dropoffed_halite = 0
  m = copy(m)
  ship = copy(ship)

  cmd = select_direction(m, ship, shipyard)

  if cmd == 'o'
    h = ceil(Int, 0.25*m[ship.p])
    ship.halite += h
    m[ship.p] -= h
  else
    c = floor(Int, 0.1*m[ship.p])
    ship.halite -= c
    d = Dict('n' => CartesianIndex(-1, 0),
             's' => CartesianIndex(1, 0),
             'w' => CartesianIndex(0, -1),
             'e' => CartesianIndex(0, 1))
    ship.p += d[cmd]

    if ship.p == shipyard
      dropoffed_halite = ship.halite
      ship.halite = 0
    end
  end

  ship.p = CartesianIndex(H.mod1.(Tuple(ship.p), size(m)))
  cmd, m, ship, dropoffed_halite
end


function simulate(m, ship, shipyard, n)
  C = []
  M = []
  S = []
  D = []

  for i in 1:n
    cmd, m, ship, dropoffed_halite = simulate1(m, ship, shipyard)
    push!(C, cmd)
    push!(M, m)
    push!(S, ship)
    push!(D, dropoffed_halite)
  end

  return C, M, S, D
end
