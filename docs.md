Application avec reverse-proxy pour les Applications

Contenant un serveur git (gitea) et un registry docker

Contenant des applications de supervision des ressource, de app, et du network avec des health checker pour être prevenu en cas de probleme
Yohem VAXELAIRE <vaxelaire.yohem@gmail.com>
16:17 (il y a 1 heure)
À moi

# RoadMap

1. Nginx Reverse Proxy
2. letsencrypt/certbot
3. Portainer
4. grafana
5. prometeus
6. CAdvisor
7. mailu (full)/mail-server
8. gitea

# Info / Progress

- [ ] Monitoring :
  - [x] Prometheus
  - [x] node-exporter
  - [x] Grafana
  - [x] Cadvisor
  - [ ] alert_manager
  - [ ] performance fixing (cAdvisor, prom, grfana)
- [x] Management
  - [x] Portainer
- [ ] Git Full
  - [x] Gitea
  - [x] Actions-Runner
    - [x] config
    - [x] use internal netxork
    - [ ] save data on reload
- [ ] GateWay
  - [x] Nginx Proxy
  - [x] CertBot
  - [ ] User Management
  - [ ] create self auto create ssl (access to /etc/letsencrypt)
- [ ] Mail

# Archi

## Doc

### Plan

1. do monitoring without alerting
2. do full management
3. do nginx proxy
4. do gitea
5. mail server
6. Alerting
7. nginx metrics

### Monitoring

1. prometeus
   1. initiat prometeus.yml to check its self
   2. check if the target prometheus is "up" on promtheus web app
2. grafana
   1. datasources config prometeus
3. docker open metrics in daemond.json
4. add docker's metrics to promteus config
5. node exporter
   1. mount volumes of "root" host, sys and proc on readOnly
   2. set volumes in args command entrypoint
   3. Add collector in args command entrypoint
6. add node exporter's metrics to promteus config
7. add graph to grafana with prometeus data
8. or import preset on grafana labs
9. Cadvisor
   1. add CAvisor and redis images
   2. mount volumes "root" host, sys and proc on readOnly
   3. mount /var/run in rw mode
   4. cAvisor depends_on redis

### Management

10. portainer
1. Mount "root" and /docker.sock:ro host in read only

### Gitea and registry

1. gitea

   1. créer la db pgql
   2. mettre les droit de la db sur le volumes (70:70)
   3. créer le User git

   ```sh
   sudo adduser --system --shell /bin/bash --gecos 'Git Version Control' --group --disabled-password --home /home/git git
   ```

   5. sshing
      1. lier /home/git/.shh/:/git/.ssh/
      2. créer un clef shh pour le git user
      ```sh
      sudo -u git ssh-keygen -t rsa -b 4096 -C "Gitea Host Key"
      ```
      3. ajouté la clef au autorized
      ```sh
      sudo -u git cat /home/git/.ssh/id_rsa.pub | sudo -u git tee -a /home/git/.ssh/authorized_keys
      sudo -u git chmod 600 /home/git/.ssh/authorized_keys
      ```
      4. ssh Forwarding host to container (change port)
      ```sh
      cat <<"EOF" | sudo tee /usr/local/bin/gitea
      #!/bin/sh
      ssh -p 2222 -o StrictHostKeyChecking=no git@127.0.0.1 "SSH_ORIGINAL_COMMAND=\"$SSH_ORIGINAL_COMMAND\" $0 $@"
      EOF
      ```
      5. Add User git to ssh connection in `/usr/local/bin/git` (change port)
      ```txt
      Match User git
          AuthorizedKeysCommandUser git
          AuthorizedKeysCommand /usr/bin/ssh -p 222 -o StrictHostKeyChecking=no git@127.0.0.1 /usr/local/bin/gitea keys -c /data/gitea/conf/app.ini -e git -u %u -t %t -k %k
      ```
   6. add shh key on gitea web-panel to send data
   7. Actions-Runner
      1. add act_runner to docker
      2. set up depends_on
      3. set ip restart always
      4. monut volumes for docker.sock, config.yml file and data
      5. Set up Env
         1. CONFIG_FILE was node path of config.yml (like in mount)
         2. GITEA_INSTANCE_URL was the full url to gitea server (use external)
         3. GITEA_RUNNER_NAME is name of Action runnner (cosmetics)
         4. GITEA_RUNNER_REGISTRATION_TOKEN is a token to fin on Admin panel > Action on gitea web interface
      6. don't mount config fil and set CONFIG_FILE env if you dont kown how do conf (just dont forget restart always)
   8. Test actions runner 1. create `./.gitea/workflows/name.yml`
      exemples:

      ```yml
      name: Gitea Actions Demo
      run-name: ${{ gitea.actor }} is testing out Gitea Actions 🚀
      on: [push]

      jobs:
      Explore-Gitea-Actions:
          runs-on: ubuntu-latest
          steps:
          - run: echo "🎉 The job was automatically triggered by a ${{ gitea.event_name }} event."
          - run: echo "🐧 This job is now running on a ${{ runner.os }} server hosted by Gitea!"
          - run: echo "🔎 The name of your branch is ${{ gitea.ref }} and your repository is ${{ gitea.repository }}."
          - name: Check out repository code
              uses: actions/checkout@v4
          - run: echo "💡 The ${{ gitea.repository }} repository has been cloned to the runner."
          - run: echo "🖥️ The workflow is now ready to test your code on the runner."
          - name: List files in the repository
              run: |
              ls ${{ gitea.workspace }}
          - run: echo "🍏 This job's status is ${{ job.status }}."
      ```

   9. set up internal netwrok
      1. create external network for gitea
      2. edit network in config.yml to add the gitea's external network

