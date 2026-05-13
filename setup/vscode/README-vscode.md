# VS Code Multiple Instances Setup

This setup allows you to run two separate VS Code instances with different profiles - one for personal projects and one for work projects. Each instance maintains its own:
- GitHub account login
- Settings Sync
- Extensions
- User preferences
- Workspace settings

## Quick Start

### Using Terminal Scripts

Make the scripts executable:
```bash
chmod +x ~/bin/setup/vscode/vscode-personal.sh
chmod +x ~/bin/setup/vscode/vscode-work.sh
```

Launch personal VS Code:
```bash
~/bin/setup/vscode/vscode-personal.sh
```

Launch work VS Code:
```bash
~/bin/setup/vscode/vscode-work.sh
```

### Using RayCast

The scripts have the meta data for RayCast to pick them up as commands.

To add a command to execute a shell script in Raycast, you have a few options:

## Quick Method: Script Command

1. **Open Raycast Settings** → Go to Extensions → Script Commands
2. **Add Directory**  add the ~/bin/setup/vscode/ directory to the scripts directory.
   - FYI Raycast defaults to looking in: `~/Documents/Raycast/Scripts/`

3. **Make your script Raycast-compatible** by adding metadata at the top (already done but you may want to change it):

```bash
#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Your Script Name
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🚀
# @raycast.packageName Custom Scripts

# Your script content here
echo "Hello from Raycast!"
```

4. **Make it executable**: `chmod +x your-script.sh` (already done)
5. **Refresh** in Raycast (it should auto-detect) or restart Raycast
6. **Add Alias** Set up an alias to make it quick to call. Add the alias 'wcode' to the vscode-work.sh script

## Mode Options

- `compact` - Shows output inline in Raycast
- `fullOutput` - Opens a window with full output
- `silent` - Runs without showing output

## Adding Arguments

If you need to pass parameters:

```bash
# @raycast.argument1 { "type": "text", "placeholder": "Your input" }
echo "You entered: $1"
```

You can also create more sophisticated extensions using the Raycast Extensions API if you need interactive forms or more complex functionality. Want help setting up a specific script?

### Using Automator Apps
*This didn't work for some reason. Switched to RayCast commands.*

Creating Automator apps provides a better user experience with separate dock icons and allows you to open files directly.

#### Create Personal VS Code App

1. Open **Automator** (Applications > Automator)
2. Choose **Application** as the document type
3. Search for "Run Shell Script" in the actions list and double-click it
4. Replace the default script with:
   ```bash
   /Users/bryan/bin/setup/vscode/vscode-personal.sh
   ```
5. Save as **VS Code Personal** in your Applications folder
6. (Optional) Right-click the app in Finder > Get Info > drag a custom icon onto the icon in the top-left

#### Create Work VS Code App

1. Open **Automator** again
2. Choose **Application** as the document type
3. Search for "Run Shell Script" and double-click it
4. Replace the default script with:
   ```bash
   /Users/bryan/bin/setup/vscode/vscode-work.sh
   ```
5. Save as **VS Code Work** in your Applications folder
6. (Optional) Customize with a different icon to distinguish from personal

#### Custom Icons (Optional)

To create distinctive icons for each app:
1. Find or create custom icons (PNG or ICNS format)
2. For each Automator app:
   - Right-click in Finder > Get Info
   - Click the icon in the top-left corner of the Info window
   - Paste your custom icon (⌘V) or drag an image file onto it

## First-Time Setup

### Personal VS Code Instance

1. Launch **VS Code Personal** app (or run `vscode-personal.sh`)
2. Sign in with your **personal GitHub account**
3. Enable **Settings Sync** (⌘⇧P > "Settings Sync: Turn On")
4. Install your preferred extensions
5. Configure your personal settings

### Work VS Code Instance

1. Launch **VS Code Work** app (or run `vscode-work.sh`)
2. Sign in with your **work GitHub account**
3. Enable **Settings Sync** (⌘⇧P > "Settings Sync: Turn On")
4. Install work-required extensions
5. Configure your work settings

## How It Works

Each script launches VS Code with separate directories:

**Personal Profile:**
- User Data: `~/.vscode/`
- Extensions: `~/.vscode/extensions`

or you can change to
- User Data: `~/.vscode-personal/`
- Extensions: `~/.vscode-personal/extensions`

**Work Profile:**
- User Data: `~/.vscode-work/`
- Extensions: `~/.vscode-work/extensions`

These directories are completely independent, allowing each instance to maintain its own:
- Authentication tokens
- Settings sync data
- Installed extensions
- UI state and history
- Workspace configurations

## Usage Tips

### Running Both Instances Simultaneously

You can run both VS Code instances at the same time. They are completely independent and won't interfere with each other.

### Opening Files and Folders

**From Finder:**
- Right-click a file/folder > Open With > choose your preferred VS Code app

**From Terminal:**
```bash
# Open folder in personal VS Code
~/bin/setup/vscode/vscode-personal.sh ~/projects/my-personal-project

# Open folder in work VS Code
~/bin/setup/vscode/vscode-work.sh ~/work/company-project
```

**Set as Default:**
You can set either app as the default for specific file types through Finder (Get Info > Open With > Change All).

### Adding to Dock

Drag the Automator apps from Applications to your Dock for quick access.

### Shell Aliases (Optional)

Add to your `~/.zshrc` or `~/.bashrc`:
```bash
alias code-personal='~/bin/setup/vscode/vscode-personal.sh'
alias code-work='~/bin/setup/vscode/vscode-work.sh'
alias pcode='~/bin/setup/vscode/vscode-personal.sh'
alias wcode='~/bin/setup/vscode/vscode-work.sh'
```

Then use:
```bash
code-personal ~/my-project
code-work ~/work-project
```

## Troubleshooting

### Scripts Don't Execute
Make sure scripts are executable:
```bash
chmod +x ~/bin/setup/vscode/vscode-personal.sh
chmod +x ~/bin/setup/vscode/vscode-work.sh
```

### VS Code Path Issues
If VS Code is installed in a different location, update the path in both scripts:
```bash
# Find VS Code installation
which code

# Or if installed via Homebrew
ls -la $(which code)
```

### Settings Not Syncing
1. Check you're signed in with the correct GitHub account
2. Verify Settings Sync is enabled: ⌘⇧P > "Settings Sync: Show Settings"
3. Each instance syncs independently - changes in one won't affect the other

### Extensions Not Isolated
If extensions appear in both instances, verify the `--extensions-dir` flag is working:
```bash
# Check personal extensions
ls ~/.vscode-personal/extensions

# Check work extensions
ls ~/.vscode-work/extensions
```

## Uninstalling

To remove a profile:

```bash
# Remove personal profile
rm -rf ~/.vscode-personal

# Remove work profile
rm -rf ~/.vscode-work
```

Delete the Automator apps from Applications folder if created.
