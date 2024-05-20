# !/bin/bash
#
# Use this script to update your GitHub Actions Runner's Host to use custom SSL Certificates from GitHub Enterprise appliance.

# Read Hostname
echo "Name of the HOST the certificate is for? (git.example.com)"
read -r $host

# Grab certificate and store in /tmp 
openssl s_client -connect $host:443 -servername $host | openssl x509 -out /tmp/$host.pem

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

echo "Certificate for $host has been added to the OS certificate store."
