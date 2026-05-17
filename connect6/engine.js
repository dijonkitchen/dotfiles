// @ts-check
/**
 * Connect6 rules engine. Pure, framework-free, loadable in browsers (via
 * `window.Connect6Engine`) and Node (via `require`).
 *
 * @typedef {0 | 1 | 2} Cell           Board cell: 0 = empty, 1 = Black, 2 = White.
 * @typedef {1 | 2}     Player         A side that takes turns.
 * @typedef {0 | Player} Winner        0 means "no winner yet".
 *
 * @typedef {object} Point
 * @property {number} c                Column index (0-based, left to right).
 * @property {number} r                Row index    (0-based, top to bottom).
 *
 * @typedef {object} Move
 * @property {number} c
 * @property {number} r
 * @property {Player} player
 * @property {number} turnIndex        The turn this stone was placed on.
 *
 * @typedef {object} GameState
 * @property {number}      size
 * @property {Cell[][]}    board       board[r][c] is the stone at (c, r).
 * @property {Move[]}      history
 * @property {number}      turnIndex
 * @property {number}      stonesPlacedThisTurn
 * @property {Winner}      winner
 * @property {Point[]|null} winLine
 *
 * @typedef {'game-over' | 'out-of-bounds' | 'occupied'} PlaceFailure
 *
 * @typedef {{ ok: true, winner?: Player, winLine?: Point[] }
 *        | { ok: false, reason: PlaceFailure }} PlaceResult
 */

(function (root, factory) {
  if (typeof module === "object" && module.exports) {
    module.exports = factory();
  } else {
    /** @type {any} */ (root).Connect6Engine = factory();
  }
})(typeof self !== "undefined" ? self : this, function () {
  "use strict";

  const EMPTY = 0;
  const BLACK = 1;
  const WHITE = 2;
  const WIN_LEN = 6;
  /** @type {ReadonlyArray<[number, number]>} */
  const DIRECTIONS = [
    [1, 0],
    [0, 1],
    [1, 1],
    [1, -1],
  ];

  /**
   * @param {number} turnIndex
   * @returns {1 | 2}
   */
  function stonesForTurn(turnIndex) {
    return turnIndex === 0 ? 1 : 2;
  }

  /**
   * @param {number} turnIndex
   * @returns {Player}
   */
  function playerForTurn(turnIndex) {
    return turnIndex % 2 === 0 ? BLACK : WHITE;
  }

  /**
   * @param {number} [size]
   * @returns {GameState}
   */
  function createGame(size) {
    const n = size === undefined ? 19 : size;
    if (!Number.isInteger(n) || n < 6) {
      throw new Error("Board size must be an integer >= 6");
    }
    /** @type {Cell[][]} */
    const board = Array.from({ length: n }, () => new Array(n).fill(EMPTY));
    return {
      size: n,
      board,
      history: [],
      turnIndex: 0,
      stonesPlacedThisTurn: 0,
      winner: 0,
      winLine: null,
    };
  }

  /**
   * @param {GameState} state
   * @param {number} c
   * @param {number} r
   */
  function inBounds(state, c, r) {
    return c >= 0 && r >= 0 && c < state.size && r < state.size;
  }

  /**
   * @param {GameState} state
   * @returns {Player}
   */
  function currentPlayer(state) {
    return playerForTurn(state.turnIndex);
  }

  /** @param {GameState} state */
  function stonesLeft(state) {
    return stonesForTurn(state.turnIndex) - state.stonesPlacedThisTurn;
  }

  /**
   * Return the winning line through (c, r) for `player`, or null.
   *
   * @param {GameState} state
   * @param {number} c
   * @param {number} r
   * @param {Player} player
   * @returns {Point[] | null}
   */
  function findWinFrom(state, c, r, player) {
    for (const [dc, dr] of DIRECTIONS) {
      /** @type {Point[]} */
      const line = [{ c, r }];
      let cc = c + dc;
      let rr = r + dr;
      while (inBounds(state, cc, rr) && state.board[rr][cc] === player) {
        line.push({ c: cc, r: rr });
        cc += dc;
        rr += dr;
      }
      cc = c - dc;
      rr = r - dr;
      while (inBounds(state, cc, rr) && state.board[rr][cc] === player) {
        line.unshift({ c: cc, r: rr });
        cc -= dc;
        rr -= dr;
      }
      if (line.length >= WIN_LEN) return line;
    }
    return null;
  }

  /**
   * Place a stone for the current player at (c, r). Mutates `state`.
   *
   * @param {GameState} state
   * @param {number} c
   * @param {number} r
   * @returns {PlaceResult}
   */
  function place(state, c, r) {
    if (state.winner) {
      return { ok: false, reason: "game-over" };
    }
    if (!inBounds(state, c, r)) {
      return { ok: false, reason: "out-of-bounds" };
    }
    if (state.board[r][c] !== EMPTY) {
      return { ok: false, reason: "occupied" };
    }

    const player = currentPlayer(state);
    state.board[r][c] = player;
    state.history.push({ c, r, player, turnIndex: state.turnIndex });
    state.stonesPlacedThisTurn += 1;

    const winLine = findWinFrom(state, c, r, player);
    if (winLine) {
      state.winner = player;
      state.winLine = winLine;
      return { ok: true, winner: player, winLine };
    }

    if (state.stonesPlacedThisTurn >= stonesForTurn(state.turnIndex)) {
      state.turnIndex += 1;
      state.stonesPlacedThisTurn = 0;
    }
    return { ok: true };
  }

  /**
   * Undo the last stone. Clears a recorded win if the undone stone was the
   * winning one.
   *
   * @param {GameState} state
   * @returns {boolean} Whether anything was undone.
   */
  function undo(state) {
    if (state.history.length === 0) return false;
    const last = /** @type {Move} */ (state.history.pop());
    state.board[last.r][last.c] = EMPTY;
    state.turnIndex = last.turnIndex;
    state.stonesPlacedThisTurn = state.history.filter(
      (m) => m.turnIndex === state.turnIndex,
    ).length;
    state.winner = 0;
    state.winLine = null;
    return true;
  }

  /**
   * Stones the current player has placed this turn, OR — if the turn just
   * ended — the stones placed on the previous turn. Useful for "last move"
   * highlighting.
   *
   * @param {GameState} state
   * @returns {Move[]}
   */
  function lastTurnMoves(state) {
    if (state.history.length === 0) return [];
    if (state.stonesPlacedThisTurn > 0) {
      return state.history.slice(-state.stonesPlacedThisTurn);
    }
    const prevTurn = state.history[state.history.length - 1].turnIndex;
    return state.history.filter((m) => m.turnIndex === prevTurn);
  }

  /**
   * Go-style column letter: A..H, J..T (skips I).
   *
   * @param {number} c
   * @returns {string}
   */
  function columnLabel(c) {
    const shifted = c >= 8 ? c + 1 : c;
    return String.fromCharCode("A".charCodeAt(0) + shifted);
  }

  /**
   * @param {GameState} state
   * @param {number} c
   * @param {number} r
   * @returns {string}
   */
  function moveLabel(state, c, r) {
    return `${columnLabel(c)}${state.size - r}`;
  }

  return {
    EMPTY,
    BLACK,
    WHITE,
    WIN_LEN,
    DIRECTIONS,
    createGame,
    place,
    undo,
    findWinFrom,
    inBounds,
    currentPlayer,
    stonesLeft,
    stonesForTurn,
    playerForTurn,
    lastTurnMoves,
    columnLabel,
    moveLabel,
  };
});
