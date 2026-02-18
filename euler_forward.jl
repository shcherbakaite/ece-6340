using Plots

# Clear equivalent (not really needed in Julia, but conceptually)
dt_vals = [0.1, 0.5, 1.5, 2.5]
t_end = 5.0

t_exact = range(0, t_end, length=500)
u_exact = exp.(-t_exact)

plot(
    t_exact,
    u_exact,
    lw=2,
    color=:black,
    label="Exact",
    grid=true
)

for dt in dt_vals
    t = 0:dt:t_end
    u = zeros(length(t))
    u[1] = 1.0

    for n in 1:length(t)-1
        u[n+1] = u[n] - dt * u[n]
    end

    plot!(
        t,
        u,
        seriestype=:scatter,
        marker=:circle,
        label="dt = $dt"
    )
    plot!(
        t,
        u,
        label=nothing
    )
end

xlabel!("t")
ylabel!("u(t)")
title!("Effect of Time Step on Stability")
