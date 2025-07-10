# General Overview

I will be adding much more here in the near future.
Right now, this page is largely meant as a sketch for what the documentation needs to cover in more depth.

## Installation

Quibble is built with CMake and requires OpenCL to be installed.
Once you are sure both packages are on your system, then building should be as simple as:

```
mkdir build/
cd build 
cmake ../.
make
```

This will also run the `./configure` script and place all the necessary configuration files and examples in `$XDG_CONFIG_HOME/.config/quibble/` (usually `/home/username/.config/quibble/`

## Uninstallation

To uninstall, run `make clean`.
To remove the configuration files, run the `clean` script in the root directory.

## Scribble overview

Quibble allows users to write scribbles that split up their OpenCL kernels into different compilation units:

1. `__verse`s: These are basic building blocks for quibble programs and can be used similarly to C functions.
2. `__stanza`s: These are composability rules for verses and allow users to define how verses are meant to be used in a larger unit.
3. `__poem`s: These are composability rules for both stanzas and verses and will be compiled into an OpenCL kernel.

### Example

Here is a quick example and the OpenCL kernel it compiles down to.

```
__verse mult_by(__global float *verse_a | float factor = 8;){
    verse_a[_idx] *= factor;
}

__stanza stanza_check(__global float *stanza_a,
                      __global float *stanza_b,
                      __global float *stanza_c | float r = 1.0;){
    if (_idx < array_size){
        stanza_c[_idx] = stanza_a[_idx] + stanza_b[_idx];
        __split_stanza();
        stanza_c[_idx] += 1; // checking comments
    } // checking comments
}

__poem poem_check(__global float *a,
                  __global float *b,
                  __global float *c,
                  int stanza_num, 
                  int array_size){
    if (stanza_num == 0){
        @SCALL stanza_check(a, b, c | r = 5;){
            @VCALL mult_by(c | factor = 2;);
        }
        if (_idx < array_size){
            @VCALL mult_by(c | factor = 0.5;);
        }
    }
}
```

Which compiles to...

```
__kernel void poem_check(__global float * a,
                         __global float * b,
                         __global float * c,
                         int stanza_num,
                         int array_size){
    int _idx = get_global_id(0);

    if (stanza_num == 0){
        {
            __global float *stanza_a = a;
            __global float *stanza_b = b;
            __global float *stanza_c = c;
            float r = 5;

            if (_idx < array_size){
                stanza_c[_idx] = stanza_a[_idx] + stanza_b[_idx];
        
                {
                    __global float *verse_a = c;
                    float factor = 2;

                    verse_a[_idx] *= factor;
                }

                stanza_c[_idx] += 1; // checking comments
            } // checking comments
        }

        if (_idx < array_size){
            {
                __global float *verse_a = c;
                float factor = 0.5;

                verse_a[_idx] *= factor;
            }
        }
    }
}

```

## Limitations

Because quibble scribbles are eventually compiled into OpenCL kernels, it is important to remember the limitations of computational kernels on the GPU.
For example:

1. No function pointers
2. No array allocation except on local (shared) memory

It is also important to note that [variable names should be unique between verses, stanzas, and poems](https://github.com/leios/quibble/issues/15).
In the long term, I am looking for a fix, but it is not my highest priority.

## Features

Because Quibble is a metaprogramming framework, there is a lot of flexibility to the overall language design -- especially because the code becomes one, large OpenCL kernel.
In particular, I can provide:
1. Keyword arguments for verses and stanzas
2. "Global" variables (such as `_idx`) that exist for all verses and stanzas being called by poems
