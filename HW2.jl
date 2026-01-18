
using LinearAlgebra

A = [
8 1 1;
1 9 1;
1 3 5;
]

b = [9, 7, 1]

x = [1,4,3]

for t in 1:1000
    global x =
    map(i -> 
            (-sum(map(j -> 
                if j == i
                    0
                else
                    A[i,j]*x[j]
                end
            ,
            1:size(A)[1]
            )) + b[i])/A[i,i]
        ,
        1:length(x))
    println(x)
end

x