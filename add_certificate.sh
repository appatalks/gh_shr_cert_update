# !/bin/bash
#
# Use this script to update your GitHub Actions Runner's Host to use custom SSL Certificates from GitHub Enterprise appliance.

# Function to display a progress indicator
show_progress() {
    local -r pid="$1"
    local -r delay='0.75'
    local spinstr='|/-\\'
    echo -n "Retrieving certificate, please wait... "
    tput civis  # Hide cursor
    while ps -p "$pid" > /dev/null 2>&1; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    tput cnorm  # Show cursor
    echo "Done"
}

# Read Hostname
echo ""
echo -e "\e[32mName of the HOST the certificate is for? (git.example.com)\e[0m"
read -r host

# Grab certificate and store in /tmp 
echo ""
openssl s_client -connect $host:443 -servername $host | openssl x509 -out /tmp/$host.pem
show_progress $!

# Detect OS
os=$(grep -Eo '^(ID_LIKE|ID)=[a-zA-Z]+' /etc/os-release | cut -d= -f2)

# Update certificate store based on OS
case "$os" in
    "ubuntu"|"debian"|"linuxmint")
        sudo cp /tmp/$host.pem /usr/local/share/ca-certificates/
        sudo update-ca-certificates
        ;;
    "fedora"|"centos"|"rhel"|"redhat")
        sudo cp /tmp/$host.pem /etc/pki/ca-trust/source/anchors/
        sudo update-ca-trust
        ;;
    "suse"|"opensuse")
        sudo cp /tmp/$host.pem /etc/pki/trust/anchors/
        sudo update-ca-certificates
        ;;
    *)
        echo "Unsupported OS"
        exit 1
        ;;
esac

echo ""
echo -e "\e[32mCertificate for $host has been added to the OS certificate store.\e[0m"
