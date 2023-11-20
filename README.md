# rom-stoppable

Custom ROM for PSX PIO. Can't do anything special yet. I'm just trying to get
comfortable with the PSX.

![Screenshot of rendered rectangles in emulator](Screenshot%202023-11-15%20at%2016.29.58.png)

## Build

Build executable.

```sh
cd template
cmake --preset default .
cmake --build ./build
```

Build loader.

```sh
armips rom.s
```
