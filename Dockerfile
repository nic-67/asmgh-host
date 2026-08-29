# syntax=docker.io/docker/dockerfile:1

FROM mcr.microsoft.com/dotnet/aspnet:10.0

# Add the MS repo to install `libmsquic` to support DNS-over-QUIC:
ADD --link https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb /
RUN <<HEREDOC
  dpkg -i packages-microsoft-prod.deb && rm packages-microsoft-prod.deb
  # `dnsutils` added to include the `dig` command for troubleshooting:
  apt-get update && apt-get install -y libmsquic dnsutils iputils-ping
  apt-get clean -y && rm -rf /var/lib/apt/lists/*

  # `/etc/dns` is expected to exist the default directory for persisting state:
  # (Users should volume mount to this location or modify the `CMD` of their container)
  mkdir /etc/dns
HEREDOC


## Only append image metadata below this line:
EXPOSE \
  # Standard DNS service
  53/udp 53/tcp      \
  # DNS-over-QUIC (UDP) + DNS-over-TLS (TCP)
  853/udp 853/tcp    \
  # DNS-over-HTTPS (UDP => HTTP/3) (TCP => HTTP/1.1 + HTTP/2)
  443/udp 443/tcp    \
  # DNS-over-HTTP (for when running behind a reverse-proxy that terminates TLS)
  80/tcp 8053/tcp    \
  # Technitium web console + API (HTTP / HTTPS)
  5380/tcp 53443/tcp \
  # DHCP
  67/udp

LABEL org.opencontainers.image.title="Fork of Technitium DNS Server"
LABEL org.opencontainers.image.vendor="Asmgh-Host"
LABEL org.opencontainers.image.url="https://asmgh-host.onrender.com/"
LABEL org.opencontainers.image.authors="root-67@lavache.com"
