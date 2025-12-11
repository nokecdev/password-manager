let socket = null;
let isConnected = false;
const ws = new WebSocket("ws://192.168.0.116:4040");

const btn = document.getElementById("connect-btn");
const statusText = document.getElementById("status-text");
const indicator = document.querySelector(".indicator");

function updateUI(connected, deviceName = null) {
  isConnected = connected;
  btn.textContent = connected ? "Disconnect" : "Connect";
  btn.classList.toggle("active", connected);
  indicator.classList.toggle("green", connected);
  indicator.classList.toggle("red", !connected);
  statusText.textContent = connected
    ? deviceName
      ? `Connected: ${deviceName}`
      : "Connected"
    : "Disconnected";
}

function connect() {
  socket = ws;

  socket.onopen = () => {
    console.log("Connected to WebSocket");
    updateUI(true);
    // Ping request to phone
    socket.send(JSON.stringify({ type: "ping" }));
  };

  socket.onmessage = (event) => {
    try {
      const msg = JSON.parse(event.data);
      if (msg.type === "pong") {
        updateUI(true, msg.deviceName || "Phone");
      }
    } catch {
      console.log("Message:", event.data);
    }
  };

  socket.onerror = (err) => {
    console.error("WebSocket error:", err);
    updateUI(false);
  };

  socket.onclose = () => {
    console.log("Connection closed");
    updateUI(false);
  };
}

function disconnect() {
  if (socket) {
    socket.close();
    socket = null;
  }
  updateUI(false);
}

btn.addEventListener("click", () => {
  if (!isConnected) connect();
  else disconnect();
});
