using PlotlyJS
using GPUArrays: @allowscalar
include("coreGPU.jl")

function B(ra, rb, nn)
    w = 30
    gx = -w:3:w; gy = zeros(size(gx)); gz = gx

    p = hcat([[x, y, z] for x in gx, y in gy, z in gz]...)
    B = BfSheet(ra, rb, nn, p)

    return cone(x=p[1,:], y=p[2,:], z=p[3,:], u=B[1,:], v=B[2,:], w=B[3,:])
end

sheets =   [[[5,-5,0],[5,5,0], [1,0,0]],
            [[5,5,0],[-5,5,0], [0,1,0]], 
            [[-5,5,0],[-5,-5,0], [-1,0,0]], 
            [[-5,-5,0],[5,-5,0], [0,-1,0]]]

ra = stack([[5,-5,0],[5,5,0],[-5,5,0],[-5,-5,0]])
rb = stack([[5,5,0],[-5,5,0],[-5,-5,0],[5,-5,0]])
nn = stack([[1,0,0],[0,1,0],[-1,0,0],[0,-1,0]])

@allowscalar begin
    field = B(ra, rb, nn)
    p = plot(field, Layout(
        scene=attr(
            xaxis=attr(range=[-20, 20]),  
            yaxis=attr(range=[-20, 20]),    
            zaxis=attr(range=[-20, 20]),     
            aspectmode="manual",           
            aspectratio=attr(x=1, y=1, z=1)  
        ),
        width=800, 
        height=600
    ))
end