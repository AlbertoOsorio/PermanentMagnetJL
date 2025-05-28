using PlotlyJS
include("main/sheets/drawSheet.jl")
include("main/sheets/util.jl")

sheets =   [[[5,-5,0],[5,5,0], [1,0,0]],
            [[5,5,0],[-5,5,0], [0,1,0]], 
            [[-5,5,0],[-5,-5,0], [-1,0,0]], 
            [[-5,-5,0],[5,-5,0], [0,-1,0]]]

cube = [drawSheet(i) for i in sheets]
field = drawB(sheets)

plot(field)