### Reverse Proxy

1. Set up Nginx
   1. Create config file systeme
   2. disable 443/ssl on http server
   3. open port you need
   4. run on `["/usr/sbin/nginx", "-g", "daemon off;"]`
2. initialise CertBot
   1. Create cert auto script
   2. mount `/etc/nginx` and `/var/www/certbot:rw`
3. Create same mount on nginx
4. Enable 443/ssl par on http section
5. Add a new domains
   1. add network external to Nginx
   2. create conf witout ssl
   3. register Domains in domain env certbot
   4. run compose
   5. enable ssl
   6. reload compose

### Mail

choix :

- mailcow
- mailu
- postfix
- poste.io
- dockermailserver

- instrumentisto/opendkim
- instrumentisto/opendmarc
- haraka/rspamd

pop3(110), imap(110), lmtp(24), submission (587), manageSieve(4190):

- https://github.com/dovecot/docker
- https://hub.docker.com/r/dovecot/dovecot

smtp:

- 25:8025
- https://github.com/devture/exim-relay/blob/master/README.md

1. set up la zone Domains
   1. A = IPv4 | AAAA = APv6
   2. Set up @ on serveur
   3. Set up mail.dnsname on serveur
   4. Lancer le container
   5. Configurer le reverse proxy pour l'access web
   6. create MX Field in DNS Area with domain(@) for name and server mail's domain for the server field
   7. create TXT field "\_dmarc" with value
      ```
      "v=DMARC1; p=reject; rua=mailto:postmaster@vaxelaire.fr; ruf=mailto:admin@vaxelaire.fr; fo=0; adkim=s; aspf=s; pct=100; rf=afrf; sp=reject"
      ```
      ```
      "v=DMARC1; p=none; rua=mailto:dmarc-reports@vaxelaire.fr"
      ```
   8. create TXT field with name point to domain(@)'s name and point to mail MX field server :
      ```
      "v=spf1 mx ~ all"
      ```
      ```
      "v=spf1 a mx ip4:91.108.113.88 ~all"
      ```
   9. create key association txt field
      1. generate DKIM key on web panel of mail server
      2. copy first par of DKIM gerate key for name field and the part between `"` for value

### IA

1. install rocm

   ```
   # version
   ver=6.2

   # amdgpu repository for jammy
   echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/rocm.gpg] https://repo.radeon.com/amdgpu/$ver/ubuntu jammy main" \
      | sudo tee /etc/apt/sources.list.d/amdgpu.list
   sudo apt update
   ```

   ```
   for ver in 5.2; do
   echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/rocm.gpg] https://repo.radeon.com/rocm/apt/$ver jammy main" \
    | sudo tee --append /etc/apt/sources.list.d/rocm.list
   done
   echo -e 'Package: *\nPin: release o=repo.radeon.com\nPin-Priority: 600' \
    | sudo tee /etc/apt/preferences.d/rocm-pin-600
   sudo apt update
   ```

---

## Folders&Files

    \VPS
        \Monitoring
            \Portainer
            \Grafana
            \Prometeus
            \CAdvisor
        \Reverse-Proxy
            \Nginx
                \data
                \Conf
            \Certbot
                \data
                \Cert
        \mail
        \Gitea
        \Projet
            \Labs
            \MinePiece
            \VDV

## Ports Exposed

1. Nginx Reverse Proxy : 80, 443
2. letsencrypt/certbot : 80
3. Portainer : 8000
4. grafana : 8080
5. prometheus : 9090
6. Node exporter : 9100
7. mailu (full)/mail-server : ??
8. gitea: 22, 3000

## Ports published

Nginx Reverse Proxy : 80, 443
Prometeus : 9090
Node exporter : 9100
Docker : 9323

## Networks

- Proxy_Net
- Monitoring
- "Part_Prj_Name

## Domains

Portainer : portainer.vaxelaire.fr
grafana : monitoring.vaxelaire.fr
prometheus : portainer.vaxelaire.f
mailu (full)/mail-server : mail.vaxelaire.fr, mail.minepiece.fr
gitea: git.vaxelaire.fr

# Container

## images

- gitea/gitea:1.22.3
- registry:2.8
- nginx:1.27.2-alpine
- postgres:17-alpine3.20
- certbot/certbot:latest
- grafana/grafana:main
- prom/prometheus:main

## Gitea

Contenant de la CI/CD permetant de push automatiquement sur le registry docker

https://docs.gitea.com/installation/install-with-docker

## Registry Docker

https://distribution.github.io/distribution/

## CertBot

Sertifier les domaines

## Nginx Reverse Proxy

Separation des apps

## Monitoring

- Grafana
- Prometehus

### Prometeus

add to `/etc/docker/daemon.json`

```json
{
  "metrics-addr": "127.0.0.1:9323"
}
```

run `systemctl restart docker`

create prometeus.yml

### prerequis

enable chown sur le WSL

/etc/wsl.conf

    [automount]
    options = "metadata"

creer les user demandé

sudo adduser --system grafana -u 472
sudo adduser --system postgres -u 70

## Docker in Docker

(Dind)
Pour les applications effemere

# DEFI/Implementation

- gestion network
- CI/CD
- grafana
- prometeheus
- health check
- DinD (docker in docker)

Defi:

- git container (gitea)
- registry docker
