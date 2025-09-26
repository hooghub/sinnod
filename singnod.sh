#!/bin/bash

# 欢迎信息
echo "=================================================="
echo " Sing-box 配置生成脚本"
echo " 支持 VLESS 和 Hysteria2 节点"
echo "=================================================="

# 读取用户输入
echo -n "请输入服务器 IP 地址: "
read server_ip

echo -n "请输入服务器端口 (默认: 443): "
read server_port
if [ -z "$server_port" ]; then
    server_port=443
fi

echo -n "请输入 VLESS UUID: "
read uuid

echo -n "请输入 Hysteria2 密码: "
read h2_password

echo -n "请输入服务器域名（可选，直接回车跳过）: "
read server_name
if [ -z "$server_name" ]; then
    server_name="$server_ip"
fi

# 生成配置文件
cat << EOF > config.json
{
  "inbounds": [
    {
      "type": "tun",
      "interface_name": "tun0",
      "inet4_address": "172.19.0.1/24",
      "auto_route": true,
      "strict_route": true
    }
  ],
  "outbounds": [
    {
      "type": "vless",
      "tag": "vless-out",
      "server": "$server_ip",
      "server_port": $server_port,
      "uuid": "$uuid",
      "flow": "xtls-rprx-vision",
      "tls": {
        "enabled": true,
        "server_name": "$server_name",
        "utls": {
          "enabled": true,
          "fingerprint": "chrome"
        }
      }
    },
    {
      "type": "hysteria2",
      "tag": "hysteria2-out",
      "server": "$server_ip",
      "server_port": $server_port,
      "up_mbps": 100,
      "down_mbps": 100,
      "obfs": {
        "enabled": true,
        "password": "$h2_password"
      },
      "auth": {
        "type": "password",
        "password": "$h2_password"
      },
      "tls": {
        "enabled": true,
        "server_name": "$server_name",
        "insecure": false
      }
    }
  ],
  "route": {
    "rules": [
      {
        "geosite": "cn",
        "geoip": "cn",
        "outbound": "direct"
      },
      {
        "domain": [
          "domain:example.com"
        ],
        "outbound": "vless-out"
      },
      {
        "network": "tcp",
        "port": [
          80,
          443
        ],
        "outbound": "hysteria2-out"
      }
    ]
  }
}
EOF

# 提示信息
echo "=================================================="
echo " 配置文件已生成为 config.json"
echo " 请确保 Sing-box 已安装并位于 PATH 中"
echo " 运行 Sing-box 的命令如下:"
echo "=================================================="
echo "sing-box run -c config.json"
echo "=================================================="
echo " 如果需要停止 Sing-box，按 Ctrl+C 即可"
echo "=================================================="
