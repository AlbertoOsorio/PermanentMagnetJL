using PlotlyJS
using GPUArrays: @allowscalar
include("main/sheets/utilGPU.jl")

sheets =   [[[5,-5,0],[5,5,0], [1,0,0]],
            [[5,5,0],[-5,5,0], [0,1,0]], 
            [[-5,5,0],[-5,-5,0], [-1,0,0]], 
            [[-5,-5,0],[5,-5,0], [0,-1,0]]]

ra = stack([[5,-5,0],[5,5,0],[-5,5,0],[-5,-5,0]])
rb = stack([[5,5,0],[-5,5,0],[-5,-5,0],[5,-5,0]])
nn = stack([[1,0,0],[0,1,0],[-1,0,0],[0,-1,0]])

@allowscalar begin
    field = drawBGPU(ra, rb, nn)
    p = plot(field, Layout(
        scene=attr(
            xaxis=attr(range=[-10, 10]),  
            yaxis=attr(range=[-10, 10]),    
            zaxis=attr(range=[-10, 10]),     
            aspectmode="manual",           
            aspectratio=attr(x=1, y=1, z=1)  
        ),
        width=800, 
        height=600
    ))
end