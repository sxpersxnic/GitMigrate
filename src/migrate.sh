#!/usr/bin/env bash

set -e

# Constants
MIGRATION_WORKDIR="../repositoryPool"
GITHUB_USERNAME="sxpersxnic"
FROM="http://git.bbcag.ch/inf-bl/zh/2023"
GITLAB_SSH="ssh://git@git.bbcag.ch:2222/inf-bl/zh/2023"
TO="https://github.com/${GITHUB_USERNAME}"
REPOS=(
    "team-c/zkampm/test"
)

# Ensure GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo "GitHub CLI not found. Installing..."
    sudo apt-get update
    sudo apt-get install -y gh
fi

# Create working directory
mkdir -p "${MIGRATION_WORKDIR}"
cd "${MIGRATION_WORKDIR}"

# Loop through each repository
for REPO in "${REPOS[@]}"; do
    REPO_NAME=$(basename "${REPO}")
    echo "Transferring repository: ${REPO_NAME}"

    # Clone GitLab repository
    git clone "${GITLAB_SSH}/${REPO}.git"
    cd "${REPO_NAME}"

    # Check for existing GitHub repository
    if gh repo view "${GITHUB_USERNAME}/${REPO_NAME}" &> /dev/null; then
        echo "GitHub repository ${GITHUB_USERNAME}/${REPO_NAME} already exists."
        read -p "Do you want to overwrite the existing repository? (y/n): " choice
        if [ "$choice" = "y" ]; then
            gh repo delete "${REPO_NAME}" --confirm
            gh repo create "${REPO_NAME}" --public --source=.
        else
            echo "Skipping repository: ${REPO_NAME}"
            cd ..
            continue
        fi
    else
        gh repo create "${REPO_NAME}" --public --source=.
    fi

    # Check and remove existing GitHub remote if present
    if git remote get-url github &> /dev/null; then
        git remote remove github
    fi

    # Add GitHub remote and push to GitHub
    git remote add github "https://github.com/${GITHUB_USERNAME}/${REPO_NAME}.git"
    git push github main

    # Go back to the working directory
    cd ..

    echo "Transferred repository: ${REPO_NAME}"
done

echo "All repositories have been transferred."
