wrap(x, y) = mod1.(x, y)
wrap(x::Base.Colon, y) = x

struct WrappedArray{T, N, A <: AbstractArray{T,N}} <: AbstractArray{T,N}
    a::A
end

WrappedArray(a::A) where {T,N,A<:AbstractArray{T,N}} = WrappedArray{T,N,A}(a)
Base.Array(w::WrappedArray) = w.a
Base.size(w::WrappedArray{T}) where {T} = size(w.a)
Base.getindex(w::WrappedArray, i::CartesianIndex) = w.a[CartesianIndex(wrap.(Tuple(i), size(w)))]
Base.setindex!(w::WrappedArray, v, i::CartesianIndex) = w.a[CartesianIndex(wrap.(Tuple(i), size(w)))] = v
Base.getindex(w::WrappedArray, i...) = w.a[wrap.(i, size(w))...]
Base.setindex!(w::WrappedArray, v, i...) = view(w, i...) .= v
Base.view(w::WrappedArray, i...) = view(w.a, wrap.(i, size(w))...)


const WrappedMatrix{T, A<:AbstractMatrix{T}} = WrappedArray{T, 2, A}
const WrappedVector{T, A<:AbstractVector{T}} = WrappedArray{T, 1, A}

WrappedVector(a::A) where {T,A<:AbstractVector{T}} = WrappedVector{T,A}(a)
WrappedMatrix(a::A) where {T,A<:AbstractMatrix{T}} = WrappedMatrix{T,A}(a)

Base.Vector(w::WrappedVector{T, Vector{T}}) where {T} = w.a
Base.Matrix(w::WrappedMatrix{T, Matrix{T}})  where {T} = w.a
