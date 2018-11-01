# given the distance 'd' and cost 'c' to the cheapest dropoff for each point on the map
# calculate the best possible halite per tick of moving to a square and then back to a dropoff
# pick path that yields most halite per tick considering (cost to dropoff can get cheaper after mining but ignore that)
function quadrant_hpt(M, ship_halite)
	t = zeros(Int, size(M)) # minimum number of ticks to leave each square
	d = ones(Int, size(M)) # direction
	d[1,1] = 4
	d[2:end,1] .= 0
	d[1,2:end] .= 1
	m = copy(M)
	h = similar(M, size(M)) # accumulated halite after leaving square

	h[1,1] = ship_halite
	if leavecost(M[1,1]) > ship_halite # forced mining
		A = mineamount(M[1,1])
		m[1,1] -= A
		h[1,1] += A
		t[1,1] += 1
	end
	h[1,1] -= leavecost(M[1,1])
	t[1,1] += 1

	for x = 1:size(M,2), y = 1:size(M,1)
		v = vy = vx = M[y,x]
		A = mineamount(vx) # only relevant when a ship can barely afford to move
		if x > 1
			tx = t[y,x-1]
			hx = h[y,x-1]
			if leavecost(vx) > hx # can't afford to pass-through, must stop and mine
				tx += 1
				hx += A
				vx -= A
			end
			h[y,x] = hx - leavecost(vx)
			t[y,x] = tx + 1
			if y > 1
				d[y,x] = d[y,x-1]
			end
			v = vx
		end
		if y > 1
			ty = t[y-1,x]
			hy = h[y-1,x]
			if leavecost(vy) > hy # can't afford to pass-through, must stop and mine
				ty += 1
				hy += A
				vy -= A
			end
			hy = hy - leavecost(vy)
			ty = ty + 1

			xhpt = h[y,x] / t[y,x]
			yhpt = hy / ty
			if x == 1 || ty < t[y,x] || (ty == t[y,x] && yhpt > xhpt)
				h[y,x] = hy
				t[y,x] = ty
				if x > 1
					d[y,x] = d[y-1,x]
				end
				v = vy
			end
		end
		m[y,x] = v
	end

	return m, h, t, d
end


struct OneWayCost
	p; M; H; T; D
end


function onewayhpt(m, ship_pos, ship_halite, ship_ticks)
    #Cheapest cost from some point to All Other points,
    #and what direction to go on First step to take that cheapest path.
    #south/east/north/west (in that order 0,1,2,3)
    m = shiftorigin(m, ship_pos)
	quadrant_hpt2(m) = quadrant_hpt(m, ship_halite)
    m1, h1, t1, d1 = m |> q1 |> quadrant_hpt2 .|> q1
    m2, h2, t2, d2 = m |> q2 |> quadrant_hpt2 .|> q2
    m3, h3, t3, d3 = m |> q3 |> quadrant_hpt2 .|> q3
    m4, h4, t4, d4 = m |> q4 |> quadrant_hpt2 .|> q4

    d1 = q1d(d1)
    d2 = q2d(d2)
    d3 = q3d(d3)
    d4 = q4d(d4)

	M3 = cat(m1, m2, m3, m4, dims=3)
	H3 = cat(h1, h2, h3, h4, dims=3)
	T3 = cat(t1, t2, t3, t4, dims=3)
	D3 = cat(d1, d2, d3, d4, dims=3)
	_, i = findmin(T3 - 1e-6H3, dims=3)
	M = M3[i][:,:]
	H = H3[i][:,:]
	T = T3[i][:,:]
	D = D3[i][:,:]
	return OneWayCost(ship_pos, ishiftorigin.((M, H, ship_ticks .+ T, D), (ship_pos,))...)
end


struct DropOffCost
	C; T; P
end


function cheapestdropoff(m, dropoffs)
	T = travelcost.((m,), dropoffs) # C, D, MHD
	C3 = cat(getindex.(T, 1)..., dims=3)
	LC = leavecost.(m[dropoffs]) # cost of "leaving" dropoff should not be included
	C3 = C3 .- reshape(LC, (1, 1, length(dropoffs)))
	T3 = cat(getindex.(T, 3)..., dims=3)
	P3 = cat(fill.(dropoffs, (size(m),))..., dims=3)
	_, i = findmin(C3, dims=3)
	C = C3[i][:,:]
	T = T3[i][:,:]
	P = P3[i][:,:]
	return DropOffCost(C, T, P)
end


struct MoveCandidate
	dir::Char; hpt::Float64; target::CartesianIndex{2}
