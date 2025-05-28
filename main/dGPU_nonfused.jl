using CUDA
using PlotlyJS
using BenchmarkTools
using GPUArrays: @allowscalar

const μ0 = 4π * 1e-7  

function makeRing(Nmag, r, magnitude)
    pos = [[r*cos(2*π*n/Nmag+π/2); r*sin(2*π*n/Nmag+π/2); 0] for n in 0:Nmag-1]
    m = [[cos(4*π*n/Nmag+π/2); sin(4*π*n/Nmag+π/2); 0.].*magnitude for n in 0:Nmag-1]
    return pos, m
end

function Bevaluate(u::CuArray, p::CuArray, pos::CuArray)
    r = p .- pos 
    r2 = sum(r .^ 2; dims=1)
    r_hat = r ./ sqrt.(r2)
    B = μ0 .* (3 .* sum(u .* r_hat; dims=1) .* r_hat .- u) ./ (sqrt.(sum(r.^2; dims=1)).^3)
    return B
end

function drawDipole(Nmagnets)
    w = 80
    gx = -w:4:w; gy = gx; gz = gx
    points_cpu = hcat([[x, y, z] for x in gx, y in gy, z in gz]...)
    points = cu(points_cpu)

    r_ring = 150.0
    positions, moments = makeRing(Nmagnets, r_ring, 10.0)

    B = sum([Bevaluate(cu(m), points, cu(pos)) for (pos, m) in zip(positions, moments)])

    #@allowscalar begin
    #    plot(cone(x=points[1,:], y=points[2,:], z=points[3,:], u=B[1,:], v=B[2,:], w=B[3,:]))
    #end
end
