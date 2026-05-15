(() => {
  "use strict";

  const BLACK = 1;
  const WHITE = 2;
  const WIN_LEN = 6;
  const DIRECTIONS = [
    [1, 0],
    [0, 1],
    [1, 1],
    [1, -1],
  ];

  const canvas = document.getElementById("board");
  const ctx = canvas.getContext("2d");
  const turnText = document.getElementById("turn-text");
  const turnDot = document.getElementById("turn-dot");
  const moveNumEl = document.getElementById("move-num");
  const stonesLeftEl = document.getElementById("stones-left");
  const undoBtn = document.getElementById("undo-btn");
  const restartBtn = document.getElementById("restart-btn");
  const sizeSelect = document.getElementById("size-select");
  const coordToggle = document.getElementById("coord-toggle");
  const lastToggle = document.getElementById("last-toggle");
  const historyEl = document.getElementById("history");
  const banner = document.getElementById("banner");

  const state = {
    size: 19,
    board: [],
    history: [],
    turnIndex: 0,
    stonesPlacedThisTurn: 0,
    winner: 0,
    winLine: null,
  };

  function stonesForTurn(turnIndex) {
    return turnIndex === 0 ? 1 : 2;
  }

  function playerForTurn(turnIndex) {
    return turnIndex % 2 === 0 ? BLACK : WHITE;
  }

  function playerName(p) {
    return p === BLACK ? "Black" : "White";
  }

  function columnLabel(c) {
    const skipI = c >= 8 ? c + 1 : c;
    return String.fromCharCode("A".charCodeAt(0) + skipI);
  }

  function moveLabel(c, r) {
    return `${columnLabel(c)}${state.size - r}`;
  }

  function resetGame(size) {
    state.size = size;
    state.board = Array.from({ length: size }, () => new Array(size).fill(0));
    state.history = [];
    state.turnIndex = 0;
    state.stonesPlacedThisTurn = 0;
    state.winner = 0;
    state.winLine = null;
    banner.hidden = true;
    renderAll();
  }

  function currentPlayer() {
    return playerForTurn(state.turnIndex);
  }

  function stonesLeftThisTurn() {
    return stonesForTurn(state.turnIndex) - state.stonesPlacedThisTurn;
  }

  function inBounds(c, r) {
    return c >= 0 && r >= 0 && c < state.size && r < state.size;
  }

  function place(c, r) {
    if (state.winner || !inBounds(c, r)) return;
    if (state.board[r][c] !== 0) return;

    const player = currentPlayer();
    state.board[r][c] = player;
    state.history.push({ c, r, player, turnIndex: state.turnIndex });
    state.stonesPlacedThisTurn += 1;

    const win = findWinFrom(c, r, player);
    if (win) {
      state.winner = player;
      state.winLine = win;
      renderAll();
      showBanner(`${playerName(player)} wins!`);
      return;
    }

    if (state.stonesPlacedThisTurn >= stonesForTurn(state.turnIndex)) {
      state.turnIndex += 1;
      state.stonesPlacedThisTurn = 0;
    }
    renderAll();
  }

  function undo() {
    if (state.history.length === 0) return;
    const last = state.history.pop();
    state.board[last.r][last.c] = 0;
    state.turnIndex = last.turnIndex;
    state.stonesPlacedThisTurn = state.history.filter(
      (m) => m.turnIndex === state.turnIndex,
    ).length;
    state.winner = 0;
    state.winLine = null;
    banner.hidden = true;
    renderAll();
  }

  function findWinFrom(c, r, player) {
    for (const [dc, dr] of DIRECTIONS) {
      const line = [{ c, r }];
      let cc = c + dc;
      let rr = r + dr;
      while (inBounds(cc, rr) && state.board[rr][cc] === player) {
        line.push({ c: cc, r: rr });
        cc += dc;
        rr += dr;
      }
      cc = c - dc;
      rr = r - dr;
      while (inBounds(cc, rr) && state.board[rr][cc] === player) {
        line.unshift({ c: cc, r: rr });
        cc -= dc;
        rr -= dr;
      }
      if (line.length >= WIN_LEN) return line;
    }
    return null;
  }

  function showBanner(text) {
    banner.textContent = text;
    banner.hidden = false;
  }

  function geometry() {
    const size = canvas.width;
    const margin = Math.round(size * 0.045);
    const inner = size - margin * 2;
    const step = inner / (state.size - 1);
    return { size, margin, step };
  }

  function pixelToCell(px, py) {
    const rect = canvas.getBoundingClientRect();
    const scale = canvas.width / rect.width;
    const x = (px - rect.left) * scale;
    const y = (py - rect.top) * scale;
    const { margin, step } = geometry();
    const c = Math.round((x - margin) / step);
    const r = Math.round((y - margin) / step);
    if (!inBounds(c, r)) return null;
    const cx = margin + c * step;
    const cy = margin + r * step;
    if (Math.hypot(x - cx, y - cy) > step * 0.5) return null;
    return { c, r };
  }

  function starPoints() {
    if (state.size === 19) {
      return [3, 9, 15].flatMap((r) => [3, 9, 15].map((c) => [c, r]));
    }
    if (state.size === 15) {
      return [3, 7, 11].flatMap((r) => [3, 7, 11].map((c) => [c, r]));
    }
    if (state.size === 13) {
      const m = 6;
      return [
        [3, 3],
        [9, 3],
        [3, 9],
        [9, 9],
        [m, m],
      ];
    }
    return [];
  }

  function drawBoard() {
    const { size, margin, step } = geometry();
    ctx.clearRect(0, 0, size, size);

    ctx.fillStyle = getCss("--board");
    ctx.fillRect(0, 0, size, size);

    ctx.strokeStyle = getCss("--board-line");
    ctx.lineWidth = 1.2;
    for (let i = 0; i < state.size; i++) {
      const p = margin + i * step;
      ctx.beginPath();
      ctx.moveTo(margin, p);
      ctx.lineTo(margin + (state.size - 1) * step, p);
      ctx.stroke();
      ctx.beginPath();
      ctx.moveTo(p, margin);
      ctx.lineTo(p, margin + (state.size - 1) * step);
      ctx.stroke();
    }

    ctx.fillStyle = getCss("--board-line");
    for (const [c, r] of starPoints()) {
      ctx.beginPath();
      ctx.arc(margin + c * step, margin + r * step, step * 0.09, 0, Math.PI * 2);
      ctx.fill();
    }

    if (coordToggle.checked) {
      ctx.fillStyle = "rgba(45, 33, 24, 0.7)";
      ctx.font = `${Math.round(step * 0.32)}px ui-monospace, monospace`;
      ctx.textAlign = "center";
      ctx.textBaseline = "middle";
      for (let i = 0; i < state.size; i++) {
        ctx.fillText(columnLabel(i), margin + i * step, margin * 0.45);
        ctx.fillText(
          columnLabel(i),
          margin + i * step,
          margin + (state.size - 1) * step + margin * 0.55,
        );
        const rowLabel = String(state.size - i);
        ctx.fillText(rowLabel, margin * 0.45, margin + i * step);
        ctx.fillText(
          rowLabel,
          margin + (state.size - 1) * step + margin * 0.55,
          margin + i * step,
        );
      }
    }
  }

  function drawStone(c, r, player, opts = {}) {
    const { margin, step } = geometry();
    const x = margin + c * step;
    const y = margin + r * step;
    const radius = step * 0.45;

    ctx.beginPath();
    ctx.arc(x, y + radius * 0.08, radius, 0, Math.PI * 2);
    ctx.fillStyle = "rgba(0,0,0,0.28)";
    ctx.fill();

    const grad = ctx.createRadialGradient(
      x - radius * 0.35,
      y - radius * 0.4,
      radius * 0.1,
      x,
      y,
      radius,
    );
    if (player === BLACK) {
      grad.addColorStop(0, "#5a606b");
      grad.addColorStop(1, getCss("--black-stone"));
    } else {
      grad.addColorStop(0, "#ffffff");
      grad.addColorStop(1, "#c8ccd2");
    }
    ctx.beginPath();
    ctx.arc(x, y, radius, 0, Math.PI * 2);
    ctx.fillStyle = grad;
    ctx.fill();

    if (opts.highlightLast) {
      ctx.strokeStyle = getCss("--last");
      ctx.lineWidth = Math.max(2, step * 0.07);
      ctx.beginPath();
      ctx.arc(x, y, radius * 0.45, 0, Math.PI * 2);
      ctx.stroke();
    }
    if (opts.highlightWin) {
      ctx.strokeStyle = getCss("--win");
      ctx.lineWidth = Math.max(2, step * 0.08);
      ctx.beginPath();
      ctx.arc(x, y, radius + step * 0.05, 0, Math.PI * 2);
      ctx.stroke();
    }
  }

  function drawStones() {
    const lastMoves = lastTurnMoves();
    const winSet = new Set(
      (state.winLine || []).map(({ c, r }) => `${c},${r}`),
    );
    for (let r = 0; r < state.size; r++) {
      for (let c = 0; c < state.size; c++) {
        const v = state.board[r][c];
        if (!v) continue;
        const isLast =
          lastToggle.checked &&
          !state.winner &&
          lastMoves.some((m) => m.c === c && m.r === r);
        const isWin = winSet.has(`${c},${r}`);
        drawStone(c, r, v, {
          highlightLast: isLast,
          highlightWin: isWin,
        });
      }
    }
  }

  function lastTurnMoves() {
    if (state.history.length === 0) return [];
    if (state.stonesPlacedThisTurn > 0) {
      return state.history.slice(-state.stonesPlacedThisTurn);
    }
    const prevTurn = state.history[state.history.length - 1].turnIndex;
    return state.history.filter((m) => m.turnIndex === prevTurn);
  }

  function renderStatus() {
    if (state.winner) {
      turnText.textContent = `${playerName(state.winner)} wins`;
      turnDot.classList.toggle("white", state.winner === WHITE);
      stonesLeftEl.textContent = "0";
    } else {
      const p = currentPlayer();
      const left = stonesLeftThisTurn();
      const count = stonesForTurn(state.turnIndex);
      const verb =
        state.stonesPlacedThisTurn === 0
          ? `to place ${count} stone${count > 1 ? "s" : ""}`
          : `placing stone ${state.stonesPlacedThisTurn + 1} of ${count}`;
      turnText.textContent = `${playerName(p)} ${verb}`;
      turnDot.classList.toggle("white", p === WHITE);
      stonesLeftEl.textContent = String(left);
    }
    moveNumEl.textContent = String(state.turnIndex + 1);
    undoBtn.disabled = state.history.length === 0;
  }

  function renderHistory() {
    historyEl.innerHTML = "";
    const byTurn = new Map();
    for (const m of state.history) {
      if (!byTurn.has(m.turnIndex)) byTurn.set(m.turnIndex, []);
      byTurn.get(m.turnIndex).push(m);
    }
    const turns = [...byTurn.keys()].sort((a, b) => a - b);
    for (const t of turns) {
      const moves = byTurn.get(t);
      const li = document.createElement("li");
      li.className = moves[0].player === BLACK ? "black" : "white";
      const label = moves[0].player === BLACK ? "B" : "W";
      li.textContent = `${label}: ${moves
        .map((m) => moveLabel(m.c, m.r))
        .join(", ")}`;
      historyEl.appendChild(li);
    }
    historyEl.scrollTop = historyEl.scrollHeight;
  }

  function renderAll() {
    drawBoard();
    drawStones();
    renderStatus();
    renderHistory();
  }

  function getCss(name) {
    return getComputedStyle(document.documentElement)
      .getPropertyValue(name)
      .trim();
  }

  canvas.addEventListener("click", (e) => {
    const cell = pixelToCell(e.clientX, e.clientY);
    if (!cell) return;
    place(cell.c, cell.r);
  });

  undoBtn.addEventListener("click", undo);
  restartBtn.addEventListener("click", () => {
    if (state.history.length === 0 || confirm("Restart the game?")) {
      resetGame(state.size);
    }
  });
  sizeSelect.addEventListener("change", () => {
    const next = parseInt(sizeSelect.value, 10);
    if (state.history.length > 0 && !confirm("Changing board size restarts the game. Continue?")) {
      sizeSelect.value = String(state.size);
      return;
    }
    resetGame(next);
  });
  coordToggle.addEventListener("change", renderAll);
  lastToggle.addEventListener("change", renderAll);

  document.addEventListener("keydown", (e) => {
    if (e.key === "z" && (e.ctrlKey || e.metaKey)) {
      e.preventDefault();
      undo();
    }
  });

  resetGame(state.size);
})();
