import { test } from "node:test";
import assert from "node:assert/strict";
import { createRequire } from "node:module";

const require = createRequire(import.meta.url);
const E = require("../engine.js");

const { BLACK, WHITE, WIN_LEN, createGame, place, undo, findWinFrom,
  stonesForTurn, playerForTurn, currentPlayer, stonesLeft,
  lastTurnMoves, columnLabel, moveLabel } = E;

function placeAll(state, moves) {
  const results = [];
  for (const [c, r] of moves) results.push(place(state, c, r));
  return results;
}

test("createGame produces an empty board of the requested size", () => {
  const g = createGame(13);
  assert.equal(g.size, 13);
  assert.equal(g.board.length, 13);
  assert.equal(g.board[0].length, 13);
  assert.ok(g.board.every((row) => row.every((v) => v === 0)));
  assert.equal(g.turnIndex, 0);
  assert.equal(g.stonesPlacedThisTurn, 0);
  assert.equal(g.winner, 0);
  assert.equal(g.history.length, 0);
});

test("createGame rejects boards smaller than the win length", () => {
  assert.throws(() => createGame(5), />= 6/);
  assert.throws(() => createGame(0), />= 6/);
  assert.throws(() => createGame(3.5), /integer/);
});

test("stonesForTurn: 1 on first turn, 2 thereafter", () => {
  assert.equal(stonesForTurn(0), 1);
  assert.equal(stonesForTurn(1), 2);
  assert.equal(stonesForTurn(2), 2);
  assert.equal(stonesForTurn(99), 2);
});

test("playerForTurn alternates Black, White, Black, ...", () => {
  assert.equal(playerForTurn(0), BLACK);
  assert.equal(playerForTurn(1), WHITE);
  assert.equal(playerForTurn(2), BLACK);
  assert.equal(playerForTurn(3), WHITE);
});

test("Black opens with exactly one stone, then White places two", () => {
  const g = createGame(19);
  assert.equal(currentPlayer(g), BLACK);
  assert.equal(stonesLeft(g), 1);

  assert.deepEqual(place(g, 9, 9), { ok: true });
  assert.equal(g.turnIndex, 1, "turn advances after black's single stone");
  assert.equal(currentPlayer(g), WHITE);
  assert.equal(stonesLeft(g), 2);

  assert.deepEqual(place(g, 8, 9), { ok: true });
  assert.equal(g.turnIndex, 1, "still white's turn after one of two stones");
  assert.equal(stonesLeft(g), 1);

  assert.deepEqual(place(g, 10, 9), { ok: true });
  assert.equal(g.turnIndex, 2, "turn advances after white's second stone");
  assert.equal(currentPlayer(g), BLACK);
  assert.equal(stonesLeft(g), 2);
});

test("place rejects out-of-bounds and occupied intersections", () => {
  const g = createGame(13);
  assert.deepEqual(place(g, -1, 0), { ok: false, reason: "out-of-bounds" });
  assert.deepEqual(place(g, 0, 13), { ok: false, reason: "out-of-bounds" });
  assert.deepEqual(place(g, 100, 100), { ok: false, reason: "out-of-bounds" });

  place(g, 5, 5);
  assert.deepEqual(place(g, 5, 5), { ok: false, reason: "occupied" });
});

test("findWinFrom detects 6-in-a-row horizontally", () => {
  const g = createGame(19);
  for (let i = 0; i < 6; i++) g.board[5][3 + i] = BLACK;
  const line = findWinFrom(g, 5, 5, BLACK);
  assert.ok(line, "expected a win");
  assert.equal(line.length, 6);
  assert.deepEqual(line[0], { c: 3, r: 5 });
  assert.deepEqual(line[5], { c: 8, r: 5 });
});

test("findWinFrom detects 6-in-a-row vertically", () => {
  const g = createGame(19);
  for (let i = 0; i < 6; i++) g.board[2 + i][7] = WHITE;
  const line = findWinFrom(g, 7, 4, WHITE);
  assert.ok(line);
  assert.equal(line.length, 6);
});

test("findWinFrom detects both diagonals", () => {
  const downRight = createGame(19);
  for (let i = 0; i < 6; i++) downRight.board[2 + i][2 + i] = BLACK;
  assert.ok(findWinFrom(downRight, 4, 4, BLACK));

  const downLeft = createGame(19);
  for (let i = 0; i < 6; i++) downLeft.board[2 + i][10 - i] = WHITE;
  assert.ok(findWinFrom(downLeft, 8, 4, WHITE));
});

test("five in a row is not a win, seven in a row is", () => {
  const five = createGame(19);
  for (let i = 0; i < 5; i++) five.board[8][3 + i] = BLACK;
  assert.equal(findWinFrom(five, 5, 8, BLACK), null);

  const seven = createGame(19);
  for (let i = 0; i < 7; i++) seven.board[8][3 + i] = BLACK;
  const line = findWinFrom(seven, 5, 8, BLACK);
  assert.ok(line);
  assert.ok(line.length >= WIN_LEN);
});

