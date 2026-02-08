# -----------------------------
# Direct SOR solver with ε interface at i=3
# -----------------------------
using Printf

# Define node type
struct V
    id::Int
end

# Grid setup
M = [
    100  100   100   0    100  100  100;  # row 1
      0  V(1)   100   0    100  V(9)  0;  # row 2
      0  V(2)   100   100  100  V(8)  0;  # row 3 -- interface
      0  V(3)   V(4)  V(5) V(6) V(7)  0;  # row 4
      0   0      0     0    0    0     0;  # row 5
]

# Physical constants
e0   = 8.85418782e-12
e_r1 = e0
e_r2 = 9.6*e0
e_av = (e_r1 + e_r2)/2

# SOR relaxation factor
ω = 1.5

# Initialize Φ array
Φ = map(x -> x isa Number ? Float64(x) : 0, M)

# Build per-cell permittivity array
eps = fill(e_av, size(Φ))
for i in 1:size(Φ,1)
    for j in 1:size(Φ,2)
        if i <= 3
            eps[i,j] = e_r1
        else
            eps[i,j] = e_r2
        end
    end
end

# Collect the V nodes
nodes = Vector{Tuple}()
for I in CartesianIndices(M)
    i,j = Tuple(I)
    if typeof(M[i,j]) == V
        push!(nodes, (i,j))
    end
end

# -----------------------------
# Main SOR iteration
# -----------------------------
max_iter = 1000
tol = 1e-6

for iter in 1:max_iter
    Rmax = 0.0

    for (i,j) in nodes
        # --- interface row (i==3) ---
        if i == 3
            # face-average permittivities
            epsN = 0.5*(eps[i,j] + eps[i-1,j])
            epsS = 0.5*(eps[i,j] + eps[i+1,j])
            epsE = 0.5*(eps[i,j] + eps[i,j+1])
            epsW = 0.5*(eps[i,j] + eps[i,j-1])

            den = epsN + epsS + epsE + epsW
            Φ_new = (epsN*Φ[i-1,j] + epsS*Φ[i+1,j] + epsE*Φ[i,j+1] + epsW*Φ[i,j-1]) / den
            R = Φ_new - Φ[i,j]
        else
            # standard constant-ε Laplace update
            R = (Φ[i+1,j] + Φ[i-1,j] + Φ[i,j+1] + Φ[i,j-1] - 4*Φ[i,j]) / 4
        end

        # SOR update
        Φ[i,j] += ω * R

        # track max residual
        Rmax = max(Rmax, abs(R))
    end

    # convergence check
    if Rmax < tol
        @printf("Converged at iteration %d, Rmax=%.3e\n", iter, Rmax)
        break
    end
end

# -----------------------------
# Print final potential
# -----------------------------
println("Φ = ")
for row in 1:size(Φ,1)
    println(Φ[row,:])
end
