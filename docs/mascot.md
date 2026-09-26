# Fini poses

The pose PNGs in `assets/mascot/` are drawn from `assets/logo/safini-mascot.png` (the brand art, `FiniPose.phone`) with the Codex desktop app's
image generation, one run per pose:

    codex exec --skip-git-repo-check -s workspace-write -i safini-mascot.png - < prompt.txt

Then cropped to the character, scaled to 600px on the long side, and quantized to 256 colours
(21-29 KB each instead of ~250 KB). Keep new poses the same way so they sit at the same scale.

Shared prompt, with POSE replaced:

> The attached image is Fini, the Safini app mascot: a cute penguin with a dark pine-green baseball cap
> worn backwards, round yellow glasses, orange beak and feet, very dark green-black body, cream-white
> belly, flat vector cartoon style with soft shading and a thin dark outline. Draw the SAME character in
> the SAME art style, proportions and exact colors, in a new pose: POSE No text, no sticker border, no
> white outline, no background: fully transparent background PNG, square 1024x1024, full body,
> character centered with a little padding.

| File | Pose | Used for |
| --- | --- | --- |
| fini-wave.png | waving hello with the right flipper raised high, big friendly open-beak smile | kid hello, no-child Today |
| fini-cheer.png | jumping with joy, both flippers raised high above the head, eyes happily closed in upward arcs, huge open-beak smile, feet off the ground, a few small gold sparkles around (sparkles only, no confetti). | 5 of 5, phone connected, kid setup done |
| fini-point.png | standing turned three-quarters to the viewer's right, pointing with the left flipper toward the right edge of the image as if presenting something, friendly smile, the other flipper on the hip. | Fini's bubble (points at it) |
| fini-oops.png | oops / slightly worried: one flipper scratching the back of the head under the cap, an awkward apologetic smile with a single small blue sweat drop near the cap, eyebrows raised. | errors, battery tips |
| fini-wait.png | patiently waiting: holding a dark green smartphone in both flippers and looking at its screen, the screen shows three small white loading dots, a calm curious expression. | waiting for the kid's phone |
