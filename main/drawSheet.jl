using LinearAlgebra
using GLMakie
using GeometryBasics: Point3f, GLTriangleFace

function drawSheet(sheet)
    ra = sheet[1]; rb = sheet[2]; nn = sheet[3]

    r_hat = rb/(norm(rb))
    p_hat = cross(r_hat, nn); p_hat /= norm(p_hat)
    p = p_hat*norm(rb-ra)/2
    sp_dir = -2*p
    sheet = [ra, rb, nn, sp_dir]

    point1 = ra+p; p1 = Point3f(point1[1], point1[2], point1[3])
    point2 = ra-p; p2 = Point3f(point2[1], point2[2], point2[3])
    point3 = rb+p; p3 = Point3f(point3[1], point3[2], point3[3])
    point4 = rb-p; p4 = Point3f(point4[1], point4[2], point4[3])
    vertices = [p1, p2, p3, p4]
    faces = [
        GLTriangleFace(1, 2, 3),  
        GLTriangleFace(2, 4, 3)   
    ]

    x = [ra[1], rb[1]]; y = [ra[2], rb[2]]; z = [ra[3], rb[3]]
    xn = [0,nn[1]]; yn = [0,nn[2]]; zn = [0,nn[3]]
    xp = [0,p[1]]; yp = [0,p[2]]; zp = [0,p[3]]
    xe = [0,sp_dir[1]]; ye = [0,sp_dir[2]]; ze = [0,sp_dir[3]]

    lines!(ax, x, y, z, color=:lightgreen)                                  #Line of current. From ra to rb
    #arrows!(ax, x, y, z, xn, yn, zn, color=:magenta, arrowsize=0.03)                                  #Normal to the plane
    mesh!(ax, vertices, faces, color = :blue, transparency = true)          #Plane sheet
    #scatter!(ax, ra[1], ra[2], ra[3], color=:red)                           #Ball point in ra
    arrows!(ax, xp, yp, zp, xe, ye, ze, color=:lightyellow, arrowsize=0.03) #EasyAxis

    xlims!(ax, -10, 10)
    ylims!(ax, -10, 10)
    zlims!(ax, -10, 10)

end