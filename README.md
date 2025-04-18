## dotfiles

This documents all things dotfiles related on our MacOS setup.

Will include zsh scripting, and Neovim configuration, and anything else that we can consider dotfiles related

<details>
<summary><h4>Setting up dotfiles repository</h4></summary>

1. **Set up the bare repo in $HOME** (if you haven’t yet):
   ```bash
   git init --bare $HOME/.dotfiles
   alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
   dotfiles config --local status.showUntrackedFiles no
   ```
   Add that alias to your `.zshrc` or `.bashrc` so it sticks.
   
   The above alias is added to ~/.local/bin/dotfiles.sh to help facilitate calling from xargs for instance where aliases dont work
   It also works with p10k status line as well as adds better support for dotfiles status and clean

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

A collection of personal shell scripts in ~/.local/scripts

This list was created by running ```list-scripts```
```
check-scripts.sh     bash     Runs shellcheck on .sh scripts in a given folder to identify issues
compare-folders.sh   bash     Compare files in different folders
data-backup.sh       bash     Backs up folders to SPARSE image bundle in iCloud
disk-useage.sh       dash     Disk usage analyzer with configurable options
dotfiles.sh          bash     Used for adding dotfiles in home directory to git bare repo
gitea-cli.sh         dash     Manage Gitea with start, stop, and log options
info2vim.sh          dash     Launch GNU info for a coreutils command and pipe to Neovim
list-scripts.sh      dash     List all scripts in ~/.local/bin with a description
llamaup.sh           dash     Update all Ollama models
n.sh                 dash     Launch nnn and with auto preview if from tmux
new-script.sh        bash     A script to generate a new shell script template with specified options
preview_cmd.sh       dash     Preview files and directories function executed by nnn
print-ascii.sh       bash     Print the ASCII codes given a range of numbers
print-colors.sh      bash     Display all 256 ANSI colors in the terminal
```
</details>

<details>
<summary><h4>Zsh color quirks</h4></summary>
There is a quirk with setting colors on MacOS (15.4.1) and zsh (5.9 arm64-apple-darwin24.0) 

This is irregardless of the ANSI colors setup in Terminal for Normal and Bright.

For instance if we try to set ```%F{blue}``` and ```%K{blue}``` they will look different, even though there RGB values 
in the Terminal.app settings palette may have been set to identical colors. 

No amount of using the expansions with named, 'blue', or numeric values, 004, 
or trying to reset the colors using %k or %f seems to fix it.

The fix is as thus, instead of using %k to reset the background, we need to use a number that is out of range of Terminals 0-255 colors,
and to use it with an escape sequence.

The trick is to use the [escape sequence](https://apple.stackexchange.com/questions/282911/prevent-mac-terminal-brightening-font-color-with-no-background/446604#446604) ```\e[48;5;256m```

So instead of matching the right trianlge foreground color to the background of previous space character
```zsh
print -P "%K{blue} %k%F{blue}\uE0B0"
```

We do the following:

```zsh
print -P "%K{blue} \e[48;5;256m%F{blue}\uE0B0"
```

Here is [Grok](https://grok.com/share/bGVnYWN5_44f1eb29-e093-436e-8b53-7a0206ae3725) just absolutely struggling with this on 4/17/25

</details>

