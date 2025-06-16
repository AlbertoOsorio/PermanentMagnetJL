using PlotlyJS
include("main/sheets/util.jl")

sheets =   [[[5,-5,0],[5,5,0], [1,0,0]],
            [[5,5,0],[-5,5,0], [0,1,0]], 
            [[-5,5,0],[-5,-5,0], [-1,0,0]], 
            [[-5,-5,0],[5,-5,0], [0,-1,0]]]

field = drawB(sheets)