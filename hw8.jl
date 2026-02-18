using Plots
gr()

# --------------------------------------------------------------------------- #
# Physical constants
# --------------------------------------------------------------------------- #
μ0 = 4π * 1e-7      # H/m
ϵ0 = 8.85e-12      # F/m
c  = 3e8           # m/s

# --------------------------------------------------------------------------- #
# Simulation parameters
# --------------------------------------------------------------------------- #
f = 2e9            # source frequency, Hz
λ = c / f          # wavelength in air, m
N = 120            # number of E nodes
dx = λ / 20        # grid spacing, m
dt = dx / (2c)     # time step (Courant)

# --------------------------------------------------------------------------- #
# Material: air → quarter-wave transformer → medium
# --------------------------------------------------------------------------- #
ϵr_medium = 4.0
ϵr_qTX    = sqrt(ϵr_medium)           # impedance match: η_tx = √(η₀ η_medium)
λ_qTX     = λ / sqrt(ϵr_qTX)          # wavelength in transformer
n_cells_qtx = max(1, round(Int, (λ_qTX/4) / dx))
layer_start  = 75
layer_end_qtx = layer_start + n_cells_qtx - 1

ϵ = fill(ϵ0, N)
for i in layer_start:N
    ϵ[i] = ϵr_medium * ϵ0
end
for i in layer_start:layer_end_qtx
    ϵ[i] = ϵr_qTX * ϵ0
end

# --------------------------------------------------------------------------- #
# Fields and Mur BC coefficients
# --------------------------------------------------------------------------- #
H = zeros(N)
E = zeros(N)
E_old = zeros(N)

v_medium   = c / sqrt(ϵr_medium)
coef_left  = (c*dt - dx) / (c*dt + dx)
coef_right = (v_medium*dt - dx) / (v_medium*dt + dx)
#coef_right = coef_left;

peak_E = 0

# --------------------------------------------------------------------------- #
# Time stepping and animation
# --------------------------------------------------------------------------- #
anim = @animate for iter in 1:1000
    E_old .= E

    # H update
    for x in 1:N-1
        H[x] += (dt / (μ0*dx)) * (E[x] - E[x+1])
    end

    # E update
    for x in 2:N
        E[x] += (dt / (ϵ[x]*dx)) * (H[x-1] - H[x])
    end

    # peak detection
    global peak_E = max(E[100], peak_E)

    # Soft source
    E[Int(N/2)] += sin(iter * dt * 2π * f)

    # Mur ABCs
    E[1] = E_old[2]   + coef_left  * (E[2]   - E_old[1])
    E[N] = E_old[N-1] + coef_right * (E[N-1] - E_old[N])

    # Plot
    plot(1:N, E;
        xlim=(1, N), ylim=(-5, 5), lw=2, label="E",
        title="Fields at t=$(round(iter*dt*1e9, digits=2)) ns",
        xlabel="x", ylabel="Field amplitude")
    vline!([layer_start],      color=:gray, ls=:dash, label="tx start")
    vline!([layer_end_qtx+1],  color=:gray, ls=:dash, label="tx end")
end

println("peak $(peak_E)");

#gif(anim, "E_wave.gif", fps=20)
