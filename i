<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>가상 코인 시뮬레이터</title>
  <style>
    body { font-family: Arial; max-width: 800px; margin: auto; padding: 20px; }
    h2 { margin-bottom: 10px; }
    canvas { width: 100%; height: 200px; border: 1px solid #ccc; margin-top: 20px; }
    table { width: 100%; border-collapse: collapse; margin-top: 20px; }
    th, td { border: 1px solid #aaa; padding: 5px; text-align: center; }
    input[type=number] { width: 100px; }
  </style>
</head>
<body>
  <h2>💰 가상 코인 시뮬레이터</h2>

  <div>
    <button onclick="selectCoin('BTC')">BTC</button>
    <button onclick="selectCoin('DOGE')">DOGE</button>
    <button onclick="selectCoin('SOL')">SOL</button>
  </div>

  <p>선택 종목: <strong id="selectedCoin">BTC</strong></p>
  <p>현재 가격: ₩<span id="currentPrice">--</span></p>
  <p>잔고: ₩<span id="balance">50000000</span></p>
  <p>보유량: <span id="holdings">없음</span></p>

  <div>
    <input type="number" id="amount" step="0.001" value="1">
    <button onclick="buy()">매수</button>
    <button onclick="sell()">매도</button>
  </div>

  <canvas id="chart"></canvas>

  <h3>거래 내역</h3>
  <table>
    <thead>
      <tr><th>시간</th><th>종목</th><th>구분</th><th>수량</th><th>가격</th></tr>
    </thead>
    <tbody id="history"></tbody>
  </table>
  <script>
let coins = {
  BTC: { price: 30000000, history: [], holding: 0 },
  DOGE: { price: 200, history: [], holding: 0 },
  SOL: { price: 40000, history: [], holding: 0 }
};
let balance = 50000000;
let selected = 'BTC';
let historyList = [];

function selectCoin(c) {
  selected = c;
  document.getElementById('selectedCoin').innerText = c;
  updateUI();
}

function buy() {
  let amt = parseFloat(document.getElementById('amount').value);
  if (isNaN(amt) || amt <= 0) return;
  let total = coins[selected].price * amt;
  if (total > balance) return alert("잔고 부족");
  coins[selected].holding += amt;
  balance -= total;
  addHistory('매수', amt);
  updateUI();
}

function sell() {
  let amt = parseFloat(document.getElementById('amount').value);
  if (isNaN(amt) || amt <= 0) return;
  if (coins[selected].holding < amt) return alert("보유량 부족");
  coins[selected].holding -= amt;
  balance += coins[selected].price * amt;
  addHistory('매도', amt);
  updateUI();
}

function addHistory(type, amt) {
  let time = new Date().toLocaleTimeString();
  historyList.push({ time, coin: selected, type, amt, price: coins[selected].price });
  renderHistory();
}

function renderHistory() {
  let el = document.getElementById('history');
  el.innerHTML = '';
  historyList.slice(-20).reverse().forEach(h => {
    el.innerHTML += `<tr>
      <td>${h.time}</td>
      <td>${h.coin}</td>
      <td>${h.type}</td>
      <td>${h.amt.toFixed(4)}</td>
      <td>₩${Math.round(h.price).toLocaleString()}</td>
    </tr>`;
  });
}

function updateUI() {
  document.getElementById('currentPrice').innerText = Math.round(coins[selected].price).toLocaleString();
  document.getElementById('balance').innerText = Math.round(balance).toLocaleString();
  let text = Object.entries(coins).map(([k, v]) => `${k}: ${v.holding.toFixed(4)}개`).join(', ');
  document.getElementById('holdings').innerText = text;
  drawChart();
}

function updatePrices() {
  for (let key in coins) {
    let coin = coins[key];
    let change = coin.price * (Math.random() * 0.05 * (Math.random() < 0.5 ? -1 : 1));
    coin.price += change;
    if (coin.price < 1) coin.price = 1;
    coin.history.push(coin.price);
    if (coin.history.length > 100) coin.history.shift();
  }
  updateUI();
}
setInterval(updatePrices, 7000);

function drawChart() {
  let canvas = document.getElementById('chart');
  let ctx = canvas.getContext('2d');
  canvas.width = canvas.clientWidth;
  canvas.height = 200;
  ctx.clearRect(0, 0, canvas.width, canvas.height);

  let max = Math.max(...coins[selected].history);
  let min = Math.min(...coins[selected].history);
  let hist = coins[selected].history;
  if (hist.length < 2) return;

  ctx.beginPath();
  hist.forEach((p, i) => {
    let x = (i / (hist.length - 1)) * canvas.width;
    let y = canvas.height - ((p - min) / (max - min)) * canvas.height;
    if (i === 0) ctx.moveTo(x, y);
    else ctx.lineTo(x, y);
  });
  ctx.strokeStyle = 'blue';
  ctx.stroke();
}

selectCoin('BTC');
updateUI();
</script>
</body>
</html>