test("placing the winning stone sets winner and winLine and stops further moves", () => {
  const g = createGame(19);
  // Reach a position where Black is about to win with their 6th-in-a-row.
  // Manually arrange to avoid simulating full Connect6 opening.
  g.turnIndex = 4;
  g.stonesPlacedThisTurn = 0;
  for (let i = 0; i < 5; i++) g.board[10][3 + i] = BLACK;

  const res = place(g, 8, 10);
  assert.equal(res.ok, true);
  assert.equal(res.winner, BLACK);
  assert.ok(Array.isArray(res.winLine));
  assert.equal(res.winLine.length, 6);
  assert.equal(g.winner, BLACK);

  // Subsequent placements are rejected.
  const after = place(g, 0, 0);
  assert.deepEqual(after, { ok: false, reason: "game-over" });
});

test("undo reverses one stone and clears a win", () => {
  const g = createGame(19);
  g.turnIndex = 4;
  for (let i = 0; i < 5; i++) g.board[10][3 + i] = BLACK;
  place(g, 8, 10);
  assert.equal(g.winner, BLACK);

  const ok = undo(g);
  assert.equal(ok, true);
  assert.equal(g.winner, 0);
  assert.equal(g.winLine, null);
  assert.equal(g.board[10][8], 0);
  // Stones placed this turn restored to 0 (start of that turn).
  assert.equal(g.stonesPlacedThisTurn, 0);
  assert.equal(g.turnIndex, 4);
});

test("undo on empty history is a no-op", () => {
  const g = createGame(19);
  assert.equal(undo(g), false);
});

test("undo across turn boundaries restores stonesPlacedThisTurn correctly", () => {
  const g = createGame(19);
  place(g, 9, 9); // Black's only opening stone, turn -> 1
  place(g, 0, 0); // White stone 1 of 2, still turn 1
  assert.equal(g.turnIndex, 1);
  assert.equal(g.stonesPlacedThisTurn, 1);

  undo(g); // undo white's stone -> turn 1, 0 placed
  assert.equal(g.turnIndex, 1);
  assert.equal(g.stonesPlacedThisTurn, 0);

  undo(g); // undo black's opener -> turn 0, 0 placed
  assert.equal(g.turnIndex, 0);
  assert.equal(g.stonesPlacedThisTurn, 0);
  assert.equal(g.history.length, 0);
});

test("lastTurnMoves returns current partial turn while in progress, else the previous full turn", () => {
  const g = createGame(19);
  assert.deepEqual(lastTurnMoves(g), []);

  place(g, 9, 9); // Black opener; turn advances to 1
  // No stones placed yet on turn 1 -> previous turn moves returned.
  assert.deepEqual(
    lastTurnMoves(g).map((m) => [m.c, m.r]),
    [[9, 9]],
  );

  place(g, 0, 0); // White stone 1 of 2
  assert.deepEqual(
    lastTurnMoves(g).map((m) => [m.c, m.r]),
    [[0, 0]],
  );

  place(g, 1, 0); // White stone 2 of 2 completes turn
  assert.deepEqual(
    lastTurnMoves(g).map((m) => [m.c, m.r]),
    [[0, 0], [1, 0]],
  );
});

test("columnLabel skips letter I (Go convention)", () => {
  assert.equal(columnLabel(0), "A");
  assert.equal(columnLabel(7), "H");
  assert.equal(columnLabel(8), "J");
  assert.equal(columnLabel(9), "K");
});

test("moveLabel uses 1-indexed rows from the bottom", () => {
  const g = createGame(19);
  assert.equal(moveLabel(g, 0, 18), "A1");
  assert.equal(moveLabel(g, 0, 0), "A19");
  assert.equal(moveLabel(g, 9, 9), "K10");
});

test("a full mini-game on a 6x6 board produces a Black win", () => {
  // Black plays a 6-in-a-row across row 2; White plays scattered non-line
  // stones so no accidental win lurks for White.
  const g = createGame(6);
  // Turn 0: Black places 1
  assert.equal(place(g, 0, 2).ok, true);
  // Turn 1: White places 2 (scattered)
  assert.equal(place(g, 0, 5).ok, true);
  assert.equal(place(g, 5, 0).ok, true);
  // Turn 2: Black places 2 in the row
  assert.equal(place(g, 1, 2).ok, true);
  assert.equal(place(g, 2, 2).ok, true);
  // Turn 3: White places 2 (scattered)
  assert.equal(place(g, 5, 3).ok, true);
  assert.equal(place(g, 0, 3).ok, true);
  // Turn 4: Black places 2 more in the row -> 5 in a row, no win yet
  assert.equal(place(g, 3, 2).ok, true);
  const res = place(g, 4, 2);
  assert.equal(res.ok, true);
  assert.equal(g.winner, 0, "five in a row should not win");
  // Turn 5: White (scattered)
  assert.equal(place(g, 3, 0).ok, true);
  assert.equal(place(g, 3, 3).ok, true);
  // Sanity: White still hasn't won.
  assert.equal(g.winner, 0);
  // Turn 6: Black places the 6th in the row
  const winRes = place(g, 5, 2);
  assert.equal(winRes.ok, true);
  assert.equal(winRes.winner, BLACK);
  assert.equal(g.winner, BLACK);
  assert.equal(winRes.winLine.length, 6);
});

test("engine state is independent across createGame calls", () => {
  const a = createGame(13);
  const b = createGame(13);
  place(a, 0, 0);
  assert.equal(b.board[0][0], 0, "second game should not see first game's stone");
  assert.equal(b.history.length, 0);
});
