function myip -d "Print the public IP address of this machine"
    curl -fsS https://ipinfo.io/ip
    echo
end
