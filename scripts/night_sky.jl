export night_sky

@inline function star_texture(y, x, red, green, blue, seed)
    # just a complicated expression
    rand_inner = abs(y*x*simple_rand(seed) / typemax(UInt)) * typemax(UInt)
    if simple_rand(ceil(UInt, rand_inner)) / typemax(UInt) > 0.995
        return RGBA{Float32}(1, 1, 1, 1)
    else
        return RGBA{Float32}(red, green, blue, 1.0)
    end
end

@inline function moon_texture(y, x, moon_loc, moon_scale)
    red = 0.9
    green = 0.9
    blue = 0.9
    hole_radius = moon_scale*0.15
    if in_blob(y, x, (moon_loc[1]-moon_scale*0.4,
                      moon_loc[2]-moon_scale*0.05),
               pi/4, hole_radius, (2, 20, 3),
               (0.3*hole_radius, 0.05*hole_radius, 0.2*hole_radius))
        red -= 0.2
        green -= 0.2
        blue -= 0.2
    end

    hole_radius = moon_scale*0.2
    if in_blob(y, x, (moon_loc[1]-moon_scale*0.5,
                      moon_loc[2]-moon_scale*0.5),
               -3*pi/16, hole_radius, (2, 20, 3),
               (0.2*hole_radius, 0.05*hole_radius, 0.3*hole_radius))
        red -= 0.2
        green -= 0.2
        blue -= 0.2
    end

    hole_radius = moon_scale*0.15
    if in_blob(y, x, (moon_loc[1]-moon_scale*0.1,
                      moon_loc[2]-moon_scale*0.6),
               pi/8, hole_radius, (2, 20, 3),
               (0.2*hole_radius, 0.05*hole_radius, 0.3*hole_radius))
        red -= 0.2
        green -= 0.2
        blue -= 0.2
    end


    return RGBA{Float32}(red, green, blue, 1.0)
end

night_sky = @fum color function night_sky(y, x, frame, color; horizon = 0.0,
                                          stars = true, seed = 1,
                                          moon = true, moon_scale = 0.075,
                                          moon_loc = (horizon-0.25, -0.5),
                                          moon_halo_scale = moon_scale*1.5)
    if y <= horizon
        red = 0.3*exp((y-horizon)*5)
        green = 0.3*exp((y-horizon)*5)
        blue = exp((y-horizon)*4)

        if moon
            if moon_halo_scale > moon_scale
                if in_ellipse(y, x, moon_loc, 0,
                              moon_halo_scale, moon_halo_scale) &&
                   !in_ellipse(y, x, moon_loc, 0, moon_scale, moon_scale)
                    r = sqrt((x-moon_loc[2])^2 + (y-moon_loc[1])^2)
                    red += 10*(moon_halo_scale - r)
                    green += 10*(moon_halo_scale - r)
                    blue += 10*(moon_halo_scale - r)

                    red = min(1, red)
                    green = min(1, green)
                    blue = min(1, blue)
                end
            end
            if in_ellipse(y, x, moon_loc, 0, moon_scale, moon_scale)
                return moon_texture(y, x, moon_loc, moon_scale)
            end
        end

        if stars
            return star_texture(y, x, red, green, blue, seed)
        end

        return RGBA{Float32}(red, green, blue, 1.0)
    else
        return RGBA{Float32}(color.r, color.g, color.b, color.alpha)
    end
end
