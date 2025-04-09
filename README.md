## dotfiles

Contains dotfiles found under home folder

<details>
<summary><h4>Setting up a dotfiles Git repo</h4></summary>

1. **Set up the bare repo in $HOME** (if you haven’t yet):
   ```bash
   git init --bare $HOME/.dotfiles
   alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
   dotfiles config --local status.showUntrackedFiles no
   ```
   Add that alias to your `.zshrc` or `.bashrc` so it sticks.
   
   The above alias is added to ~/.local/bin/dotfiles.sh to help facilitate calling from xargs for instance where aliases dont work

2. **Add and commit your dotfiles**:
   ```bash
   dotfiles add .zshrc .vimrc  # or whatever you want to track
   dotfiles commit -m "Initial dotfiles commit"
   ```

3. **Create a repo in Gitea**:
   - Log into your Gitea web UI.
   - Hit "New Repository," name it something like `dotfiles`, keep it private if you want, and create it. Skip initializing with a README since you’ll push to it.

4. **Link your local bare repo to Gitea**:
   - Grab the repo URL from Gitea (e.g., `http://localhost:3000/username/dotfiles.git` or SSH if you’ve got that set up).
   - In your terminal:
     ```bash
     dotfiles remote add origin http://localhost:3000/username/dotfiles.git
     dotfiles push -u origin master
     ```

5. **Push updates whenever**:
   - After tweaking dotfiles, just:
     ```bash
     dotfiles add .zshrc
     dotfiles commit -m "Updated zshrc"
     dotfiles push
     ```

That’s it. Your local Gitea will now mirror your dotfiles repo. Since it’s bare, there’s no working tree cluttering $HOME, and Gitea handles the remote storage and browsing. If you’re on another machine, you can clone it with:
```bash
git clone --bare http://localhost:3000/username/dotfiles.git $HOME/.dotfiles
```
Then set up the alias again and pull.

Works like a charm with Gitea, GitLab, or any git server. Just make sure your Gitea instance is accessible where you need it—local LAN or VPN if you’re syncing across devices.

Also see [here](https://askubuntu.com/a/1316230) 
</details>

<details>
<summary><h4>Custom shell scripts</h4></summary>

A collection of personal shell scripts in ~/.local/bin

This list was created by running ```list-scripts```
```
check-scripts.sh     bash     Runs shellcheck on .sh scripts in a given folder to identify issues
compare-folders.sh   bash     No description available
disk-useage.sh       dash     Disk usage analyzer with configurable options
dotfiles.sh          bash     Used for adding dotfiles in home directory to git bare repo .dotfiles
gitea-backup.sh      bash     gitea-backup.sh: Backs up ~/.gitea-data to SPARSE image bundle in iCloud
gitea-cli.sh         dash     Manage Gitea with start, stop, and log options
info2vim.sh          dash     Launch GNU info for a coreutils command and pipe to Neovim
list-scripts.sh      dash     List all scripts in ~/.local/bin with a description
llamaup.sh           dash     Update all Ollama models
n.sh                 dash     Launch nnn and with auto preview if from tmux
new-script.sh        bash     A script to generate a new shell script template with specified options
preview_cmd.sh       dash     Preview files and directories function executed by nnn
print-ascii.sh       bash     No description available
print-colors.sh      bash     Display all 256 ANSI colors in the terminal
```
</details>
