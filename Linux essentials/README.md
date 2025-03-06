## Steps I took

### 1. Install Tools
- Installed essential packages:
  ```bash
  apt update
  apt install nano dnsutils netcat-openbsd curl nginx -y
  ```

### 2. Lookup `tremend.com` IP
- Ran:
  ```bash
  dig tremend.com +short
  ```
- **Result**: Got the IPs
176.34.175.11
52.18.209.114
34.248.35.216

### 3. Map `8.8.8.8` to `google-dns`
- Edited `/etc/hosts`:
  ```bash
  echo "8.8.8.8 google-dns" >> /etc/hosts
  ```

### 4. Check DNS Port
- Tested port 53:
  ```bash
  nc -zv google-dns 53
  ```
- **Result**: Connection to google-dns (8.8.8.8) 53 port [tcp/*] succeeded!

### 5. Use Google DNS
- Updated `/etc/resolv.conf`:
  ```bash
  echo "nameserver 8.8.8.8" > /etc/resolv.conf
  ```
- Verified with `dig tremend.com +short`. The same IP addresses were found.

### 6. Set Up Nginx
- Started Nginx:
  ```bash
  nginx &
  ```
- Checked with `curl localhost`. The html file was the output

### 7. Check Nginx Port
- Ran:
  ```bash
  ss -tuln | grep 80
  ```
- **Result**: Listening on port 80.

tcp   LISTEN 0      511          0.0.0.0:80        0.0.0.0:*

tcp   LISTEN 0      511             [::]:80           [::]:*
### Bonus Tasks
#### 8. Change Nginx Port to 8080
- Edited `/etc/nginx/sites-enabled/default`:
  ```bash
  nano /etc/nginx/sites-enabled/default
  ```
  Changed from 80 to 8080 here:
server {
        listen 8080 default_server;
        listen [::]:8080 default_server;
  }
- Reloaded Nginx:
  ```bash
  nginx -s reload
  ```
- Verified with `curl localhost:8080`. Got back the same html from before, so great.

#### 9. Update HTML Title
- Found the nginx html inside the `/var/www/html` using ls
- Modified `/var/www/html/index.nginx-debian.html`:
  ```bash
  sed -i 's/Welcome to nginx!/I have completed the Linux part of the Tremend DevOps internship project/' /var/www/html/index.nginx-debian.html
  ```
- Checked with `curl localhost:8080`. The new title appeared in the html.

---
