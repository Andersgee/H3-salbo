wrap(x::CartesianIndex{2}, y::Tuple) = CartesianIndex(mod1.(Tuple(x), y))

function Δ(sz, a, b)
    half = div.(sz, 2)
	return mod.(b .- a .+ half, sz) .- half
end
Δ(sz, a::CartesianIndex{2}, b::CartesianIndex{2}) = Δ(sz, Tuple(a), Tuple(b))

splitview(A; dims=ndims(A)) = view.((A,), (d == dims ? (1:size(A,d)) : (:) for d in 1:ndims(A))...)

max_turns(g::H.GameMap) = 451 + div((size(g.halite, 1) - 48)*25, 8)

warn_io = Base.stderr
function warn(s...)
	println(warn_io, s...)
	flush(warn_io)
end

function initwarn(fn::String)
	global warn_io
	warn_io = open(fn, "w")
end

function initwarn(io::IO)
	global warn_io
	warn_io = io
end
