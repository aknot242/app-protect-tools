# For Alpine 3.10:
FROM alpine:3.10

# Download and add the NGINX signing key:
RUN wget -O /etc/apk/keys/nginx_signing.rsa.pub https://cs.nginx.com/static/keys/nginx_signing.rsa.pub

# Download and add the security updates signing key:
RUN wget -O /etc/apk/keys/app-protect-security-updates.rsa.pub https://cs.nginx.com/static/keys/app-protect-security-updates.rsa.pub

# Add NGINX Plus repository:
RUN printf "https://pkgs.nginx.com/plus/alpine/v`egrep -o '^[0-9]+\.[0-9]+' /etc/alpine-release`/main\n" | tee -a /etc/apk/repositories

# Add NGINX App Protect repository:
RUN printf "https://pkgs.nginx.com/app-protect/alpine/v`egrep -o '^[0-9]+\.[0-9]+' /etc/alpine-release`/main\n" | tee -a /etc/apk/repositories

# Add security updates repository
RUN printf "https://pkgs.nginx.com/app-protect-security-updates/alpine/v`egrep -o '^[0-9]+\.[0-9]+' /etc/alpine-release`/main\n" | tee -a /etc/apk/repositories

# Update the repository and install the most recent version of the NGINX App Protect package (which includes NGINX Plus):
RUN --mount=type=secret,id=nginx-repo.crt,dst=/etc/apk/cert.pem,mode=0644 \
	--mount=type=secret,id=nginx-repo.key,dst=/etc/apk/cert.key,mode=0644 \
    apk update && apk add bash curl jq nginx-plus app-protect-compiler app-protect-attack-signatures app-protect-threat-campaigns \
        && apk add yq --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community

COPY ./convert.sh convert.sh
COPY ./signature-report.sh signature-report.sh
