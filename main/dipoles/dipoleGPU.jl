using NPZ
using CUDA
using PlotlyJS
using BenchmarkTools
using GPUArrays: @allowscalar
using Distributions, Random
include("../gru.jl")

const μ0 = 4π * 1e-7  

function distribute(arr, magnetization, sigma)
    d = Normal(magnetization, sigma) 
    #td = truncated(d, magnetization - 5, magnetization + 5)
    vals = rand(d, size(arr))
    sampled = vals .* arr
    return sampled
end

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

function B0(rnd=false)
    #zeros(size(z))
    gx = -80:4:80; gy = gx; gz = [-70, -50, -30,-10, 10, 30, 50, 70, 90, 110] #[-60, -40, -20, 0, 20, 40, 60] 
    points_cpu = hcat([[x, y, z] for x in gx, y in gy, z in gz]...)

    data = npzread("main/data/B0.npz")
    positions17 = data["array1"]; moments17 = data["array2"]
    if rnd; ori17 = distribute(moments17, 15, 0.5)
    else; ori17 = moments17 .* 15.
    end

    positions8 = data["array3"]; moments8 = data["array4"]
    if rnd; ori8 = distribute(moments8, 20, 0.5)
    else; ori8 = moments8 .* 20.
    end

    positions = hcat(positions17, positions8); ori = hcat(ori17, ori8)
    pos = cu(positions); m = cu(ori); points = cu(points_cpu)
    B = Bevaluate(m, points, pos)

    XX = [xi for xi in gx, yi in gy, zi in gz]
    mask = trues(size(XX))
    By = zeros(size(XX))
    @allowscalar begin
        By[mask] = B[2,:]
        fig = Figure(size=(600,600))
        saxi = Slicer3D(fig,By,zoom=5)  
        display(fig)
        for (i, zval) in enumerate(1:size(By,3))
            saxi.sliders[1].value[] = zval
            sleep(0.1)
            save("slice_z_$(lpad(i,3,'0')).png", fig)
        end

    end

end