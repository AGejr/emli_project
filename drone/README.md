# Drone

## Image sync

### Setup laptop as drone

1. Enable ssh server on laptop
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
Port 22
AllowUsers emli
PermitRootLogin no
```

4. Install and configure fail2ban
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

### Create ssh keys on wildlife cam (pi)
```
ssh-keygen -f ./id_ed25519_wildlifecam -t ed25519
```

Copy the public key to the "drone".

### Test ssh connection
Test that the wildlife cam (pi) can ssh into the drone (laptop)
```
ssh -i ~/.ssh/id_ed25519_wildlifecam emli@[Drone IP]
```

### Rsync via ssh
If the dir containing the wildlife images is `~/Images/`

```
rsync -avz ~/Images/* emli@[Drone IP]:~/Images/.
```
