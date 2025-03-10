function B_onpoint(sheet, vertices, point)
    ra = sheet[1]; rb = sheet[2]; nn = sheet[3]; pp = sheet[4]

    A=dot(point-ra,point-ra)
    B=dot(point-ra,rb-ra)
    C=dot(rb-ra,rb-ra)
    D=dot(point-ra,pp)
  
    a1=A*C-2*B*C+C*C
    b1=-2*C*D
    c1=1^2*C^2
    p1=-(C-B)^2
  
    a2=A*C
    b2=-2*C*D
    c2=1^2*C^2
    p2=-B^2

    JJ1=integral_GR2284(0,1,a1,b1,c1,p1)
    JJ2=integral_GR2284(1,0,a1,b1,c1,p1)
    JJ3=integral_GR2284(0,1,a2,b2,c2,p2)
    JJ4=integral_GR2284(1,0,a2,b2,c2,p2)

    out=cross(rb-ra,r2-ra)*1*C*((C-B)*JJ1+B*JJ3) + 1^2*C^2*nn*((C-B)*JJ2+ B*JJ4)
    out=out*Br/(4*pi)
    Bout=Bout+out
    return Bout

end

function integral_GR2284(AA,BB,a,b,c,p)
    