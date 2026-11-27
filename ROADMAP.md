# Roadmap

## Next

- **Campaign scripting**: script the next missions on from
  `replays/field_training_m2.txt`.
- **Frame timing**: the recompiler times code similarly to mGBA (`gbarecomp`
  #21, #22, #25). Boot matches mGBA to the frame and Mission 1 stays within
  4 frames, but execution isn't cycle-exact yet: by the end of Mission 2 the
  build is about 16 frames ahead due to approximate waitstates/prefetch/DMA
  stalls.
- **CI**: build and run unit/wasm/headless checks on push; conformance
  reports SKIP there (no ROM).
- **RAM overlays in the recompiler (optional)**: retire the remaining
  runtime-interpreted RAM entries cleanly.

## Deferred

- Save states.
- Advance Wars 2: Black Hole Rising.

## Out of scope

- Distributing the ROM, generated source, or builds made from them.
