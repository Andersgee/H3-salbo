function simulate1(m, ship, shipyard)
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
  end

  ship.p = CartesianIndex(H.mod1.(Tuple(ship.p), size(m)))
  cmd, m, ship
end


function simulate(m, ship, shipyard, n)
  C = []
  M = []
  S = []

  for i in 1:n
    cmd, m, ship = simulate1(m, ship, shipyard)
    push!(C, cmd)
    push!(M, m)
    push!(S, ship)
  end

  return C, M, S
end
