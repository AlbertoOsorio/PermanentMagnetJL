using LinearAlgebra

function Bevaluate(u, p, val) # donde u es un vector en z y p el punto donde evaluamos el cambo magnetico
    p_hat = p/(norm(p))
    B = ((dot(u, p_hat)*p_hat*3)-u)*(val/(4* pi *(norm(p)^3)))
end
