#!/bin/bash

# Git Setup Script
# This script will configure Git and optionally set up SSH keys

set -e  # Exit on any error

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Git Setup Script${NC}"
echo "==================="
echo

# Check if Git is installed
if ! command -v git &> /dev/null; then
    echo -e "${RED}❌ Git is not installed. Please install Git first:${NC}"
    echo "  - macOS: brew install git"
    echo "  - Ubuntu/Debian: sudo apt install git"
    echo "  - CentOS/RHEL: sudo yum install git"
    echo "  - Windows: Download from https://git-scm.com"
    exit 1
fi

echo -e "${GREEN}✅ Git is installed: $(git --version)${NC}"
echo

# Get user information
echo -e "${BLUE}📝 Setting up Git configuration...${NC}"
while [[ -z "$user_name" ]]; do
    read -p "Enter your full name: " user_name
    if [[ -z "$user_name" ]]; then
        echo -e "${YELLOW}⚠️  Name cannot be empty. Please try again.${NC}"
    fi
done

while [[ -z "$user_email" || ! "$user_email" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; do
    read -p "Enter your email address: " user_email
    if [[ -z "$user_email" ]]; then
        echo -e "${YELLOW}⚠️  Email cannot be empty. Please try again.${NC}"
    elif [[ ! "$user_email" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
        echo -e "${YELLOW}⚠️  Please enter a valid email address.${NC}"
    fi
done
echo

# Configure Git
echo -e "${BLUE}🔧 Configuring Git...${NC}"
git config --global user.name "$user_name"
git config --global user.email "$user_email"
git config --global init.defaultBranch main

# Set some helpful defaults
git config --global pull.rebase false
git config --global push.default simple
git config --global core.autocrlf input  # Better cross-platform line endings

# Set default editor
echo -e "${BLUE}📝 Choose your default Git editor:${NC}"
echo "1) VS Code (code --wait)"
echo "2) Nano"
echo "3) Vim"
echo "4) Skip (use system default)"
read -p "Enter your choice (1-4): " editor_choice

case $editor_choice in
    1)
        if command -v code &> /dev/null; then
            git config --global core.editor "code --wait"
            echo -e "${GREEN}✅ Set VS Code as default editor${NC}"
        else
            echo -e "${YELLOW}⚠️  VS Code not found, skipping editor setup${NC}"
        fi
        ;;
    2)
        git config --global core.editor "nano"
        echo -e "${GREEN}✅ Set Nano as default editor${NC}"
        ;;
    3)
        git config --global core.editor "vim"
        echo -e "${GREEN}✅ Set Vim as default editor${NC}"
        ;;
    4)
        echo -e "${YELLOW}⏭️  Skipping editor setup${NC}"
        ;;
    *)
        echo -e "${YELLOW}⚠️  Invalid choice, skipping editor setup${NC}"
        ;;
esac

echo

# Optional: Set up SSH key
echo -e "${BLUE}🔐 SSH Key Setup (recommended for GitHub/GitLab)${NC}"
read -p "Do you want to generate an SSH key? (y/n): " setup_ssh

if [[ $setup_ssh =~ ^[Yy]$ ]]; then
    ssh_key_path="$HOME/.ssh/id_ed25519"
    
    # Ensure .ssh directory exists
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    
    if [[ -f "$ssh_key_path" ]]; then
        echo -e "${YELLOW}⚠️  SSH key already exists at $ssh_key_path${NC}"
        read -p "Do you want to overwrite it? (y/n): " overwrite_key
        if [[ ! $overwrite_key =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}⏭️  Skipping SSH key generation${NC}"
            setup_ssh="n"
        fi
    fi
    
    if [[ $setup_ssh =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}🔑 Generating SSH key...${NC}"
        ssh-keygen -t ed25519 -C "$user_email" -f "$ssh_key_path" -N ""
        
        # Set proper permissions
        chmod 600 "$ssh_key_path"
        chmod 644 "$ssh_key_path.pub"
        
        echo -e "${BLUE}🔧 Adding SSH key to agent...${NC}"
        # Start ssh-agent if not running
        if ! pgrep -x "ssh-agent" > /dev/null; then
            eval "$(ssh-agent -s)" > /dev/null
        fi
        ssh-add "$ssh_key_path" 2>/dev/null || echo -e "${YELLOW}⚠️  Could not add key to agent (this is usually fine)${NC}"
        
        echo
        echo -e "${GREEN}✅ SSH key generated successfully!${NC}"
        echo -e "${BLUE}📋 Your public key (copy this to GitHub/GitLab):${NC}"
        echo "================================================"
        cat "$ssh_key_path.pub"
        echo "================================================"
        echo
        echo -e "${BLUE}📝 To add this key to GitHub:${NC}"
        echo "  1. Go to https://github.com/settings/keys"
        echo "  2. Click 'New SSH key'"
        echo "  3. Paste the key above"
        echo
        echo -e "${BLUE}📝 To add this key to GitLab:${NC}"
        echo "  1. Go to https://gitlab.com/-/profile/keys"
        echo "  2. Paste the key above"
        echo
    fi
fi

# Display final configuration
echo -e "${GREEN}🎉 Git setup complete!${NC}"
echo "======================"
echo -e "${BLUE}Configuration summary:${NC}"
git config --global --list | grep -E "(user\.|init\.|core\.editor|pull\.|push\.|core\.autocrlf)" | sort
echo

# Optional: Test SSH connection
if [[ $setup_ssh =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}🧪 Want to test SSH connection to GitHub? (y/n)${NC}"
    read -p "Enter choice: " test_ssh
    if [[ $test_ssh =~ ^[Yy]$ ]]; then
        echo "Testing SSH connection to GitHub..."
        ssh -T git@github.com 2>&1 | head -1 || echo -e "${YELLOW}Note: 'Permission denied' is normal if you haven't added the key to GitHub yet${NC}"
    fi
fi

echo
echo -e "${GREEN}🚀 You're all set! Basic Git commands to get started:${NC}"
echo "  git init                    # Initialize a new repository"
echo "  git clone <repo-url>        # Clone a repository"
echo "  git status                  # Check repository status"
echo "  git add <file>              # Stage files"
echo "  git commit -m 'message'     # Commit changes"
echo "  git push                    # Push to remote"
echo "  git pull                    # Pull from remote"
echo
echo -e "${GREEN}Happy coding! 🎉${NC}"