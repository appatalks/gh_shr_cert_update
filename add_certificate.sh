# !/bin/bash
#
# Use this script to update your GitHub Actions Runner's Host to use custom SSL Certificates from GitHub Enterprise appliance.

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo -e "\e[31mThis script must be run as root. Use sudo.\e[0m" 
   exit 1
fi

# Read Hostname
echo ""
echo -e "\e[32mName of the HOST the certificate is for? (git.example.com)\e[0m"
read -r host

# Grab certificate and store in /tmp 
echo ""
echo -e "\e[32mRetrieving certificate. Please Stand By...\e[0m"
openssl s_client -connect $host:443 -servername $host | openssl x509 -out /tmp/$host.pem

# Detect OS
os=$(grep -Eo '^(ID_LIKE|ID)=[a-zA-Z]+' /etc/os-release | cut -d= -f2)

# Update certificate store based on OS
case "$os" in
    "ubuntu"|"debian"|"linuxmint")
        sudo cp /tmp/$host.pem /etc/ssl/certs/
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