end


Base.isless(a::MoveCandidate, b::MoveCandidate) = a.hpt > b.hpt
Base.isapprox(a::MoveCandidate, b::MoveCandidate; kwargs...) = a.dir == b.dir && a.target == b.target && isapprox(a.hpt, b.hpt; kwargs...)


function twowayhpt(ship::OneWayCost, dropoff::DropOffCost)
	# H includes ship_halite
	# T includes ship_ticks
	h = ship.H
	M = ship.M

	hpt2way = (h .- dropoff.C) ./ (ship.T .+ dropoff.T)
	hpt_go_home = hpt2way[ship.p]
	h = h .+ leavecost.(M) # the original leave cost is already deduced from H at each step, put it back
	for extra_mining_ticks in 1:1 # try mining up to 10 ticks to see if hpt can be increased
		A = mineamount.(M)
		A = min.(A, H.MAX_HALITE .- h)
		h = h .+ A
		M = M .- A
		L = leavecost.(M)
		hpttest = (h .- L .- dropoff.C) ./ (extra_mining_ticks .+ ship.T .+ dropoff.T)
		j = hpt2way .< hpttest
		if any(j)
			hpt2way[j] .= hpttest[j]
		end
	end

	h = h[ship.p]
	M = M[ship.p]

	for stay_extra_mining_ticks in 2:10 # try mining up to 10 ticks to see if hpt can be increased
		A = mineamount(M)
		A = min(A, H.MAX_HALITE - h)
		h = h .+ A
		M = M .- A
		L = leavecost(M)
		hpttest = (h - L - dropoff.C[ship.p]) ./ (stay_extra_mining_ticks .+ ship.T[ship.p] .+ dropoff.T[ship.p])
		if hpt2way[ship.p] < hpttest
			hpt2way[ship.p] = hpttest
		else
			break
		end
	end

	hpt_stay_still = hpt2way[ship.p]
	z = []
	for _ in 1:5
		hpt, i = findmax(hpt2way)
		dir = ship.D[i]
		hpt2way[ship.D .== dir] .= -Inf
		if dir != H.STAY_STILL && !isinf(hpt)
			push!(z, MoveCandidate(dir, hpt, i))
		end
	end

	if hpt_stay_still > hpt_go_home
		push!(z, MoveCandidate(H.STAY_STILL, hpt_stay_still, ship.p))
	else
		# select cheapest dropoff for ship position and pick fastest route to that dropoff
		dropoff_p = dropoff.P[ship.p]
		push!(z, MoveCandidate(ship.D[dropoff_p], hpt_go_home, dropoff_p))
	end
	return sort!(z)
end

#=
function dropoffhpt(ship::OneWayCost, dropoff::DropOffCost)
	hpt2dropoff = (ship.H[ship.p] - dropoff.C[ship.p]) ./ (ship.T[ship.p] + dropoff.T[ship.p])
	if dropoff.T[ship.p] == 0
		hpt2dropoff = -Inf # don't go to dropoff if on a dropoff
	end
	dropoff_p = dropoff.P[ship.p]
	return MoveCandidate(ship.D[dropoff_p], hpt2dropoff, dropoff_p)
end
=#

# dropoff = cheapestdropoff(m, dropoffs)
function pathfinding2(ship::OneWayCost, dropoff::DropOffCost)
	adventures = twowayhpt(ship, dropoff)
	#dropoffcand = dropoffhpt(ship, dropoff)
	#return sort!([adventures; dropoffcand])
	return adventures
end

#=
# whether to construct a dropoff should depend on how much halite there is around that point,
# not how far away other ships happen to be? or?
# pre-calc good dropoff-points?
# if a position had a dropoff, how much faster does it get to deliver halite to that point
function constructdropoffhpt(m, dropoffs, ships::Vector{OneWayCost})
	dropoff = cheapestdropoff(m, dropoffs]
	hptbefore = [pathfinding2(s, dropoff)[1].hpt for s in ships]

	[begin
		dropoff = cheapestdropoff(m, [dropoffs; s.p])]
		# only consider the hpt of the first MoveCandidate
		j = [1:i-1; i+1:length(ships)]
		hptafter = sum(pathfinding2(s2, dropoff)[1].hpt for s2 in ships[j])
		hpteffect = hptafter - sum(hptbefore[j])
		constructioncost = H.DROPOFF_COST - m[s.p] - s.h[s.p]

		MoveCandidate(H.CONSTRUCT, hpteffect - constructioncost, s.p)
	end for (i,s) in enumerate(ships)]
end
=#
