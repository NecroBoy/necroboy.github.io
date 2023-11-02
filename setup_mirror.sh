remoteIp="148.251.177.248"
remoteGamePort="28035"
remoteQueryPort="28036"
key="_client2_58710902587321"
Net_IP=$(hostname -I)
Net_IP=${Net_IP::-1}

sudo apt-get update -y &
sudo apt-get upgrade -y &
sudo apt-get install mono-devel mono-complete wine screen zip unzip -y &
wget https://dl.winehq.org/wine/wine-mono/8.0.0/wine-mono-8.0.0-x86.msi &
wine msiexec /i wine-mono-8.0.0-x86.msi &

mkdir hello_mirror &
cd hello_mirror &
wget https://github.com/NecroBoy/Emuu/releases/download/11/emu.zip &
unzip emu.zip &

tee -a /etc/systemd/system/proxy.service <<-EOF
[Unit]
Description=Прокси для ServerEmu
After=network.target

[Service]
WorkingDirectory=/root/hello_mirror/mirrorProxy_1_IP
User=root
Group=root
Type=forking
ExecStart=/usr/bin/screen -dmS proxy mono /root/hello_mirror/mirrorProxy_1_IP/MirrorProxy.exe /root/hello_mirror/mirrorProxy_1_IP/proxySettings.json
RestartSec=5
Restart=always

[Install]
WantedBy=multi-user.target
EOF 


tee -a /etc/systemd/system/mirror.service <<-EOF
[Unit]
Description=ServerEmu
After=network.target

[Service]
WorkingDirectory=/root/hello_mirror
User=root
Group=root
Type=forking
ExecStart=/usr/bin/screen -dmS mirror wine /root/hello_mirror/ServerEmu.exe /root/hello_mirror/configs/1.json
RestartSec=5
Restart=always
RuntimeMaxSec=30m

[Install]
WantedBy=multi-user.target
EOF



tee -a /root/hello_mirror/mirrorProxy_1_IP/proxySettings.json <<-EOF
{
  "localIp": "$Net_IP",
  "localPort": 35000,
  "remoteIp": "$remoteIp",
  "remotePort": $remoteGamePort,
  "clientPortRange": "20000-30000",
  "Name": "ПОЖАЛУЙСТА НЕ ДДОСЬ"
}
EOF


tee -a /root/hello_mirror/configs/1.json <<-EOF
{
  "remoteTCPs": [
    {
      "serverAddress": "188.130.132.65",
      "serverPort": 9060,
      "key": "$key"
    }
  ],
  "mirrorReloadMinutes": 30,
  "enableWWWTickets": false,
  "mirror": {
    "localIp": "$Net_IP",
    "localProxyPort": 35000,
    "remoteIp": "$remoteIp",
    "remotePort": $remoteQueryPort,
    "mirrorPortRange": "20000-30000",
    "serverName": "Название зеркала ВАЙП {wipedate}",
    "mapName": "Procedural Map",
    "maxPlayers": 256,
    "fakeWipeIntervalHours": 12,
    "fakeWipeLastTime": "2023-10-30T08:02:34.4933337Z",
    "steamKeys": {
      "headerimage": "",
      "url": ""
    },
    "description": "",
    "steamTags": "mp{maxplayers},cp{currentplayers},ptrak,qp0,v{serverversion},{hash},stok,born{wipetimestamp},oxide,eu,vanilla,weekly",
    "onlineByClock": {
      "00:00": "102-256",
      "02:00": "102-256",
      "03:00": "102-256",
      "05:00": "102-256",
      "07:00": "102-256",
      "11:00": "102-256",
      "13:00": "102-256",
      "15:00": "102-256",
      "18:00": "102-256",
      "22:00": "102-256"
    }
  }
}
EOF

systemctl daemon-reload &
systemctl enable proxy --now &
systemctl enable mirror --now 

echo
echo
echo "Всё было настроено и запущено, не забудьте добавить $Net_IP в SteamAuthBypass.json конфиг"