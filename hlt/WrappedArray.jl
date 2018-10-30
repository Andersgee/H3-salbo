wrap(sz::Int, x) = mod1.(x, sz)
wrap(sz::Int, x::Base.Colon) = x
wrap(sz::Tuple, x...) = wrap.(sz, x)
wrap(sz::Tuple, x::CartesianIndex) = (CartesianIndex(wrap.(sz, Tuple(x))),)
wrap(sz::Tuple, X::CA) where {N, CA<:AbstractVector{<:CartesianIndex{N}}} = ([wrap(sz, x)[1] for x in X],)

struct WrappedArray{T, N, A <: AbstractArray{T,N}} <: AbstractArray{T,N}
    a::A
end

WrappedArray(a::A) where {T,N,A<:AbstractArray{T,N}} = WrappedArray{T,N,A}(a)
Base.Array(w::WrappedArray) = w.a
Base.size(w::WrappedArray{T}) where {T} = size(w.a)
#Base.getindex(w::WrappedArray, i::CartesianIndex) = w.a[CartesianIndex(wrap(size(w)))]
#Base.setindex!(w::WrappedArray, v, i::CartesianIndex) = w.a[CartesianIndex(wrap(i, size(w)))] = v
Base.getindex(w::WrappedArray, i...) = w.a[wrap(size(w), i...)...]
Base.setindex!(w::WrappedArray, v, i...) = view(w, i...) .= v
#Base.view(w::WrappedArray, i::V) where {V<:AbstractVector{<:CartesianIndex}} = view(w.a, wrap.(i, (size(w),)))
Base.view(w::WrappedArray, i...) = view(w.a, wrap(size(w), i...)...)


const WrappedMatrix{T, A<:AbstractMatrix{T}} = WrappedArray{T, 2, A}
const WrappedVector{T, A<:AbstractVector{T}} = WrappedArray{T, 1, A}

WrappedVector(a::A) where {T,A<:AbstractVector{T}} = WrappedVector{T,A}(a)
WrappedMatrix(a::A) where {T,A<:AbstractMatrix{T}} = WrappedMatrix{T,A}(a)

Base.Vector(w::WrappedVector{T, Vector{T}}) where {T} = w.a
Base.Matrix(w::WrappedMatrix{T, Matrix{T}})  where {T} = w.a
