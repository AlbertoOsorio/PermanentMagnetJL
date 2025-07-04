using BenchmarkTools
using GPUArrays: @allowscalar
using GLMakie, LinearAlgebra

# Types
@kwdef mutable struct MagnetT
    c::Vector{Float32} = [0;0;0]   # 3D vector with coordinates of center of magnet
    rh::Vector{Float32} = [0;0;0]  # 3D vector from center to height of box 
    rw1::Vector{Float32} = [0;0;0] # 3D vector from center to first lateral side
    rw2::Vector{Float32} = [0;0;0] # 3D vector from center to second lateral side

    ra = zeros(3,4)
    rb = zeros(3,4)
    nn = zeros(3,4)
    misc = zeros(1,2)
end

# Auxiliary functions
    include("ComputeB.jl")
    include("MagnetUtil.jl")
    include("GraphUtil.jl")
    include("gru.jl")

# What to do
compute_field = true
plot_field = true
plot_type = "sliders"
plot_magnets = true

# Parameters
    wx = 10.0           # Dimensions of each magnet in mm
    wy = wx
    wz = 15.0
    alpha = wz/wx       # Aspect ratio of magnet (width as a proportion of length)
    Br = 1.             # Remanent field of magnet in T
    r_ring = 150.       # outwards radial displacement of cube [mm]
    Nmagnets = 16       # number of magnets per ring
    Nrings = 5          # number of rings (must be odd)
    RingsSep = 15.      # separation between rings
    ROIr = 80.          # Region Of Interest radius in xy
    ROIh = 80.          # Region of interest height in z

# Makes the Halbach array. Array of magnets
Magnet = Array{MagnetT, 1}(undef, 0) 
for k in 0:Nrings-1
    global Magnet = [Magnet;makeRing(Nmagnets,r_ring,wz,wx,-RingsSep*k)]
end

# Compute the field
if compute_field
    xx = -ROIr:4:ROIr
    yy = -ROIr:4:ROIr
    zz = -ROIh:4:ROIh

    # Create meshgrid in the range specified
    XX = [xi for xi in xx, yi in yy, zi in zz]
    YY = [yi for xi in xx, yi in yy, zi in zz]
    ZZ = [zi for xi in xx, yi in yy, zi in zz]

    # All points with shape (3, n)
    p = hcat([[x, y, z] for x in xx, y in yy, z in zz]...)

    # mask points that are IN a magnet
    mask = trues(size(XX))
    for p in eachindex(XX)
        mask[p] = .! inMagnets(Magnet,[XX[p];YY[p];ZZ[p]],5)
    end

    # Compute the field for all points and store it in B (in mT)
    # Collect all results in CPU memory first
    cpu_results = []
    for mag in Magnet
        partial_B = computeB(mag, p)
        push!(cpu_results, Array(partial_B))  # Move to CPU
        CUDA.unsafe_free!(partial_B)
        CUDA.synchronize()
        GC.gc()
    end

    # Transfer back to GPU and sum
    B = sum(cu.(cpu_results)) .* 1000.
end

# plot vector field
if plot_field
    @allowscalar begin
        By = zeros(size(XX))
        By[mask] = B[2,:]
        fig = Figure(size=(600,600))
        saxi = Slicer3D(fig,By,zoom=5)   
        display(fig)
        #for (i, zval) in enumerate(1:size(By,3))
        #    saxi.sliders[1].value[] = zval
        #    sleep(0.1)
        #    save("imgs/slice_z_$(lpad(i,3,'0')).png", fig)
        #end
    end
end

# plot magnets
if plot_magnets
    if !(@isdefined fig) || !(fig isa Makie.Figure)
        fig = Figure()
    end

    ax = Axis3(saxi,limits=(-160,160,-160,160,-160,160))
    for n in eachindex(Magnet)
        vertices,faces,cs = draw3Dmagnet(Magnet[n])
        mesh!(ax,vertices,faces,color=cs)
    end

    display(fig)
end