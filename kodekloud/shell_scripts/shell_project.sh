#!/bin/bash
#
# Automate Ecommerce Application Deployment
# Author: Upendar Gareri

###########################################
# Print a message in a given color
# Arguments:
#   1 - Color. e.g green, red
#   2 - Message
# Outputs:
#   Writes message to stdout
###########################################
function print_color(){
    NC='\033[0m'  # No Color
    case $1 in
      "green") COLOR='\033[0;32m' ;;
      "red") COLOR='\033[0;31m' ;;
      "*") COLOR=$NC
    esac

    echo -e "$COLOR $2 $NC"
}

###########################################
# Check status of a service. If not active, exit script
# Arguments:
#   Service Name e.g firewalld, mariadb
###########################################
function check_service_status(){
    is_active=$(sudo systemctl is-active $1)
    if [  $is_active = "active" ]
    then
        print_color "green" "$1 is active and running"
    else
        print_color "red" "$1 is not active/running"
        exit 1
    fi
}

###########################################
# Check status of firewalld rule. If not configured, exit
# Arguments:
#   Port number e.g 3306, 80
###########################################
function is_firewalld_rule_configured(){
    firewalld_port=$(sudo firewall-cmd --list-all --zone=public | grep ports)

    if [[ $firewalld_port = *$1* ]]
    then
        print_color "green" "Firewalld has port $1 configured"
    else
        print_color "red" "Friewalld port $1 is not configured"
        exit 1
    fi
}

###########################################
# Check if given item is present in output
# Arguments:
#   1 - Output
#   2 - Item
###########################################
function check_item(){
    if [[ $1 = *$2* ]]
    then
        print_color "green" "Item $2 is present on the web page"
    else
        print_color "red" "Item $2 is not present on the web page"
    fi
}


print_color "green" "-------------------- Setup Database Server --------------------"

# Install and configure firewalld
print_color "green" "Installing Firewalld..."
sudo yum install -y firewalld

print_color "green" "Starting Firewalld..."
sudo systemctl start firewalld
sudo systemctl enable firewalld

# Check if firewalld service is running
check_service_status firewalld

# Install and configure mariadb
print_color "green" "Installing Mariadb Server..."
sudo yum install -y mariadb-server

print_color "green" "Starting Mariadb Server..."
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Check if mariadb service is running
check_service_status mariadb

# Configure firewall rules for databases
print_color "green" "Configuring FirewallD rules for Database..."
sudo firewall-cmd --permanent --zone=public --add-port=3306/tcp
sudo firewall-cmd --reload

is_firewalld_rule_configured 3306

# Configuring database
print_color "green" "Setting up database..."
cat > setup-db.sql <<-EOF
    CREATE DATABASE ecomdb;
    CREATE USER 'ecomuser'@'localhost' IDENTIFIED BY 'ecompassword';
    GRANT ALL PRIVILEGES ON *.* TO 'ecomuser'@'locahost';
    FLUSH PRIVILEGES;
EOF

sudo mysql < setup-db.sql

# Loading inventory data into database
print_color "green" "Loading Inventory Data into Database"
cat > db-load-script.sql <<-EOF
USE ecomdb;
CREATE TABLE products (id mediumint(8) unsigned NOT NULL auto_increment,Name varchar(255) default NULL,Price varchar(255) default NULL, ImageUrl varchar(255) default NULL,PRIMARY KEY (id)) AUTO_INCREMENT=1;
INSERT INTO products (Name,Price,ImageUrl) VALUES ("Laptop","100","c-1.png"),("Drone","200","c-2.png"),("VR","300","c-3.png"),("Tablet","50","c-5.png"),("Watch","90","c-6.png"),("Phone Covers","20","c-7.png"),("Phone","80","c-8.png"),("Laptop","150","c-4.png");
EOF

sudo mysql < db-load-script.sql

mysql_db_results=$(sudo mysql -e "use ecomdb; select * from products;")

if [[ $mysql_db_results = *Laptop* ]]
then
    print_color "green" "Inventory data loaded into MySQL"
else
    print_color "red" "Inventory data not loaded into MySQL"
    exit 1
fi

print_color "green" "-------------------- Setup Database Server - Finished --------------------"

print_color "green" "-------------------- Setup Web Server --------------------"

# Install web server packages
print_color "green" "Installing web server packages..."
sudo yum install -y httpd php php-mysql

# Configure firewall rules
print_color "green" "Configuring Firewall rules"
sudo firewall-cmd --permanent --zone=public --add-port=80/tcp
sudo firewall-cmd --reload

is_firewalld_rule_configured 80

# Update index.php
sudo sed -i 's/index.html/index.php/g' /etc/httpd/conf/httpd.conf

# Start httpd service
print_color "green" "Starting httpd service..."
sudo systemctl start httpd
sudo systemctl enable httpd

# Check if httpd service is running
check_service_status httpd

# Download code
print_color "green" "Installing GIT..."
sudo yum install -y git
sudo git clone https://github.com/kodekloudhub/learning-app-ecommerce.git /var/www/html/

print_color "green" "Updating index.php"
sudo sed -i 's/172.20.1.101/localhost/g' /var/www/html/index.php

print_color "green" "-------------------- Setup Web Server - Finished --------------------"

# Test script
web_page=$(curl http://localhost)

for item in Laptop Drone VR Watch Phone
do
    check_item "$web_page" $item
done 