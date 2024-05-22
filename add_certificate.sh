# !/bin/bash
#
# Run this script from the Runner's installation to update your Runner's Host to use custom SSL Certificates from GitHub Enterprise appliance.

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo -e "\e[31mThis script must be run as root. Use sudo.\e[0m" 
   exit 1
fi

# Check if backup.config exists
if [[ ! -f "backup.config" ]]; then
    echo -e "\e[31mbackup.config file not found in the current directory. Check path.\e[0m"
    exit 1
fi

# Read the hostname from backup.config
source backup.config

# Check if GHE_HOSTNAME is set
if [[ -z "$GHE_HOSTNAME" ]]; then
    echo ""
    echo -e "\e[31mPlease remember to set GHE_HOSTNAME variable in backup.config.\e[0m"
    GHE_HOSTNAME="git.example.com"
fi

# Confirm hostname with the user
echo ""
echo -e "\e[32mThe hostname from backup.config is: $GHE_HOSTNAME\e[0m"
echo -e "\e[32mIs this correct? (y/n)\e[0m"
read -r confirm

if [[ "$confirm" != "y" ]]; then
    echo ""
    echo -e "\e[32mPlease enter the correct hostname:\e[0m"
    read -r host
else
    host=$GHE_HOSTNAME
fi

# Grab certificate and store in /tmp 
echo ""
echo -e "\e[32mRetrieving certificate. Please Stand By...\e[0m"
openssl s_client -connect $host:443 -servername $host | openssl x509 -out /tmp/$host.pem

# Detect OS
os=$(grep -Eo '^(ID_LIKE|ID)=[a-zA-Z]+' /etc/os-release | cut -d= -f2)

# Update certificate store based on OS
case "$os" in
    "ubuntu"|"debian"|"linuxmint")
        sudo mkdir -p /etc/ssl/certs/
        sudo cp /tmp/$host.pem /etc/ssl/certs/
        sudo echo "NODE_EXTRA_CA_CERTS=/etc/ssl/certs/$host.pem" >> .env
        sudo update-ca-certificates
        ;;
    "fedora"|"centos"|"rhel"|"redhat")
        sudo mkdir -p /etc/pki/ca-trust/source/anchors/ 
        sudo cp /tmp/$host.pem /etc/pki/ca-trust/source/anchors/
        sudo echo "NODE_EXTRA_CA_CERTS=/etc/pki/ca-trust/source/anchors/$host.pem" >> .env
        sudo update-ca-trust
        ;;
    "suse"|"opensuse")
        sudo mkdir -p /etc/pki/trust/anchors/
        sudo cp /tmp/$host.pem /etc/pki/trust/anchors/
        sudo echo "NODE_EXTRA_CA_CERTS=/etc/pki/trust/anchors/$host.pem" >> .env
        sudo update-ca-certificates
        ;;
    "arch")
        sudo mkdir -p /etc/ssl/certs/
        sudo cp /tmp/$host.pem /etc/ssl/certs/
        sudo echo "NODE_EXTRA_CA_CERTS=/etc/ssl/certs/$host.pem" >> .env
        sudo update-ca-trust
        ;;        
    *)
        echo ""
        echo "\e[31mAppologies - Unsupported OS\e[0m"
        echo ""
        echo "Please consider helping improve this script with a pull request. Thank you."
        exit 1
        ;;
esac

echo ""
echo -e "\e[32mCertificate for $host has been added to the OS certificate store.\e[0m"
