---
Authors : Albanesi Nicolas, Kandiah Abivarman, Stirnemann Jonas
Date : 22/02/2024
Name: Quickscope
---

# Oscilloscope on FPGA

## Internal diagram

![internal_diagram](docs/internal_diagram.png)

## Demo
![Demo gif](docs/demo_small.webp)


## Repository organisation 

- `build` : Built elf, bitstream and xsa
- `docs` : Documentation

- `src.bd` : Block diagrams
- `src.constraints` : Constraint files
- `src.cpu` : The C code that goes on the Softcore CPU
- `src.framebuffer` : Individual framebuffer code
- `src.rotary_encoder` : Individual rotary_encoder code
- `src.video_generator` : Individual video_generator code


[FULL VIDEO DEMO](docs/IMG_0708.mov)
