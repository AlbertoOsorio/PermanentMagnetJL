using PlotlyJS
include("coreGPU.jl")

function drawBGPU(ra, rb, nn)
    w = 2
    gx = -w:1:w; gy = gx; gz = gx

    points_cpu = hcat([[x, y, z] for x in gx, y in gy, z in gz]...)

    B = [BsheetGPU(ra, rb, nn, p) for p in eachcol(points_cpu)]

    #return cone(x=p[1,:], y=p[2,:], z=p[3,:], u=B[1,:], v=B[2,:], w=B[3,:])
end
