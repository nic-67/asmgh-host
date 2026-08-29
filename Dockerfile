FROM mcr.microsoft.com/dotnet/aspnet:10.0

ADD --link https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb /
RUN <<HEREDOC
    dpkg -i packages-microsoft-prod.deb && rm packages-microsoft-prod.deb

    apt-get update && apt-get install -y dotnet-sdk-10.0 aspnetcore-runtime-10.0 git ca-certificates curl tzdata wget libmsquic dnsutils iputils-ping

    mkdir -p /usr/bin /etc/dns /opt/technitium/dns /var/log/technitium/dns
HEREDOC

WORKDIR /opt/technitium/dns
COPY --link ./DnsServerApp/bin/Release/publish /opt/technitium/dns

ENTRYPOINT ["/usr/bin/dotnet", "/opt/technitium/dns/DnsServerApp.dll"]
CMD ["/etc/dns"]

EXPOSE \
  53/udp 53/tcp \
  853/udp 853/tcp \
  443/udp 443/tcp \
  80/tcp 8053/tcp \
  5380/tcp 53443/tcp \
  67/udp

LABEL org.opencontainers.image.title="Fork of Technitium DNS Server"
LABEL org.opencontainers.image.vendor="Asmgh-Host"
LABEL org.opencontainers.image.url="https://asmgh-host.onrender.com/"
LABEL org.opencontainers.image.authors="root-67@lavache.com"
