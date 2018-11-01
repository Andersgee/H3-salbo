function simulate1(f, m, ship, shipyard, turn)
  dropoffed_halite = 0
  m = copy(m)
  ship = copy(ship)

  cmd = f(m, ship, shipyard, turn)

  if cmd == H.STAY_STILL
    h = mineamount(m[ship.p])
    ship.halite += h
    m[ship.p] -= h
  elseif cmd == H.CONSTRUCT
    error("Not implemented")
  else
    c = leavecost(m[ship.p])
    if ship.halite < c
      error("Can't afford to move from ", ship.p, " with ", m[ship.p], " halite when ship only has ", ship.halite, " halite.")
    end
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


# f = select_direction
function simulate(f, m, ship, shipyard, n)
  C = []
  M = []
  S = []
  D = []

  for i in 1:n
    cmd, m, ship, dropoffed_halite = simulate1(f, m, ship, shipyard, i)
    push!(C, cmd)
    push!(M, m)
    push!(S, ship)
    push!(D, dropoffed_halite)
  end

  return C, M, S, D
end
