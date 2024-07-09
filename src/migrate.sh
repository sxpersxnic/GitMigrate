#!/usr/bin/env bash

set -e

# Constants
MIGRATION_WORKDIR="./repositoryPool"
GITHUB_TOKEN="" # Add Github access token
GITHUB_USERNAME="" # Add Github username
FROM="http://git.bbcag.ch/inf-bl/zh/2023" 
GITLAB_SSH="ssh://git@git.bbcag.ch:2222/inf-bl/zh/2023"
TO="https://github.com/${GITHUB_USERNAME}"
REPOS=(
    ""
) # Add paths to repositories

# Ensure GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo "GitHub CLI not found. Installing..."
    sudo apt-get update
    sudo apt-get install -y gh
fi

# Authenticate with GitHub CLI
echo "${GITHUB_TOKEN}" | gh auth login --with-token

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
    if gh repo view "${REPO_NAME}" &> /dev/null; then
        echo "GitHub repository ${REPO_NAME} already exists."
        read -p "Do you want to overwrite the existing repository? (y/n): " choice
        if [ "$choice" = "y" ]; then
            gh repo delete "${REPO_NAME}" --confirm
            gh repo create "${REPO_NAME}" --public
        else
            echo "Skipping repository: ${REPO_NAME}"
            cd ..
            continue
        fi
    else
        gh repo create "${REPO_NAME}" --public
    fi

    # Check and remove existing remotes if present
    if git remote | grep origin &> /dev/null; then
        git remote remove origin
    fi
    if git remote | grep github &> /dev/null; then
        git remote remove github
    fi

    # Add GitHub remote with token and push to GitHub
    git remote add github "https://${GITHUB_USERNAME}:${GITHUB_TOKEN}@github.com/${GITHUB_USERNAME}/${REPO_NAME}.git"
    git push github main --force

    # Go back to the working directory
    cd ..

    echo "Transferred repository: ${REPO_NAME}"
done

echo "All repositories have been transferred."
