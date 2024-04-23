# Drone

## Image sync

### Setup pi as wildlife cam

1. Enable ssh server on pi
```bash
sudo apt install openssh-server
sudo systemctl start ssh
sudo systemctl enable ssh
sudo systemctl status ssh
```

2. Setup firewall
```bash
sudo ufw enable
sudo ufw allow ssh
```

3. Configure ssh securely
`/etc/ssh/ssh_config`
```
PasswordAuthentication no
PubkeyAuthentication yes
```

6. Install and configure fail2ban
```bash
sudo apt install fail2ban
sudo cp /etc/fail2ban/fail2ban.conf /etc/fail2ban/fail2ban.local
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
```

`/etc/fail2ban/jail.local`
```
bantime = 600
findtime = 600
maxretry = 3

// sshd config
backend=systemd
```

```bash
sudo systemctl start fail2ban
sudo systemctl enable fail2ban
sudo systemctl status fail2ban
```

### Create ssh keys on laptop
```
ssh-keygen -f ./id_ed25519_drone -t ed25519
```

Copy the public key to pi

### Test ssh connection
Test that the drone (laptop) can ssh into the wildlife cam (pi)
```
ssh -i ~/.ssh/id_ed25519_drone emli@[Wildlife cam IP]
```

### Rsync via ssh
Run sync_images.sh script

```bash
./sync_images.sh
```
