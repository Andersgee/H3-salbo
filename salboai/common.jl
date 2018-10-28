splitview(A; dims=ndims(A)) = view.((A,), (d == dims ? (1:size(A,d)) : (:) for d in 1:ndims(A))...)

max_turns(g::H.GameMap) = 451 + (size(g.halite, 1) - 48)*25/8

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
