# General Overview

I will be adding much more here in the near future.
As it stands, this page is largely meant as a sketch for what the documentation needs to cover in the future.

Quibble allows users to split up their OpenCL kernels into different compilation units:

1. `__verse`s: These are basic building blocks for quibble programs and can be used similarly to C functions.
2. `__stanza`s: These are composability rules for verses and allow users to define how verses are meant to be used in a larger unit.
3. `__poem`s: These are composability rules for both stanzas and verses and will be compiled into an OpenCL kernel.

## Example

Here is a quick example and the OpenCL kernel it compiles down to.

```
__verse mult_by(float *a | float factor = 8;){
    a[_idx] *= factor;
}

__stanza stanza_check(afloat *, bfloat *, cfloat * | float r = 1.0;){
    c[_idx] = a[_idx] + b[_idx];
    __split_stanza();
    c[idx] += 1;
}

__poem poem_check(float *a, float *b, float *c, stanza_num){
    if (stanza_num == 0){
        @SCALL stanza_check(a, b, c){
            @VCALL mult_by(c | factor = 2;);
        }
    }
}
```

Which compiles to...

```
__kernel void poem_check(float *a, float *b, float *c, stanza_num){
    int _idx = get_global_id(0);

    if (stanza_num == 0){
        {
            float *a = a;
            float *b = b;
            float *c = c;
            float r = 1.0;

            c[_idx] = a[_idx] + b[_idx];
            {
                float *a = c;
                float factor = 8;

                a[_idx] *= factor;
            }
            c[idx] += 1;
        }

    }

}
```

## Limitations

Because quibble scribbles are eventually compiled into OpenCL kernels, it is important to keep in mind several limitations to computational kernels on the GPU.
For example:

1. No function pointers
2. No array allocation except on local (shared) memory

## TODO

Add specifics for verses, stanzas, and poems -- in particular, note stanza splitting

