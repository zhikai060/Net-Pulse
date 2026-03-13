\# 🚀 NetPulse



NetPulse is a lightweight PowerShell-based network diagnostic tool.



\## Features



\- Interactive IP  Domain input

\- Ping or Tracert mode

\- Ping count selection (10  30  50  100  200  Infinite)

\- Infinite mode supports press Q to stop

\- Real-time statistics

&nbsp; - Min latency

&nbsp; - Max latency

&nbsp; - Average latency

&nbsp; - TTL


## Screenshot

![NetPulse Example](Example.png)## Usage

### 1️⃣ Download

Download `NetPulse.ps1` from the **Releases** page.

### 2️⃣ Run the script

Open PowerShell in the folder and run:

```
.\NetPulse.ps1
```

If PowerShell blocks the script, you can allow scripts temporarily:

```
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

### 3️⃣ Enter target

Input the IP address or domain you want to test.

Example:

```
8.8.8.8
google.com
```

### 4️⃣ Select ping count

Choose one of the preset options:

```
1) 10
2) 30
3) 50
4) 100
5) 200
6) Infinite (-t)
```

Infinite mode can be stopped by pressing **Q**.

### 5️⃣ View results

NetPulse will display:

* Latency (colorized)
* Packet loss %
* Min / Max / Avg latency
* TTL
---



\## Installation



Download the latest release from



Releases section



Or clone the repository

git clone https://github.com/zhikai060/Net-Pulse.git



\## Requirements



\- Windows 10 / 11

\- PowerShell 5.1+





\## Roadmap



\- Packet loss %

\- Colorized latency display

\- Multi-target comparison mode

\- Parameter-based CLI execution



---



Made with PowerShell 
