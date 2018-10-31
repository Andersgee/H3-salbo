function simulate1(m, ship, shipyard)
  dropoffed_halite = 0
  m = copy(m)
  ship = copy(ship)

  cmd = select_direction(m, ship, shipyard)

  if cmd == H.STAY_STILL
    h = mineamount(m[ship.p])
    ship.halite += h
    m[ship.p] -= h
  elseif cmd == H.CONSTRUCT
    error("Not implemented")
  else
    c = leavecost(m[ship.p])
    ship.halite -= c
    ship.p += cmdΔ(cmd)

    if ship.p == shipyard
      dropoffed_halite = ship.halite
      ship.halite = 0
    end
  end

  ship.p = CartesianIndex(mod1.(Tuple(ship.p), size(m)))
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
