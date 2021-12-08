# For Ubuntu 20.04:
FROM ubuntu:focal

# Install prerequisite packages:
RUN apt-get update && apt-get install -y apt-transport-https lsb-release ca-certificates software-properties-common wget gnupg2

# Download and add the NGINX signing key:
RUN wget https://cs.nginx.com/static/keys/nginx_signing.key && apt-key add nginx_signing.key

# Download and add the NGINX Security Updates signing key:
RUN wget https://cs.nginx.com/static/keys/app-protect-security-updates.key && apt-key add app-protect-security-updates.key

# Download the yq signing key
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys CC86BB64

# Add NGINX App-protect repository:
RUN printf "deb https://pkgs.nginx.com/app-protect/ubuntu `lsb_release -cs` nginx-plus\n" | tee /etc/apt/sources.list.d/nginx-app-protect.list

# Add security updates repository
RUN printf "deb https://pkgs.nginx.com/app-protect-security-updates/ubuntu/ `lsb_release -cs` nginx-plus\n" | tee /etc/apt/sources.list.d/app-protect-security-updates.list

# Download the apt configuration to `/etc/apt/apt.conf.d`:
RUN wget -P /etc/apt/apt.conf.d https://cs.nginx.com/static/files/90pkgs-nginx

# Update the repository and install the most recent version of the NGINX App Protect WAF Compiler package, Signatures and Threat Campaigns and other utilities
RUN --mount=type=secret,id=nginx-crt,dst=/etc/ssl/nginx/nginx-repo.crt,mode=0644 \
    --mount=type=secret,id=nginx-key,dst=/etc/ssl/nginx/nginx-repo.key,mode=0644 \
    add-apt-repository ppa:rmescandon/yq && apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get install -y curl jq yq app-protect-compiler app-protect-attack-signatures app-protect-threat-campaigns

COPY ./convert.sh convert.sh
COPY ./signature-report.sh signature-report.sh
