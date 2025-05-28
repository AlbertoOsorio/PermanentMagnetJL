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


function Evaluate(Nmagnets)
    w = 80
    gx = -w:4:w; gy = gx; gz = gx
    
    points_cpu = hcat([[x, y, z] for x in gx, y in gy, z in gz]...)
    points = cu(points_cpu)
    
    r_ring = 150.
    positions, moments = makeRing(Nmagnets, r_ring, 10)
    pos = cu(positions); m = cu(moments)

    B = Bevaluate(m, points, pos)

    #@allowscalar begin
    #    plot(cone(x=points[1,:], y=points[2,:], z=points[3,:], u=B[1,:], v=B[2,:], w=B[3,:]))
    #end

end

function B0()
    gx = -150:4:150; gy = gx; gz = -140:4:140
    points_cpu = hcat([[x, y, z] for x in gx, y in gy, z in gz]...)
    points = cu(points_cpu)

    data = npzread("B0.npz")
    positions = data["array1"]
    moments = data["array2"]
    pos = cu(positions); m = cu(moments)
    B = Bevaluate(m, points, pos)
    @allowscalar begin
        plot(cone(x=points[1,:], y=points[2,:], z=points[3,:], u=B[1,:], v=B[2,:], w=B[3,:]))
    end
end