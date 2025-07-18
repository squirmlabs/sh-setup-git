To use this script:

Make it executable:

```bash
chmod +x setup-git.sh
```

Run it:

```bash
./setup-git.sh
```


The script will:

✅ Check if Git is installed
📝 Prompt for your name and email
🔧 Configure Git globally
📝 Let you choose a default editor
🔐 Optionally generate SSH keys
🧪 Optionally test GitHub SSH connection
📋 Display your public key for easy copying to GitHub/GitLab

Features:

Interactive prompts for all configuration
Error handling and validation
Safe SSH key generation (won't overwrite without permission)
Clear instructions for adding keys to GitHub/GitLab
Summary of configuration at the end

The script handles different operating systems and provides helpful next steps. Just run it once and you'll have a fully configured Git setup!

Issues Found & Fixed:

1. Input Validation: Added validation for empty names and invalid email formats
2. SSH Directory: Added mkdir -p ~/.ssh and proper permission setting (chmod 700)
3. File Permissions: Added proper SSH key permissions (chmod 600 for private, chmod 644 for public)
4. SSH Agent: Added check if ssh-agent is already running before starting it
5. Error Handling: Added better error handling for ssh-add command
6. Visual Improvements: Added color coding for better readability
7. Additional Git Config: Added useful defaults:

pull.rebase false (merge strategy)
push.default simple (safer pushing)
core.autocrlf input (better line ending handling)

SSH Test: Improved SSH connection test with better error handling

Key Safety Features:

✅ Won't overwrite existing SSH keys without confirmation
✅ Validates email format before proceeding
✅ Handles missing directories and permissions
✅ Graceful error handling throughout
✅ Clear color-coded output for better UX
