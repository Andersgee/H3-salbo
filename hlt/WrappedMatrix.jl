mod1(x, y) = 1 .+ mod.(x .- 1, y)

# Does not support 'end' or ':' because there is no beginning nor end.
# But it does support i:j.
struct WrappedMatrix{T} <: AbstractMatrix{T}
    m::Matrix{T}
end

Base.Matrix(w::WrappedMatrix) = w.m
Base.size(w::WrappedMatrix) = size(w.m)
Base.getindex(A::WrappedMatrix, i::CartesianIndex) = A.m[CartesianIndex(mod1.(Tuple(i), size(A)))]
Base.setindex!(A::WrappedMatrix, v, i::CartesianIndex) = A.m[CartesianIndex(mod1.(Tuple(i), size(A)))] = v
Base.getindex(A::WrappedMatrix, i...) = A.m[mod1.(collect.(i), size(A))...]
Base.setindex!(A::WrappedMatrix, v, i...) = view(A, i...) .= v

Base.view(A::WrappedMatrix, i...) = view(A.m, mod1.(collect.(i), size(A))...)
