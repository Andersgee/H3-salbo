include("../../hlt/halite.jl")
include("../salboai.jl")

using BenchmarkTools

A = zeros(Int,5,5)
A[1,1] = 1
B = boxfilter(A,1)

@test B == [1 1 0 0 1
            1 1 0 0 1
            0 0 0 0 0
            0 0 0 0 0
            1 1 0 0 1]

d1 = Salboai.diamondfilter(A, 1)
@test d1 == [1 1 0 0 1
             1 0 0 0 0
             0 0 0 0 0
             0 0 0 0 0
             1 0 0 0 0]

d2 = Salboai.diamondfilter(A, 2)
@test d2 == [1 1 1 1 1
             1 1 0 0 1
             1 0 0 0 0
             1 0 0 0 0
             1 1 0 0 1]

@test Salboai.diamondelems(0) == 1
@test Salboai.diamondelems(1) == 5
@test Salboai.diamondelems(2) == 13

h = rand(1:1000, 64, 64)
ksize = 15

function diamondsummatrix(m, k)
    ksize = div(size(k, 1)-1, 2)
   diamondsum=zeros(Int, size(m))
   for x=1:size(m,2), y=1:size(m,1)
       diamondsum[y,x] = sum(m[y-ksize:y+ksize, x-ksize:x+ksize] .* k)
   end
   return diamondsum
end

k = diamondkernel(Int, ksize)

hw = H.WrappedMatrix(h)
m1 = Salboai.diamondfilter(h, ksize)
m2 = diamondsummatrix(hw, k)
@test m2 == m1

e1 = @elapsed Salboai.diamondfilter(h, ksize)
e1 = @elapsed Salboai.diamondfilter(h, ksize)
e2 = @elapsed diamondsummatrix(hw, k)

@test 100 * e1 < e2

#=
using FFTW

diamondkernel(T, r) = T[abs(x) + abs(y) ≤ r for y in -r:r, x in -r:r]

# wraps A, not B
function wrappedconv2(A::StridedMatrix{T}, B::StridedMatrix{T}) where T
    sa, sb = size(A), size(B)
    Bt = zeros(T, sa[1], sa[2])
    h = div.(sb.+1, 2)
    h2 = sb .- h
    Bt[[end-h2[1]+1:end; 1:h[1]], [end-h2[2]+1:end; 1:h[2]]] .= B
    p = plan_fft(Bt)
    C = ifft((p*A).*(p*Bt))
    if T <: Real
        return real(C)
    end
    return C
end

function diamonfilter_conv2(A, r)
    k = diamondkernel(Float64, r)
    w = wrappedconv2(A, k)
end
=#
