manhattandist(a,b) = sum(abs.(b-a))

function manhattandistmatrix(m, origin)
    #with wrap around taken into account
    Y=size(m,1)
    X=size(m,2)
    mhdist_q4=zeros(Int,(Y,X))
    mhdist_q1=zeros(Int,(Y,X))
    mhdist_q2=zeros(Int,(Y,X))
    mhdist_q3=zeros(Int,(Y,X))
    o=[origin[1],origin[2]]
    for x=1:X, y=1:Y
        mhdist_q4[y,x] = manhattandist([1,1],[y,x])
        mhdist_q3[y,x] = manhattandist([1,X],[y,x])
        mhdist_q2[y,x] = manhattandist([Y,X],[y,x])
        mhdist_q1[y,x] = manhattandist([Y,1],[y,x])
    end
    mhdist_q4 = ishiftorigin(mhdist_q4, origin)
    mhdist_q3 = ishiftorigin(shiftorigin(mhdist_q3, CartesianIndex(1,X)), origin)
    mhdist_q2 = ishiftorigin(shiftorigin(mhdist_q2, CartesianIndex(Y,X)), origin)
    mhdist_q1 = ishiftorigin(shiftorigin(mhdist_q1, CartesianIndex(Y,1)), origin)

    return min.(mhdist_q4,mhdist_q3,mhdist_q2,mhdist_q1)
end
