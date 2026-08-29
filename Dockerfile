FROM mcr.microsoft.com/dotnet/aspnet:10.0

ADD --link https://packages.microsoft.com/config/debian/13/packages-microsoft-prod.deb /
RUN <<HEREDOC
    dpkg -i packages-microsoft-prod.deb && rm packages-microsoft-prod.deb

    apt-get update && apt-get install -y libmsquic dnsutils iputils-ping
    apt-get clean -y && rm -rf /var/lib/apt/lists/*

    mkdir -p /etc/dns /opt/technitium/dns /var/log/technitium/dns && \
    
    git clone --depth 1 https://github.com/TechnitiumSoftware/TechnitiumLibrary.git TechnitiumLibrary
    git clone --depth 1 https://github.com/TechnitiumSoftware/DnsServer.git DnsServer

    dotnet build TechnitiumLibrary/TechnitiumLibrary.ByteTree/TechnitiumLibrary.ByteTree.csproj -c Release
    dotnet build TechnitiumLibrary/TechnitiumLibrary.Net/TechnitiumLibrary.Net.csproj -c Release
    dotnet build TechnitiumLibrary/TechnitiumLibrary.Security.OTP/TechnitiumLibrary.Security.OTP.csproj -c Release
    
    dotnet publish DnsServer/DnsServerApp/DnsServerApp.csproj -c Release
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
