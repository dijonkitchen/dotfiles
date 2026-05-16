(() => {
  "use strict";

  const E = window.Connect6Engine;
  const { BLACK, WHITE, createGame, place, undo, columnLabel, moveLabel,
    stonesForTurn, currentPlayer, stonesLeft, lastTurnMoves } = E;

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

  let state = createGame(19);

  function playerName(p) {
    return p === BLACK ? "Black" : "White";
  }

  function resetGame(size) {
    state = createGame(size);
    banner.hidden = true;
    renderAll();
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
    if (c < 0 || r < 0 || c >= state.size || r >= state.size) return null;
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
      return [
        [3, 3],
        [9, 3],
        [3, 9],
        [9, 9],
        [6, 6],
      ];
    }
    return [];
  }

  function getCss(name) {
    return getComputedStyle(document.documentElement)
      .getPropertyValue(name)
      .trim();
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
    const lastMoves = lastTurnMoves(state);
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

  function renderStatus() {
    if (state.winner) {
      turnText.textContent = `${playerName(state.winner)} wins`;
      turnDot.classList.toggle("white", state.winner === WHITE);
      stonesLeftEl.textContent = "0";
    } else {
      const p = currentPlayer(state);
      const left = stonesLeft(state);
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
        .map((m) => moveLabel(state, m.c, m.r))
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

  canvas.addEventListener("click", (e) => {
    const cell = pixelToCell(e.clientX, e.clientY);
    if (!cell) return;
    const res = place(state, cell.c, cell.r);
    if (!res.ok) return;
    if (res.winner) {
      banner.textContent = `${playerName(res.winner)} wins!`;
      banner.hidden = false;
    }
    renderAll();
  });

  undoBtn.addEventListener("click", () => {
    if (undo(state)) {
      banner.hidden = true;
      renderAll();
    }
  });
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
      if (undo(state)) {
        banner.hidden = true;
        renderAll();
      }
    }
  });

  resetGame(19);
})();
