splitview(A; dims=ndims(A)) = view.((A,), (d == dims ? (1:size(A,d)) : (:) for d in 1:ndims(A))...)

max_turns(g::H.GameMap) = 451 + (size(g.halite, 1) - 48)*25/8

warn_fn = Base.stderr
function warn(s...)
	println(warn_fn, s...)
	flush(warn_fn)
end

function initwarn(fn)
	global warn_fn
	warn_fn = open(fn, "w")
end
