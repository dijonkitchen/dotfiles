# Connect6

A static, two-player Connect6 game that runs entirely in the browser. No
build step, no dependencies — open `index.html` and play.

## How to run

Open `connect6/index.html` in a browser. No build step, no server required.

## Rules implemented

- **Opening:** Black places one stone on the first turn.
- **Subsequent turns:** each player places two stones per turn, alternating.
- **Win:** first to align six or more stones in a row, column, or diagonal.
- Stones cannot be placed on occupied intersections.

## Features

- 13×13, 15×15, or 19×19 board (standard Connect6 is 19×19).
- Click an intersection to place a stone.
- "Last move" markers show the stones placed in the current/most-recent turn.
- Win line is highlighted when the game ends.
- Undo move (also `Ctrl/Cmd+Z`) and Restart.
- Move history with standard column-letter / row-number coordinates
  (column `I` is skipped, Go-style).
- Toggleable board coordinates and last-move highlight.

## Tests

The pure rules live in `engine.js` and are exercised by `tests/engine.test.mjs`
using Node's built-in test runner (no dependencies). Run from the repo root:

```sh
make test-connect6
# or directly:
node --test 'connect6/tests/*.test.mjs'
```

## Type-checking

`engine.js` is annotated with `// @ts-check` and JSDoc `@typedef`s
(`Cell`, `Player`, `Move`, `GameState`, `PlaceResult`, ...). Editors with
TypeScript support get autocomplete and inline errors for free; CI can run:

```sh
make typecheck-connect6
```

This invokes `tsc` via `npx` — no `package.json` or local install required,
and the shipped site is still plain JavaScript with zero dependencies.

Tests cover: turn progression (Black opens with 1, then 2 per turn),
out-of-bounds and occupied-cell rejection, win detection across all four
directions, the 5-not-6 negative case, post-win move rejection, undo across
turn boundaries, the column-`I`-skipping coordinate labels, and a full
deterministic mini-game on a 6×6 board.

## Files

- `index.html` — markup and layout
- `styles.css` — dark theme, responsive layout
- `engine.js` — pure rules (UMD-loadable in browser and Node)
- `game.js` — UI layer: canvas rendering, event handlers, status panel
- `tests/engine.test.mjs` — unit tests for the rules engine
