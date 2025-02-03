# Rope Face

A SwiftUI pet project inspired by an intriguing art object found on [Instagram](https://www.instagram.com/reel/DFRQRbVuShR/?utm_source=ig_web_copy_link&igsh=MzRlODBiNWFlZA==): a small portrait of a lady where the face is replaced with a free-moving rope fixed at its edges. Shaking the portrait changes the face dynamically, making each interaction unique.

## Inspiration 

I was captivated by this artwork and decided to create a digital version. My goal was to simulate the behavior of the rope and allow users to interact with it by shaking their devices.

![instagram](https://github.com/user-attachments/assets/cf9273b1-8e35-4611-9182-c428ce006544)


## Features & Technical Details

- Rope Simulation: The rope movement is imitated using a **7th-order Bezier curve**.
- Device Motion Detection: Utilizes `CMMotionManager` to detect user shakes.
- Dynamic Rope Behavior: When the user shakes the device hard enough, the direction is detected, and control **points are adjusted accordingly to the left or right**.
- Length Preservation: Keeping the **rope length constant** is maintained using numeric equations. *Not sure if the work correctly - I asked ChatGPT help me there. But it looks like plausible.*

## Credits

A big thank you to [simeonfik](https://www.instagram.com/simeonfik/) for the inspiration behind this project!
