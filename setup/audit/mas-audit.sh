#!/bin/bash

# Path to the mas.sh file
MAS_FILE="/Users/bryan/bin/setup/appstore/mas.sh"

# Get the list of installed apps from mas
INSTALLED_APPS=$(mas list | awk '{print $1}')
INSTALLED_APPS_NAME=$(mas list | awk '{print $2}')

# Read the mas.sh file and filter out comments, then extract the app IDs
REQUIRED_APPS=$(grep -v '^#' appstore/mas.sh | grep 'mas install' | awk '{print $3}')


echo -e "\napps not installed that are in $MAS_FILE\n"

# Compare the installed apps with the required apps
for app in $REQUIRED_APPS; {
    if ! echo "$INSTALLED_APPS" | grep -q "$app"; then
        echo "App with ID $app is not installed."
    fi
}

echo -e "\nINSTALLED APPS missing from $MAS_FILE\n"

# Compare the installed apps with the required apps
for app in $INSTALLED_APPS; {
    count=$((count + 1))
    if ! echo "$REQUIRED_APPS" | grep -q "$app"; then
        echo "App with ID $app is not in file. name: $(echo "$INSTALLED_APPS_NAME" | sed -n "${count}p")"
    fi
}



