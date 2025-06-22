using LinearAlgebra
using PlotlyJS

function drawSheet(sheet)
    ra = sheet[1]; rb = sheet[2]; nn = sheet[3]

    r_hat = rb/(norm(rb))
    p_hat = cross(r_hat, nn); p_hat /= norm(p_hat)
    p = p_hat*norm(rb-ra)/2
    sp_dir = -2*p

    p1 = ra+p; p2 = ra-p; p3 = rb+p; p4 = rb-p
    vertices = [p1, p2, p3, p4]

    return mesh3d(x=[i[1] for i in vertices], y=[i[2] for i in vertices], z=[i[3] for i in vertices],
                    i=[0, 1], j=[1, 2], k=[2, 3], opacity=0.8, color="blue")
end