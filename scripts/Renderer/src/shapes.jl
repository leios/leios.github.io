export run_shapes

abstract type Shape end;

struct Shape
    y
    x
    location
    rotation
    fx
end

struct Circle{T, C} <: Shape where {T <: Number, C <:Union{RGB{Float32}, RGBA{Float32}}}
    y::T
    x::T
    radius::T
    color::C
end

function create_circle(y, x, radius, color)
    return Circle(y, x, radius, color)
end

function in_shape(circle::Circle, y, x)
    if (y-circle.y)^2 + (x-circle.x)^2 <= circle.radius^2
        return true
    end
    return false
end

struct Square{T, C} <: Shape where {T <: Number, C <:Union{RGB{Float32}, RGBA{Float32}}}
    y::T
    x::T
    size::T
    rotation::T
    color::C
end

function create_square(y, x, size, rotation, color)
    return Square(y, x, size, rotation, color)
end

# This is still broken
function in_shape(square::Square, y, x)
    if abs(x*cos(square.rotation)-square.x) < square.size &&
       abs(y*sin(square.rotation)-square.y) < square.size
        return true
    end

    return false
end

@kernel inbounds=true function shape_shade!(image, size_per_pixel, shapes)
    j, i = @index(Global, NTuple)
    y = (j-size(image)[1]*0.5)*size_per_pixel[1]
    x = (i-size(image)[2]*0.5)*size_per_pixel[2]

    for shape in shapes
        if in_shape(shape, y, x)
            image[j, i] = image[j,i]*(1-shape.color.alpha) + shape.color*shape.color.alpha
        end
    end
end

function run_shapes(; array_size=(1080,1920), ArrayType=Array, filename="out.png", num_threads=256, max_size = (0.9, 1.6))

    image=ArrayType((zeros(RGBA{Float32}, array_size...)))
    backend = get_backend(image)
    kernel! = shape_shade!(backend, num_threads)

    size_per_pixel = (max_size[1]/array_size[1], max_size[2]/array_size[2])
    println(size_per_pixel)

    simple_circle = create_circle(0.0, 0.0, 0.5, RGBA{Float32}(1, 0, 1, 0.5))
    simple_square = create_square(0.05, 0.1, 0.1, 0.15*pi, RGBA{Float32}(0, 0, 1, 0.5))
    shapes = (simple_circle, simple_square)
    #shapes = (simple_circle,)
    kernel!(image, size_per_pixel, shapes;ndrange = size(image))
    
    save(filename, Array(image))
    
end

