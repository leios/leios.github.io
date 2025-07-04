export run_starry_night

function is_star(frequency)
    if rand() < frequency
        return true
    end
    return false
end

@kernel function night_shade!(image, horizon, size_per_pixel)
    j, i = @index(Global, NTuple)

    y = j*size_per_pixel
    if y <= horizon
        if is_star(0.001)
            image[j, i] = RGBA(1,1,1,1)
        else
            red = exp(10*(y-horizon))
            green = exp(10*(y-horizon))
            blue = exp(6*(y-horizon))
            image[j, i] = RGBA(red, green, blue, 1)
        end
    else
        image[j, i] = RGBA(0, 0, 0, 1)
    end 

end

function run_starry_night(; array_size=(1080,1920), ArrayType=Array, filename="out.png", num_threads=256)

    image=ArrayType((zeros(RGBA, array_size...)))
    backend = get_backend(image)
    kernel! = night_shade!(backend, num_threads)

    horizon = 0.9
    size_per_pixel = 1/array_size[1]
    kernel!(image, horizon, size_per_pixel;ndrange = size(image))
    
    save(filename, Array(image))
    
end

