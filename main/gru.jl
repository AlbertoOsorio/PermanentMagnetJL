using GLMakie

"""
    Slicer3D(fig, data;
             colormap = :inferno,
             colorrange = nothing,
             zoom::Int = 1,
             haircross = true,
             pointvalue = true)

Crea en `fig` un layout con tres vistas (axial, sagital y coronal) de la matriz 3D `data`, 
más tres sliders: uno para X, otro para Y y otro para Z. 
Además devuelve el objeto `saxi` correspondiente al SliderGrid de Z, 
para que puedas modificarlo externamente.
"""
function Slicer3D(fig, data;
                  colormap = :inferno,
                  colorrange = nothing,
                  zoom::Int = 1,
                  haircross = true,
                  pointvalue = true)

    debug = true

    # --------------------------------------------------
    # Data: dims = (sagital = X, coronal = Y, axial = Z)
    sizesag, sizecor, sizeaxi = size(data)
    # Tamaño escalado para ejes según el zoom
    zsizesag, zsizecor, zsizeaxi = zoom .* size(data)
    # Punto central para sliders iniciales
    startpoint = Point3(Int.(round.(size(data) ./ 2)))

    # Determinar rango de color si no se provee
    if isnothing(colorrange)
        crange = extrema(filter(!isnan, data))
    else
        crange = colorrange
    end

    if debug
        println("size(data) = $(size(data))")
        println("crange = $crange")
    end
    # --------------------------------------------------

    # Crear ejes:
    #   [  (1,2) ]  -> vista axial (XY)
    #   [  (2,1) ]  -> vista sagital (ZY)
    #   [  (2,2) ]  -> vista coronal (XZ)
    # --------------------------------------------------
    aaxi = Axis(fig[1, 2], aspect = DataAspect(), height = zsizecor, width = zsizesag)
    asag = Axis(fig[2, 1], aspect = DataAspect(), height = zsizeaxi, width = zsizecor)
    acor = Axis(fig[2, 2], aspect = DataAspect(), height = zsizeaxi, width = zsizesag)

    hidespines!(aaxi);  hidedecorations!(aaxi)
    hidespines!(acor);  hidedecorations!(acor)
    hidespines!(asag);  hidedecorations!(asag)

    # Label para mostrar el valor del punto seleccionado
    lpvalue = Label(fig[3, 1], "")

    # SliderGrid para Z (axial), X (sagital) y Y (coronal)
    saxi = SliderGrid(fig[2, 3],
        (range = 1:sizeaxi, startvalue = startpoint[3],
         horizontal = false, height = zsizeaxi))
    ssag = SliderGrid(fig[3, 2],
        (range = 1:sizesag, startvalue = startpoint[1],
         horizontal = true, width = zsizesag))
    scor = SliderGrid(fig[1, 3],
        (range = 1:sizecor, startvalue = startpoint[2],
         horizontal = false, height = zsizecor))
    # --------------------------------------------------

    # Parte interactiva
    @lift begin
        x = $(ssag.sliders[1].value)
        y = $(scor.sliders[1].value)
        z = $(saxi.sliders[1].value)

        # Vista sagital (datos[x, :, :]) — eje Z vertical, eje Y horizontal
        heatmap!(asag, data[x, :, :], colormap = colormap, colorrange = crange)

        # Vista coronal (datos[:, y, :]) — eje Z vertical, eje X horizontal
        heatmap!(acor, data[:, y, :], colormap = colormap, colorrange = crange)

        # Vista axial (datos[:, :, z]) — eje Y vertical, eje X horizontal
        heatmap!(aaxi, data[:, :, z], colormap = colormap, colorrange = crange)

        if haircross
            # Líneas cruzadas para indicar la posición actual
            lines!(aaxi, [1; sizesag], [y; y], color = :white)
            lines!(aaxi, [x; x], [1; sizecor], color = :white)

            lines!(acor, [1; sizesag], [z; z], color = :white)
            lines!(acor, [x; x], [1; sizeaxi], color = :white)

            lines!(asag, [1; sizecor], [z; z], color = :white)
            lines!(asag, [y; y], [1; sizeaxi], color = :white)
        end

        if pointvalue
            lpvalue.text = @sprintf("(%d, %d, %d) → %.2f", x, y, z, data[x, y, z])
        end
    end

    # Devolvemos el objeto del slider axial para control externo
    return saxi
end