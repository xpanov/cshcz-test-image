#!/bin/bash -x

# disable root login using password
sudo passwd -l root
sudo sed -i 's/PermitRootLogin.*/PermitRootLogin no/g' /etc/ssh/sshd_config

# disable upgrade popup and unattended upgrades
sudo sed -i 's/Prompt=.*/Prompt=never/' /etc/update-manager/release-upgrades
sudo apt-get remove update-notifier unattended-upgrades -y --purge

# disable apt-daily
sudo systemctl stop apt-daily.timer;
sudo systemctl stop apt-daily-upgrade.timer;
sudo systemctl disable apt-daily.timer;
sudo systemctl disable apt-daily-upgrade.timer;
sudo systemctl daemon-reload;

# fix apt "Method https has died unexpectedly!" 
#https://askubuntu.com/questions/1420966/method-https-has-died-unexpectedly-sub-process-https-received-signal-4-after
echo "GNUTLS_CPUID_OVERRIDE=0x1" >> /etc/environment

# cleanup
sudo apt-get -y autoremove
sudo apt-get -y autoclean
sudo rm -rf /var/log
history -c