#!/bin/bash

# Function to update remote URL in a given directory
update_remote_in_subdirs() {
    local dir="$1"

    # Check if the directory is a Git repository
    if [ -d "$dir/.git" ]; then
        # Get the current remote URL
        remote_url=$(git -C "$dir" config --get remote.origin.url)

        # Check if the remote URL matches git@github.com:KOMOSYS
        if [[ "$remote_url" =~ git@github.com:KOMOSYS ]]; then
            # Extract the repository name
            repo_name=$(basename "$remote_url")
            
            # Construct the new URL
            new_url="git@gh.deepx.ai:deepx/$repo_name"

            # Change the remote URL
            git -C "$dir" remote set-url origin "$new_url"

            # Perform fetch
            git -C "$dir" fetch
            echo "Updated remote for $dir to $new_url"
        else
            echo "$dir: Current remote URL does not match git@github.com:KOMOSYS."
        fi
    else
        echo "$dir: This directory is not a Git repository."
    fi

    # Check if .gitmodules exists
    if [ -f "$dir/.gitmodules" ]; then
        # Update .gitmodules file
        sed -i 's|git@github.com:KOMOSYS|git@gh.deepx.ai:deepx|g' "$dir/.gitmodules"

        # Update specific repository URL
        sed -i 's|\/CryptoCell-312_Software_bundle_v1.4.git|\/rt_CryptoCell-312_Software_bundle_v1.4.git|g' "$dir/.gitmodules"

        # Sync submodules
        git -C "$dir" submodule sync

        # Update URL for each submodule
        git -C "$dir" submodule foreach 'git remote set-url origin $(git config --get remote.origin.url | sed "s|git@github.com:KOMOSYS|git@gh.deepx.ai:deepx|")'
    fi
}

# If -r option is provided, loop through all subdirectories
if [ "$1" == "-r" ]; then
    for dir in */; do
        update_remote_in_subdirs "$dir"
    done
else
    update_remote_in_subdirs "."
fi
