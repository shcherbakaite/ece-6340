# Direct SOR solver
using Plots

struct V
    id::Int
end

M =
[100  100   100   0    100  100  100;         # e1
 0    V(1)  100   0    100  V(9)  0;          # e1
 0    V(2)  100   100  100  V(8)  0;          # e2, i = 3
 0    V(3)  V(4)  V(5) V(6) V(7)  0;          # e2
 0    0     0     0    0    0     0;];        # e2

e0 = 8.85418782e-12

e_r1 = e0

e_r2 = 9.6*e0

e_av = (e_r1 + e_r2)/2

# Initialize result
Φ = map(x -> x isa Number ? Float64(x) : 0, M)

# Get node coordinates
nodes = Vector{Tuple}()
for I in CartesianIndices(M)
    i,j = Tuple(I)
    v = M[i, j]
    if typeof(v) == V
        push!(nodes, Tuple(I))
    end
    println(M[i,j])
end


for n in range(1,1000) 
    R = 0;
    # Iterate over nodes
    for (i, j) in nodes
        # Handle e1 to e2 interface
        if i == 3
            R = (1/(4*e_av))*( e_r1*Φ[i-1,j] + e_r2*Φ[i+1,j] + e_av*Φ[i,j-1] + e_av*Φ[i,j+1] -4*e_av*Φ[i,j] )
        # Handle constant e
        else
            R = ( Φ[i+1,j] + Φ[i-1,j] + Φ[i,j+1] + Φ[i,j-1] - 4*Φ[i,j] )/4
        end

        Φ[i,j] = Φ[i,j] + R
    end

    println(R) 
    if R < 0.000001 
        break
    end

end

# function node_equation(i,j)
#     R = zeros(10)

#     v = M[i, j]
#     R[v.id] = -4

#     v_t = M[i+1, j]
#     v_d = M[i-1, j]
#     v_l = M[i, j-1]
#     v_r = M[i, j+1]

#     for v in [v_t, v_d, v_l, v_r] 
#         if typeof(v) == V
#             R[v.id] = 1
#         else
#             R[10] -= v
#         end
#     end

#     return R
# end

# A = [node_equation(2,2)';
#      node_equation(3,2)';
#      node_equation(4,2)';
#      node_equation(4,3)';
#      node_equation(4,4)';
#      node_equation(4,5)';
#      node_equation(4,6)';
#      node_equation(3,6)';
#      node_equation(2,6)';]

# b = A[:,10]
# A = A[:,1:9]

# x = A \ b

#println(repr("text/plain", A))

println(repr("text/plain", Φ))

# map(v ->
#     if typeof(v) == V
#         x[v.id]
#     else
#         v
#     end
# , Φ)

# Φ is already a Matrix{Float64}
heatmap(
    reverse(Φ, dims=1),
    clim = (0, 100),
    aspect_ratio = 1,
    color =  :hot,
    colorbar = true,
    xlabel = "x",
    ylabel = "y",
    title = "Cell Potentials Φ"
)

