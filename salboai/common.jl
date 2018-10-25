splitview(A; dims=ndims(A)) = view.((A,), (d == dims ? (1:size(A,d)) : (:) for d in 1:ndims(A))...)
