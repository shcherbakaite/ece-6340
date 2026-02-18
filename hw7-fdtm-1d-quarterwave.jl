using Plots
gr()

# Parameters
N = 120
H = zeros(N)
E = zeros(N)
E_old = zeros(N)   # must be a separate array so Mur BC has previous time step

μ0 = 4*pi*1e-7      # H/m
ϵ0 = 8.85e-12       # F/m

# Material: layer at x = 75 (dielectric slab)
ϵ = fill(ϵ0, N)
layer_center = 75
layer_halfwidth = 1   # layer from 74 to 76
ϵr_layer = 4.0       # relative permittivity of layer
for i in (layer_center - layer_halfwidth):(layer_center + layer_halfwidth)
    if 1 ≤ i ≤ N
        ϵ[i] = ϵr_layer * ϵ0
    end
end

c = 3e8             # m/s
f = 2e9
λ = c/f

dx = λ/20          # m

dt = dx/(2*c)
#dt = dx / c

# Create animation
anim = @animate for iter in 1:1000

    # Save old E
    E_old .= E

    for x in 1:N-1
        H[x] += dt/(μ0*dx)*(E[x] - E[x+1])
    end

    # Update E (uses ϵ[x] for material layer)
    for x in 2:N
        E[x] += dt/(ϵ[x]*dx)*(H[x-1] - H[x])
    end

    # Add soft source
    E[Int(N/2)] = E[Int(N/2)] + sin(iter*dt*2*pi*f)


    # Mur ABCs
    coef = (c*dt - dx) / (c*dt + dx)

    E[1] = E_old[2]     + coef * (E[2]     - E_old[1])
    E[N] = E_old[N-1]   + coef * (E[N-1]   - E_old[N])




    # Plot E for this frame
    # p = plot(1:N, zeros(N), E, ylim=(-5,5), zlim=(-5,5), xlim=(1,N), title="E field at t=$(round(iter*dt*1e9, digits=2)) ns",
    #      xlabel="x", ylabel="E", legend=false)
    
    # plot!(1:N, 377 .* H, zeros(N),
    #       lw=2, label="H")
    p = plot(
    1:N, E,
    ylim=(-5,5),
    xlim=(1,N),
    lw=2,
    label="E",
    title="Fields at t=$(round(iter*dt*1e9, digits=2)) ns",
    xlabel="x",
    ylabel="Field amplitude"
)
    vline!([75], color=:gray, ls=:dash, label="layer")

end

# Save as GIF
gif(anim, "E_wave.gif", fps=20)