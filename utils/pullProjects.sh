#!/bin/bash

echo "Cloning First Virtualization level: Sample App repository"
if git clone git@github.com:martin059/virtualization-level-1-prototype-app.git; then
    echo "First Virtualization level repository cloned successfully"
else
    echo "Failed to clone First Virtualization level repository"
    echo "Please check your GitHub credentials and ensure that GitHub is reachable"
    exit 1
fi

read -p "Do you want to clone the Second Virtualization level repository? (yes/no): " answer
if [[ ${answer,,} == "yes" || ${answer,,} == "y" ]]; then
    echo "Cloning Second Virtualization level repository"
    git clone git@github.com:martin059/virtualization-level-2-vagrant-setup.git
else
    echo "Skipping cloning of Second Virtualization level repository"
fi