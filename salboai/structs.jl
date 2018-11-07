struct CandidateTarget
	dir::Char
	target::CartesianIndex{2}
	hpt::Float64
	checkcollision::Bool
end

CandidateTarget(dir::Char, target::CartesianIndex{2}=CartesianIndex(0,0), hpt::Float64=-Inf) = CandidateTarget(dir, target, hpt, true)
CandidateTarget(dir::Char, target::CartesianIndex{2}, checkcollision::Bool) = CandidateTarget(dir, target, -Inf, checkcollision)

Base.isless(a::CandidateTarget, b::CandidateTarget) = a.hpt < b.hpt
Base.isapprox(a::CandidateTarget, b::CandidateTarget; kwargs...) = a.dir == b.dir && a.target == b.target && isapprox(a.hpt, b.hpt; kwargs...)


struct ShipCandidateTargets
	ship::H.Ship
	cands::NTuple{5, CandidateTarget} # fixed size AbstractArray
end

function ShipCandidateTargets(ship, cands)
	cands5 = [cands...; fill(CandidateTarget(H.STAY_STILL, ship.p), 5-length(cands))]
	sort!(cands5, rev=true) # best first
	ShipCandidateTargets(ship, Tuple(cands5))
end


struct Back2DropOff
	C::Matrix{Int}               # cost to nearest dropoff
	T::Matrix{Int}               # manhattan distance to nearest dropoff
	P::Matrix{CartesianIndex{2}} # position of nearest dropoff
end
