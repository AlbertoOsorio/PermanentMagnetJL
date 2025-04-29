using GLMakie
include("main/drawSheet.jl")
include("main/util.jl")

fig = Figure()
ax = Axis3(fig[1, 1], aspect=(1,1,1)) 

sheets = [[[5,-5,0],[5,5,0], [1,0,0]], [[5,5,0],[-5,5,0], [0,1,0]], [[-5,5,0],[-5,-5,0], [-1,0,0]], [[-5,-5,0],[5,-5,0], [0,-1,0]]]
drawSheet(sheets[1]); drawSheet(sheets[2]); drawSheet(sheets[3]); drawSheet(sheets[4])

tester(sheets)

fig