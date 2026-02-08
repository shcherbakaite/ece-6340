using Random

# -----------------------
# Target Definition
# -----------------------
mutable struct Target
    id::Int
    azimuth::Float64       # degrees
    elevation::Float64     # degrees
    az_vel::Float64        # deg/sec
    el_vel::Float64        # deg/sec
    threat_level::Float64
    classification::Symbol # :friend, :foe, :neutral
end

# -----------------------
# Turret Definition
# -----------------------
mutable struct Turret
    azimuth::Float64
    elevation::Float64
    az_speed::Float64  # deg/sec
    el_speed::Float64  # deg/sec
    az_dir::Int        # 1=clockwise, -1=counter
    el_dir::Int
    fov::Tuple{Float64, Float64} # az_fov, el_fov
end

function rotate_turret!(turret::Turret, dt::Float64)
    # Update turret angles based on speed and direction
    turret.azimuth += turret.az_dir * turret.az_speed * dt
    turret.elevation += turret.el_dir * turret.el_speed * dt

    # Reverse sweep if limits reached
    if turret.azimuth > 180
        turret.azimuth = 180
        turret.az_dir *= -1
    elseif turret.azimuth < -180
        turret.azimuth = -180
        turret.az_dir *= -1
    end

    if turret.elevation > 45
        turret.elevation = 45
        turret.el_dir *= -1
    elseif turret.elevation < -10
        turret.elevation = -10
        turret.el_dir *= -1
    end
end

# -----------------------
# Target Tracking
# -----------------------
mutable struct TargetTracker
    targets::Dict{Int, Target}
end

function update_tracker!(tracker::TargetTracker, detected::Vector{Target})
    for t in detected
        tracker.targets[t.id] = t
    end
end

# -----------------------
# Scan Environment (FOV Detection)
# -----------------------
function scan_environment(turret::Turret, all_targets::Vector{Target})
    detected = Target[]
    az_fov, el_fov = turret.fov
    for t in all_targets
        if abs(t.azimuth - turret.azimuth) <= az_fov/2 &&
           abs(t.elevation - turret.elevation) <= el_fov/2
            push!(detected, t)
        end
    end
    return detected
end

# -----------------------
# Fire Policy & Control
# -----------------------
function decide_fire(target::Target)
    return target.classification == :foe && target.threat_level > 0.7
end

function engage_target(target::Target)
    # Simple prediction based on angular velocity
    predicted_az = target.azimuth + target.az_vel * 0.1
    predicted_el = target.elevation + target.el_vel * 0.1
    println("Firing at target $(target.id): predicted az=$(predicted_az), el=$(predicted_el)")
end

function feedback(target::Target, hit::Bool)
    println("Target $(target.id) was $(hit ? "hit" : "missed")")
end

# -----------------------
# Simulation
# -----------------------
# Initialize turret and tracker
turret = Turret(0.0, 0.0, 30.0, 10.0, 1, 1, (30.0, 20.0))
tracker = TargetTracker(Dict())

# Environment: targets with constant motion
all_targets = [
    Target(1, 45.0, 5.0, 0.5, 0.0, 0.8, :foe),
    Target(2, -60.0, 0.0, -0.2, 0.1, 0.5, :foe),
    Target(3, 100.0, 10.0, 0.0, 0.0, 0.9, :friend)
]

# Time-stepped simulation
dt = 0.1   # timestep in seconds
sim_time = 10.0
steps = Int(sim_time / dt)

for step in 1:steps
    # Update turret angles (continuous scanning)
    rotate_turret!(turret, dt)

    # Detect targets in current FOV
    detected = scan_environment(turret, all_targets)
    update_tracker!(tracker, detected)

    # Engage visible targets
    for t in detected
        if decide_fire(t)
            engage_target(t)
            feedback(t, rand() > 0.3)
        end
    end

    # Optional: simulate targets moving
    for t in all_targets
        t.azimuth += t.az_vel * dt
        t.elevation += t.el_vel * dt
    end
end
