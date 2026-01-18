
using LinearAlgebra

A = [
8 1 1;
1 9 1;
1 3 5;
]

b = [9, 7, 1]

x = [1.0,4.0,3.0]

for t in 1:1000
    global x
    x_new = similar(x)

    for i in 1:length(x)
        acc = 0.0

        for j in i+1:size(A, 1)
            if j != i
                acc += A[i, j] * x[j]
            end
        end

        # Residual
        acc_R = 0
        for j in 1:i-1
            acc_R += A[i, j] * x_new[j]
        end
        
        #R = -(acc_R + (b[i] + acc) ) / A[i, i]

        x_new[i] = (-acc - acc_R + b[i]) / A[i, i]
        
        #x_new[i] = (b[i] - acc) / A[i, i] + R
    end

    x = x_new
    println(x)
end

x