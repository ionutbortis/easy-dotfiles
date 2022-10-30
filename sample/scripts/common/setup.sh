#!/bin/bash

setup_battery_charge_limit() {
  local charge_limit="60"

  echo "Setting up battery charge limit to [ $charge_limit ]..."

  local service_file="/etc/systemd/system/battery-charge-threshold.service"

  echo "[Unit]
Description=Set the battery charge threshold
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'echo $charge_limit > /sys/class/power_supply/BAT0/charge_control_end_threshold'

[Install]
WantedBy=multi-user.target" | sudo tee "$service_file"

  sudo chmod 644 "$service_file"
  sudo systemctl daemon-reload
  sudo systemctl enable "$(basename $service_file)"
}

setup_battery_charge_limit
