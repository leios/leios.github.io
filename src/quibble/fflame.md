# Fractal Flames

Quibble is a metaprogramming framework to allow for the straightforward composition of various function systems.
In many ways, the fractal flame algorithm is similar in that it allows users to inject various functions into pre-existing iterated function systems.
Though quibble is primarily meant for general-purpose graphical workflows, it can also easily create fractal flames.
In fact, I had originally envisioned quibble to be based on fractal flames.

For these reasons, it's relevant to create a quick example showing how this might be done.

## The Basics

As mentioned above, the fractal flame method is actually quite straightforward.
Just pick an IFS of your choice and solve it by the chaos game.
Then, before looping back and choosing a function for the next step, you instead pick a function from another IFS.
That's it.
The trick(s) come later.

Namely, How do you make something that actually looks visually interesting?

Well, this is done in a number of different ways.
The paper outlines
