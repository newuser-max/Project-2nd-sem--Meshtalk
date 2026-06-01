# Meshtalk
---
A peer-to-peer mesh messaging app built with Qt6/QML and C++.
Devices through bluetooth can relay encrypted messages without any central server.

Collaborators

| Name of the student | Roll no. / Regd. No. |
|---------------------|----------------------|
| Ashutosh Dahal      | 2 / 041028-25        |
| Prasid Dahal        | 4 / 041030-25        |
| Rushan Dahal        | 5 / 041031-25        |
| Jishan Dhakal       | 11 / 041037-25       |
| Pranjal Ghimire     | 24 / 041050-25       |



---

## Features

- 🔵 **Automatic peer discovery over Bluetooth** — scans for nearby devices running MeshTalk 
- 🔒 **End-to-end AES-256-GCM encryption** — every message is encrypted before leaving your device; a 16-byte GCM tag detects any tampering (OpenSSL)
- 🔁 **Mesh routing with hop-count limiting** — messages hop device-to-device through the Bluetooth mesh; TTL = 7 prevents infinite loops
- 💬 **Broadcast and direct messaging** — send to one peer by nickname or broadcast to all reachable devices at once
- 📵 **Works entirely offline** — no internet, no Wi-Fi router, no hotspot required; pure Bluetooth only

---

## How It Works

1. When you set a nickname, the app scans for nearby Bluetooth devices
   running MeshTalk 
2. Each device recognises nearby devices and connects individually via
   `QBluetoothSocket` — those devices do the same, forming a mesh
3. Messages are encrypted with AES-256-GCM before being sent over Bluetooth
4. Each packet carries a hop count — it is decremented at every relay node
   and dropped when it reaches zero, preventing infinite loops

---

## Tech Stack

| Layer      | Technology                        |
|------------|-----------------------------------|
| UI         | Qt6 QML                           |
| Backend    | C++ / Qt6                         |
| Networking | Qt Bluetooth LE (GATT)            |
| Build      | CMake 3.16+                       |


---

## Requirements

- Qt 6.10 or later 
- CMake 3.16+
- OpenSSL 3.x

---

## Building

```bash
mkdir build && cd build
cmake ..
cmake --build . -j4
```

Or open the project in Qt Creator and click Run.

---

##Usage

-Launch the app on two or more devices on the same or nearby physical space
-Enter a nickname — this starts BLE advertising and scanning immediately
-Devices discover each other automatically within seconds
-Send a message to a specific nickname or broadcast to All
-Messages relay through intermediate nodes automatically if devices are out of direct range

---

## License

MIT License — free to use, modify, and distribute.


#testing 