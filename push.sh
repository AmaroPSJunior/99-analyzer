#!/bin/bash
# Exit on any error
set -e

# Make sure we are in the workspace root
cd "$(dirname "$0")"

# 1. Initialize git if not already initialized
if [ ! -d .git ]; then
    echo "Initializing git repository..."
    git init -b main
else
    echo "Git repository already initialized."
fi

# 2. Configure Git user identity
git config user.name "Amaro PS Junior"
git config user.email "arcamos.j@gmail.com"

# 3. Handle remote origin and credentials auto-detection
# Remove old origin if it exists
git remote remove origin 2>/dev/null || true

echo "Detecting GitHub credentials..."

REAL_TOKEN=""
REAL_REPO="AmaroPSJunior/99-analyzer" # default fallback based on directory list

# Helper function to check token validity
check_token() {
    local tok="$1"
    if [[ -n "$tok" && "$tok" =~ ^ghp_ ]]; then
        local status_code=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: token $tok" https://api.github.com/user)
        if [ "$status_code" -eq 200 ]; then
            return 0
        fi
    fi
    return 1
}

if check_token "$GITHUB_TOKEN"; then
    echo "Found valid token in GITHUB_TOKEN variable."
    REAL_TOKEN="$GITHUB_TOKEN"
elif check_token "$GITHUB_REPO"; then
    echo "Found valid token in GITHUB_REPO variable (it was likely configured there by mistake!)."
    REAL_TOKEN="$GITHUB_REPO"
else
    echo "❌ Error: Could not find any valid GitHub token starting with 'ghp_'. Please check your Secrets configuration."
    exit 1
fi

# Detect repository
if [[ -n "$GITHUB_REPO" && "$GITHUB_REPO" =~ / && ! "$GITHUB_REPO" =~ ^ghp_ ]]; then
    REAL_REPO="$GITHUB_REPO"
    echo "Using repository specified in GITHUB_REPO: $REAL_REPO"
elif [[ -n "$GITHUB_TOKEN" && "$GITHUB_TOKEN" =~ / && ! "$GITHUB_TOKEN" =~ ^ghp_ ]]; then
    REAL_REPO="$GITHUB_TOKEN"
    echo "Using repository specified in GITHUB_TOKEN: $REAL_REPO"
else
    # Fetch login username dynamically
    GITHUB_USER=$(curl -s -H "Authorization: token $REAL_TOKEN" https://api.github.com/user | grep -oP '"login":\s*"\K[^"]+')
    if [ -n "$GITHUB_USER" ]; then
        REAL_REPO="${GITHUB_USER}/99-analyzer"
    fi
    echo "No valid repository path found in environment variables. Defaulting to: $REAL_REPO"
fi

REMOTE_URL="https://${REAL_TOKEN}@github.com/${REAL_REPO}.git"
echo "Setting remote origin to https://github.com/${REAL_REPO}.git..."
git remote add origin "$REMOTE_URL"

# 4. Stage and commit changes
echo "Staging files..."
git add .

# Check if there are changes to commit
if [ -n "$(git status --porcelain)" ]; then
    echo "Committing changes..."
    git commit -m "Automated commit: Update codebase and fix compilation errors"
else
    echo "No changes to commit."
fi

# 5. Push to GitHub
echo "Pushing to GitHub..."
# Try to push to main. If main fails, fall back to master or detect current branch.
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")
git push -u origin "$CURRENT_BRANCH" --force
echo "Push completed successfully!"
