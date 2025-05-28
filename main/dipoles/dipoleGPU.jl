using NPZ
using CUDA
using PlotlyJS
using BenchmarkTools
using GPUArrays: @allowscalar

const μ0 = 4π * 1e-7  

function makeRing(Nmag, r, magnitude)
    pos = hcat([[r*cos(2*π*n/Nmag+π/2); r*sin(2*π*n/Nmag+π/2); 0] for n in 0:Nmag-1]...)
    m = hcat([[cos(4*π*n/Nmag+π/2); sin(4*π*n/Nmag+π/2); 0.].*magnitude for n in 0:Nmag-1]...)
    return pos, m
end

function Bevaluate(u::CuArray, p::CuArray, pos::CuArray)
    dm = reshape(u, 3, 1, :)
    r = reshape(p, 3, :, 1) .- reshape(pos, 3, 1, :) 
    r_hat = r ./ sqrt.(sum(r .^ 2; dims=1))
    B = μ0 .* (3 .* sum(dm .* r_hat; dims=1) .* r_hat .- dm) ./ (sqrt.(sum(r .^ 2; dims=1)).^3)
    return dropdims(sum(B; dims=3); dims=3)
end


function RingGeneric(Nmagnets::Int, viz=false)
    w = 80
    gx = -w:4:w; gy = gx; gz = gx

    r_ring = 150.
    
    points_cpu = hcat([[x, y, z] for x in gx, y in gy, z in gz]...)
    positions, moments = makeRing(Nmagnets, r_ring, 10)
    pos = cu(positions); m = cu(moments); points = cu(points_cpu)

    B = Bevaluate(m, points, pos)

    if viz
        @allowscalar plot(cone(x=points[1,:], y=points[2,:], z=points[3,:], u=B[1,:], v=B[2,:], w=B[3,:]))
    end
end

function B0(viz=false)
    gx = -150:5:150;; gy=gx; gz=gx; x = gx; z = gz 
    y = gy#zeros(size(z))

    data = npzread("main/data/B0.npz")
    positions = data["array1"]; moments = data["array2"]
    points_cpu = hcat([[x, y, z] for x in gx, y in gy, z in gz]...)
    pos = cu(positions); m = cu(moments); points = cu(points_cpu)

    B = Bevaluate(m, points, pos)

    if viz
        @allowscalar plot(cone(x=points_cpu[1,:], y=points_cpu[2,:], z=points_cpu[3,:], u=B[1,:], v=B[2,:], w=B[3,:]))
    end
end