# Julia, SOR implementation

using LinearAlgebra

# Matrix to solve
A = [
8 1 1;
1 9 1;
1 3 5;
]

# relaxation
w = 1.02

# convergence criteria
e = 0.0001

b = [9.0, 7.0, 1.0]

x = [1.0,4.0,3.0]

for iter in 1:1000
    global x
    x_new = similar(x)

    for i in 1:length(x)
        acc = 0.0

        for j in i:size(A, 1)
            #if j != i
                acc += A[i, j] * x[j]
            #end
        end

        acc2 = 0
        for j in 1:i-1
            acc2 += A[i, j] * x_new[j]
        end
        
        x_new[i] = x[i] + w*(-(acc2 + (-b[i] + acc) ) / A[i, i])
    end

    delta = maximum(abs.(x_new .- x))

    x = x_new
    if delta[1] < e 
        break
    end
    println(string(iter), ": ", string(x))
end

x

# Sample run

# 1: [0.235, 0.34670000000000023, -0.11612039999999979]
# 2: [1.113401101, 0.67337418722, -0.43291641918264007]
# 3: [1.0945736125552366, 0.704878034340039, -0.4420200455937194]
# 4: [1.0920941341837396, 0.705560709272997, -0.4417499565366826]
# 3-element Vector{Float64}:
#   1.092022246342445
#   0.705524592969887
#  -0.441718590020696