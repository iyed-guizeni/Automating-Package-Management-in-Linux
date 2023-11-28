#!/bin/bash

# Function to install packages using apt
apt_install() {
    sudo apt-get -y install "$1"
}

# Function to remove packages using apt
apt_remove() {
    sudo apt-get remove -y --purge "$1"
    sudo apt autoremove -y
}

# Function to install packages using snap
snap_install() {
    sudo snap install "$1"
}

# Function to remove packages using snap
snap_remove() {
    sudo snap remove "$1"
}

# Function to display help information
help_func() {
    echo -e "Usage: $0 [options]"
    echo "Options:"
    echo "  -i      Install all packages marked 'yes' in the CSV file"
    echo "  -t TYPE Display all packages of the specified TYPE"
    echo "  -r      Remove all packages marked 'no' in the CSV file"
    echo "  -log    Display the installation log"
}

# Function to check if a package is installed
check_packages() {
    find=$(sudo dpkg -l | awk '{print $2}' | grep "^$1$")
    if [[ ! -z $find ]]; then
        echo "FOUND"
    else
        find=$(sudo snap list | awk '{print $1}' | grep "^$1$")
        if [[ ! -z $find ]]; then
            echo "FOUND"
        else
            echo "NOT FOUND"
        fi
    fi
}

# Create or display the installation log
if [[ $1 == '-log' ]] && [[ $# -eq 1 ]]; then
    cat /tmp/inst_log.txt
    exit
else
    sudo echo "Start:" > /tmp/inst_log.txt
    date >> /tmp/inst_log.txt
fi

# Check if the CSV file exists
file_name="inst.csv"
search_result=$(find / -name "$file_name" 2>/dev/null)
if [[ -z $search_result ]]; then
    echo "Error: No file $file_name found in any path."
    exit
fi

# Main script logic
case $1 in
    -i)
        while read line; do
            option=$(echo "$line" | awk -F',' '{print $2}')
            if [[ $option == "yes" ]]; then
                name=$(echo "$line" | awk -F',' '{print $1}')
                package=$(echo "$line" | awk -F',' '{print $5}')
                echo "Package: $package"

                status=$(check_packages "$package")

                if [[ $status == 'FOUND' ]]; then
                    # Package is already installed, update it
                    echo -n "Updating package... "
                    echo -n "Updating package... " >> /tmp/inst_log.txt
                else
                    # Package not installed, install it
                    echo -n "Installing package... "
                    echo -n "Installing package... " >> /tmp/inst_log.txt
                fi

                command=$(echo "$line" | awk -F',' '{print $6}')
                eval "$command" >> /tmp/inst_log.txt 2>> /tmp/inst_log.txt

                status=$(check_packages "$package")

                if [[ $status == 'FOUND' ]]; then
                    echo "DONE"
                else
                    echo "FAILED"
                fi
            fi
        done < inst.csv
        ;;
    -t)
        # Display packages of a specific type
        if [[ $# -eq 2 ]]; then
            type="$2"
            found=false

            while read line; do
                package_type=$(echo "$line" | awk -F',' '{print $3}')
                if [[ $package_type == $type ]]; then
                    found=true
                    name=$(echo "$line" | awk -F',' '{print $1}')
                    info=$(echo "$line" | awk -F',' '{print $4}')
                    echo "$name: $info"
                fi
            done < inst.csv

            if [ "$found" == false ]; then
                echo "Error: The specified package type does not exist in the inst.csv file."
            fi
        else
            echo "Error: Please provide a package type after the -t option."
        fi
        ;;
    -r)
        # Remove packages marked 'no' in the CSV file
        while read line; do
            option=$(echo "$line" | awk -F',' '{print $2}')
            if [[ $option == "no" ]]; then
                name=$(echo "$line" | awk -F',' '{print $1}')
                package=$(echo "$line" | awk -F',' '{print $5}')
                echo "Package: $package"

                status=$(check_packages "$package")

                if [[ $status == 'FOUND' ]]; then
                    # Package is installed, remove it
                    echo -n "Removing package... "
                    echo -n "Removing package... " >> /tmp/inst_log.txt
                else
                    # Package not installed, notify
                    echo -n "Package not found... "
                    echo -n "Package not found... " >> /tmp/inst_log.txt
                fi

                command=$(echo "$line" | awk -F',' '{print $7}')
                eval "$command" >> /tmp/inst_log.txt 2>> /tmp/inst_log.txt

                status=$(check_packages "$package")

                if [[ $status == 'FOUND' ]]; then
                    echo "FAILED"
                else
                    echo "DONE"
                fi
            fi
        done < inst.csv
        ;;
    *)
        help_func
        ;;
esac
