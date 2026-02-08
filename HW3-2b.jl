# Direct SOR solver

h = 1 # 0.25 # m

struct V
    id::Int
end


struct dVdn
    value::Float32
end

M =
[ 0   0        100   100   100  0      0 ;
  0   dVdn(25)   V(1)  V(2)  V(3) dVdn(25) 0 ;
  0   dVdn(25)   V(4)  V(5)  V(6) dVdn(25) 0 ;
  0   dVdn(25)   V(7)  V(8)  V(9) dVdn(25) 0 ;
  0   0          0     0     0    0        0 ; ]


M =
[ 0   0   100   100   100  0 0 ;
  0   0   V(1)  V(2)  V(3) 0 0 ;
  0   0   V(4)  V(5)  V(6) 0 0 ;
  0   0   V(7)  V(8)  V(9) 0 0 ;
  0   0   0     0     0    0 0 ; ]


 M = 
 [  0  0        0    0        0
    0  dVdn(1) V(1)  dVdn(1)  0
    0  0        0    0        0
 ] 


#  M = 
#  [  0  0     0     0    0
#     0  V(0)  V(1)  V(3) 0
#     0  0     0     0    0
#  ] 

# -4V0 +  V1 +   0*V3 + (1 * 2h + V1) = 0 
# V0 +  -4V1 +     V3 = 0
# 0*V0 +  V1 +  -4*V3 + (1 * 2h + V1) = 0

# 1 = (V_n+1 - V1)/2h
# V_n+1 = 1 * 2h + V1


# -4V0 +  2*V1 +   0*V3 + (1 * 2h) = 0 
# V0 +    -4V1 +     V3 = 0
# 0*V0 +  2*V1 +  -4*V3 + (1 * 2h) = 0


# -4V0 +  2*V1 +   0*V3 = -2 
# V0 +    -4V1 +     V3 = 0
# 0*V0 +  2*V1 +  -4*V3 = -2

# Initialize result
Φ = map(x -> x isa Number ? Float64(x) : 0, M)

# Get node coordinates
nodes = Vector{Tuple}()

for I in CartesianIndices(M)
    i,j = Tuple(I)
    v = M[i, j]
    if typeof(v) == V || typeof(v) == dVdn # Add Neuman BC nodes as regular nodes for solving
        push!(nodes, Tuple(I))
    end
    println(M[i,j])
end

println(repr("text/plain", Φ))



for iter in 1:100

# Iterate over nodes where we want to find potential
for (i, j) in nodes
    local b = 0 # h^2*q_v/e 
    R = ( Φ[i+1,j] + Φ[i-1,j] + Φ[i,j+1] + Φ[i,j-1] - 4*Φ[i,j] - b )/4
    Φ[i,j] = Φ[i,j] + 1.5*R
    #println(i, " ", j) 
end

# Update interpolated nodes adjacent to Neuman nodes
for j in range(1,size(Φ)[1])
    left_BC = M[j, 2]
    if left_BC isa dVdn
        Φ[j, 1] = left_BC.value*2*h + Φ[j, 3]
    end

    right_BC = M[j, size(Φ)[2]-1]
    if right_BC isa dVdn
        Φ[j, size(Φ)[2]] = right_BC.value*2*h + Φ[j, size(Φ)[2]-2]
    end

end


println(repr("text/plain", Φ))


end


#  88.84548611111111
#  88.10763888888889
#  90.66840277777777
#  79.16666666666666
#  72.91666666666666
#  73.95833333333333
#  81.9878472222222
#  50.43402777777776
#  46.83159722222221

# ×7 Matrix{Real}:
#  0.0  0.0  100.0      100.0      100.0      0.0  0.0
#  0.0  0.0   41.8793    51.7006    42.3683   0.0  0.0
#  0.0  0.0   17.7742    24.0234    18.2616   0.0  0.0
#  0.0  0.0    6.65512    9.33332    6.89874  0.0  0.0
#  0.0  0.0    0.0        0.0        0.0      0.0  0.0