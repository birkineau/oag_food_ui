This application shows an example Food Application that would recommend three
dishes at a time in a list-like layout, or a multitude of dishes in a bubble
layout.

## Features

A pleasing user UI/UX mock-up with two different layouts:

1. A list-like like layout with staggered animations.
2. A custom layout with randomly generated bubbles; the bubble placement is
random and generated on demand, and adapts to any device frame.

## Usage

There is one single screen that showcases both UI layouts.

Initially, the list-like layout is shown, and the animation can be played by
tapping on the "Chow Picks" button.

You can switch to the bubble layout by tapping on the right-adjacent button with
the bubbles. Tapping on it again will generate a new set of bubbles.

In a real application, both layouts would fetch data from the server and simply
display the results. For example, an AI-assisted recommendation system would
return interesting recipes/dishes for the user.

## Additional information

The bubble layout algorithm is not optimized, but this is not critical because
in a real application it could simply be run N times to generate N unique
layouts which could be cached in a file, DB, or local device DB.
