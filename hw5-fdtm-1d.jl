using Plots
gr()

# Parameters
N = 100
H = zeros(N)
E = zeros(N)

μ = 4*pi*1e-7      # H/m
ϵ = 8.85e-12       # F/m

dx = 0.001          # m
c = 3e8             # m/s
dt = dx/c


# Create animation
anim = @animate for iter in 1:100
    # Update H
    for x in 1:N-1
        H[x] += dt/(μ*dx)*(E[x] - E[x+1])
    end

    # Update E
    for x in 2:N
        E[x] += dt/(ϵ*dx)*(H[x-1] - H[x])
    end


    E[Int(N/2)] = sin(iter*dt*2*pi*10e9)

    # Plot E for this frame
    p = plot(1:N, zeros(N), E, ylim=(-5,5), zlim=(-5,5), xlim=(1,N), title="E field at t=$(round(iter*dt*1e9, digits=2)) ns",
         xlabel="x", ylabel="E", legend=false)
    
    plot!(1:N, 377 .* H, zeros(N),
          lw=2, label="H")
end

# Save as GIF
gif(anim, "E_wave.gif", fps=20)