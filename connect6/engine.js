(function (root, factory) {
  if (typeof module === "object" && module.exports) {
    module.exports = factory();
  } else {
    root.Connect6Engine = factory();
  }
})(typeof self !== "undefined" ? self : this, function () {
  "use strict";

  const EMPTY = 0;
  const BLACK = 1;
  const WHITE = 2;
  const WIN_LEN = 6;
  const DIRECTIONS = [
    [1, 0],
    [0, 1],
    [1, 1],
    [1, -1],
  ];

  function stonesForTurn(turnIndex) {
    return turnIndex === 0 ? 1 : 2;
  }

  function playerForTurn(turnIndex) {
    return turnIndex % 2 === 0 ? BLACK : WHITE;
  }

  function createGame(size) {
    const n = size === undefined ? 19 : size;
    if (!Number.isInteger(n) || n < 6) {
      throw new Error("Board size must be an integer >= 6");
    }
    return {
      size: n,
      board: Array.from({ length: n }, () => new Array(n).fill(EMPTY)),
      history: [],
      turnIndex: 0,
      stonesPlacedThisTurn: 0,
      winner: 0,
      winLine: null,
    };
  }

  function inBounds(state, c, r) {
    return c >= 0 && r >= 0 && c < state.size && r < state.size;
  }

  function currentPlayer(state) {
    return playerForTurn(state.turnIndex);
  }

  function stonesLeft(state) {
    return stonesForTurn(state.turnIndex) - state.stonesPlacedThisTurn;
  }

  function findWinFrom(state, c, r, player) {
    for (const [dc, dr] of DIRECTIONS) {
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

  function undo(state) {
    if (state.history.length === 0) return false;
    const last = state.history.pop();
    state.board[last.r][last.c] = EMPTY;
    state.turnIndex = last.turnIndex;
    state.stonesPlacedThisTurn = state.history.filter(
      (m) => m.turnIndex === state.turnIndex,
    ).length;
    state.winner = 0;
    state.winLine = null;
    return true;
  }

  function lastTurnMoves(state) {
    if (state.history.length === 0) return [];
    if (state.stonesPlacedThisTurn > 0) {
      return state.history.slice(-state.stonesPlacedThisTurn);
    }
    const prevTurn = state.history[state.history.length - 1].turnIndex;
    return state.history.filter((m) => m.turnIndex === prevTurn);
  }

  function columnLabel(c) {
    const shifted = c >= 8 ? c + 1 : c;
    return String.fromCharCode("A".charCodeAt(0) + shifted);
  }

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
