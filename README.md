## Installation

### Alacritty

- [Alacritty](https://github.com/alacritty/alacritty)

  ```sh
  brew install alacritty
  ```

- [Themes](https://github.com/alacritty/alacritty-theme)

  ```sh
  mkdir -p ~/.config/alacritty/themes
  git clone --depth=1 https://github.com/alacritty/alacritty-theme ~/.config/alacritty/themes
  ```

- [Nerd Font](https://github.com/ryanoasis/nerd-fonts)

  ```sh
  brew install font-hack-nerd-font
  brew install font-Inconsolata-Nerd-Font 
  brew install font-iosevka-nerd-font
  brew install font-iosevka-term-slab-nerd-font
  brew install font-tinos-nerd-font
  brew install font-profont-nerd-font
  brew install font-m+-nerd-font
  brew install font-go-mono-nerd-font
  brew install font-Anonymice-nerd-font
  ```

  > NOTE: All Nerd fonts can be previewed on this page. Install as needed: <https://www.nerdfonts.com/font-downloads>

### Tmux

- [Tmux](https://github.com/tmux/tmux)

  ```sh
  brew install tmux
  ```

- switchaudio-osx

  ```sh
  # For showing audio volume status in the tmux status bar.
  brew install switchaudio-osx
  ```

### Zsh

- [Zsh](https://github.com/ohmyzsh/ohmyzsh)

  ```sh
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  ```

- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)

  ```sh
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  ```

- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)

  ```sh
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
  ```

- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)

  ```sh
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.powerlevel10k
  ```

- [eza](https://github.com/eza-community/eza)

  ```sh
  # A modern replacement for ls.
  brew install eza
  ```

### Neovim

- [Neovim](https://github.com/neovim/neovim)

  ```sh
  brew install neovim
  ```

## Install dotfiles

```sh
# Clone windvalley/dotfiles
git clone https://git@github.com:windvalley/dotfiles.git ~/.dotfiles

# Tmux
killall tmux
mv ~/.tmux ~/.tmux.bak
rm -rf /tmp/tmux*
ln -sf ~/.dotfiles/tmux/tmux.conf ~/.tmux.conf

# Alacritty
ln -sf ~/.dotfiles/alacritty/alacritty.toml ~/.config/alacritty/alacritty.toml
cp ~/.dotfiles/alacritty/alacritty_private.toml ~/.config/alacritty/alacritty_private.toml

# Zsh
ln -sf ~/.dotfiles/zsh/zshrc ~/.zshrc
ln -sf ~/.dotfiles/zsh/p10k.zsh ~/.p10k.zsh
cp ~/.dotfiles/zsh/zshrc_private ~/.zshrc_private
exec zsh

# Neovim(LazyVim)
mv ~/.config/nvim ~/.config/nvim.bak
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.cache/nvim
ln -sf ~/.dotfiles/nvim ~/.config/nvim
cat > ~/.dotfiles/nvim/lua/plugins/switch_colorscheme.lua <<EOF
return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight"
    },
  },
}
EOF
```

## Usage

### Alacritty

#### Keyboard Shortcuts

| Shortcut               | Action                                                   |
| ---------------------- | -------------------------------------------------------- |
| `Command` `h`          | Hide the current Alacritty terminal                      |
| `Command` `m`          | Minimize the current Alacritty to the Dock               |
| `Command` `q`/`w`      | Quit Alacritty                                           |
| `Command` `n`          | Spawn new instance of Alacritty                          |
| `Command` `f`/`b`      | Search forward or backward                               |
| `Command` `+`/`-`/`0`  | Increase/Decrease/Reset font size                        |
| `Ctrl` `Command` `f`   | Toggle full screen                                       |
| `Ctrl` `l`             | Clear warning/error messages of Alacritty in status line |
| `Command` `Option` `h` | Hiding all windows other than the current Alacritty      |



### Tmux

#### Prefix Key

Prefix Key: `Ctrl a`

All the following shortcuts keys must first press the prefix key.

> Note that after pressing the prefix key, you need to release the prefix key first,
> and then press other specific shortcut keys.

#### Key Bindings

##### Common

- `?` : List key bindings
- `r` : Reload `~/.tmux.conf`
- `e` : Edit `~/.tmux.conf`
- `K` : View help documents of the object in `~/.tmux.conf`
- `d` : Detach the current client


##### Session
- `s` : Choose a session from a list
- `Option/Alt` `f` : Search session
- `Ctrl` `c` : Create new session
- `$` : Rename the current session
- `b` : Toggle status line of the current session

##### Window

- `c` : Create new window
- `,` : Rename current window
- `.` : Move current window
- `n` : Select the next window
- `p` : Select the previous window
- `0-9`: Select window 0-9
- `&` : Kill current window
- `w` : Choose a window from a list
- `f` : Search window
- `i` : Display window information

<details>
<summary>Show more ...</summary>

##### Pane

- `%` : Split window horizontally
- `"` : Split window vertically
- `<Space>` : Select next layout
- `Ctrl` `E` : Spread panes out evenly
- `x` : Kill the active pane
- `z` : Zoom the active pane
- `{` / `<` : Swap the active pane with the pane above
- `}` / `>` : Swap the active pane with the pane below
- `q` : Display pane numbers(it will also display a letter if the number gather than 10),
  then press the specified number(or letter) to select it.
- `t` : Show a clock in current pane
- `!` : Break pane to a new window
- `;` : Move to the previously active pane
- `k` : Select the pane above the active pane
- `j` : Select the pane below the active pane
- `h` : Select the pane to the left of the active pane
- `l` : Select the pane to the right of the active pane
- `o` : Select the next pane
- `Ctrl` `o` : Rotate through the panes
- `Option/Alt` `o` : Rotate through the panes in reverse
- `m` : Toggle the marked pane
- `K` : Resize the pane up
- `J` : Resize the pane down
- `H` : Resize the pane left
- `L` : Resize the pane right
- `Ctrl` `l` : Clear all the messages(include history messages) in the active pane
- `Ctrl` `b` : Toggle pane name of the current window's all panes
- `Ctrl` `t` : Create a new pane that is 16% of the size of the current pane and below the current pane

##### Copy Mode

- `[` : Enter copy mode
- `]` : Paste the most recent paste buffer

**NOTE**: The followings is the operations after entered copy mode, **no need** to press the Prefix Key first.

- `q` : Exit from copy mode
- `hjhl` : Movements
- `v` : Text select
- `V` : Text line select
- `Ctrl` `v` : Text block select
- `enter`: Copy the selected text
- `esc` : Escape from text selected
- `/` : Search down
- `?` : Search up

Enabled `vi-mode`, many vi shortcuts can be used in this scenario.

##### Sync Mode

- `Ctrl` `y` : Toggle sync mode

</details>

#### Tmux Plugins

<details>
<summary>Show more ...</summary>

##### [tmux-plugins/tpm](https://github.com/tmux-plugins/tpm)

Tmux Plugin Manager.

- `I` : Install new plugins
- `U` : Update all plugins
- `u` : Uninstall plugins that not in `~/.tmux.conf`

##### [tmux-plugins/tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect) 

This plugin saves all the little details from your tmux environment so it can be completely restored after a system restart (or when you feel like it).

- `Ctrl` `s` : Save sessions
- `Ctrl` `r` : Restore sessions from local backup

##### [tmux-plugins/tmux-copycat](https://github.com/tmux-plugins/tmux-copycat) 

###### Search

- `/` : Regex search (strings work too)

  Example search entries:

  - `foo` : Searches for string foo
  - `[0-9]+` : Regex search for numbers

###### Predefined searches

- `Ctrl` `f` : Simple file search
- `Ctrl` `g` : Jumping over git status files (best used after git status command: `git status -sb`)
- `Ctrl` `h` : Jumping over SHA-1/SHA-256 hashes (best used after git log command)
- `Ctrl` `u` : URL search (http, ftp and git urls)
- `Ctrl` `d` : Number search (mnemonic d, as digit)
- `Ctrl` `i` : IP address search
- `S` : Jumping over string surrounded by `""`

These start "copycat mode" and jump to first match.

###### Copycat mode bindings

These are enabled when you search with copycat:

- `n` : Jumps to the next match
- `N` : Jumps to the previous match
- `enter` : Copy a highlighted match

##### [tmux-plugins/tmux-yank](https://github.com/tmux-plugins/tmux-yank)

- Tmux Normal Mode
  - `y` : Copies text from the command line to the clipboard.
  - `Y` : Copy the current pane's current working directory to the clipboard.
- Tmux Copy Mode
  - `y` : Copy selection to system clipboard.
  - `Y` : Equivalent to copying a selection, and pasting it to the command line.

##### [tmux-plugins/tmux-open](https://github.com/tmux-plugins/tmux-open) 

Plugin for opening highlighted selection directly from Tmux copy mode.

In Tmux Copy Mode:

- `o` : Open a highlighted selection with the system default program. open for OS X or xdg-open for Linux.
- `Ctrl` `o` : Open a highlighted selection with the $EDITOR
- `S` : Search the highlighted selection directly by Google
- `B` : Search the highlighted selection directly by Bing

</details>

### Zsh

#### Reload `~/.zshrc`

`omz reload` or `exec zsh` or `source ~/.zshrc`

#### [fzf](https://github.com/junegunn/fzf)

- `$ ff`

  Search file by `fzf` and then open it by `vim`.

- `Ctrl` `t`

  List all files and dirs of the current dir, then select one and `enter`,
  it will paste the selected file name to the command line.

- `Option`/`Alt` `c`

  List all dirs of the current dir, then select one and `enter`,
  it will switch to the selected dir.

- `Ctrl` `r`

  List history commands, then input keywords and select the specific one,
  and `enter`, it will paste the selected command to the command line.

- `Ctrl` `k`/`j`

  Select up or down in file/dir list or history command list.

- `Ctrl` `p`/`n`

  The same as `Ctrl` `k`/`j`.

- `Ctrl` `c` / `Ctrl` `g` / `esc`

  Quit from file/dir list or history command list.

#### Custom Commands

- Change colorscheme of Alacritty and Neovim

  ```bash
  $ cs

  Usage: colorscheme <tokyonight|tokyonight|gruvbox|dracula|catppuccin>
  ```

- Change Font of Alacritty

  ```bash
  $ ft

  Usage: font <Hack|Inconsolata|Iosevka|ProFontIIx|ProFontWindows|M+1Code|M+CodeLat50|GoMono|AnonymicePro>
  ```

- Change Font Size of Alacritty

  ```bash
  $ fs

  Usage: font-size <1-200>
  ```

- Change opacity of Alacritty

  ```bash
  $ o

  Usage: opacity <0.0~1.0>
  ```

- Adjust the system volume

  ```sh
  $ vol

  Usage of audio-volume:
    digit             Set volume value, 1~100
    -p, --print       Print all audio devices
    -n, --next        Switch to the next audio device
    -i device_id      Switch to the given audio device
  ```

- Batch ssh remote hosts in multi-tmux-panes

  ```sh
  $ s

  Usage:
      ssh-sessions /yourpath/tmux_window[.extension]

  Content format of /yourpath/tmux_window[.extension]:
      node1.example.com
      node2.example.com
      node3.exmaple.com
      ...

  Note:
      Make sure the hosts in /yourpath/tmux_window.extension
      can login without password by ssh public key authentication.

  Examples:
      $ ssh-sessions ~/.xxxhosts.ssh

      or

      $ ssh-sessions ~/.xxxhosts

      or

      $ ssh-sessions ~/xxxhosts
  ```

#### OhMyZsh Plugins

<details>
<summary>Show more ...</summary>

##### vi-mode

> ~/.oh-my-zsh/plugins/web-search/README.md

- Enter `Normal Mode`  
  First of all, use <kbd>esc</kbd> or `Ctrl [` to enter `Normal mode`.

- History
  - `ctrl` `p` : Previous command in history
  - `ctrl` `n` : Next command in history
  - `/` : Search backward in history
  - `n` : Repeat the last `/`

- Vim edition
  - `vv` : Edit current command line in Vim

- Movement
  - `$` : To the end of the line
  - `^` : To the first non-blank character of the line
  - `0` : To the first character of the line
  - `w` : [count] words forward
  - `W` : [count] WORDS forward
  - `e` : Forward to the end of word [count] inclusive
  - `E` : Forward to the end of WORD [count] inclusive
  - `b` : [count] words backward
  - `B` : [count] WORDS backward
  - `t{char}` : Till before [count]'th occurrence of {char} to the right
  - `T{char}` : Till before [count]'th occurrence of {char} to the left
  - `f{char}` : To [count]'th occurrence of {char} to the right
  - `F{char}` : To [count]'th occurrence of {char} to the left
  - `;` : Repeat latest f, t, F or T [count] times
  - `,` : Repeat latest f, t, F or T in opposite direction

- Insertion
  - `i` : Insert text before the cursor
  - `I` : Insert text before the first character in the line
  - `a` : Append text after the cursor
  - `A` : Append text at the end of the line
  - `o` : Insert new command line below the current one
  - `O` : Insert new command line above the current one

- Delete and Insert
  - `ctrl-h` : While in _Insert mode_: delete character before the cursor
  - `ctrl-w` : While in _Insert mode_: delete word before the cursor
  - `d{motion}` : Delete text that {motion} moves over
  - `dd` : Delete line
  - `D` : Delete characters under the cursor until the end of the line
  - `c{motion}` : Delete {motion} text and start insert
  - `cc` : Delete line and start insert
  - `C` : Delete to the end of the line and start insert
  - `r{char}` : Replace the character under the cursor with {char}
  - `R` : Enter replace mode: Each character replaces existing one
  - `x` : Delete `count` characters under and after the cursor
  - `X` : Delete `count` characters before the cursor

##### git

> ~/.oh-my-zsh/plugins/git/README.md

- `gst` : git status
- `gsh` : git show
- `ga` : git add
- `gc` : git commit -v
- `gp` : git push
- `gpf` : git push -f
- `glo` : git log --oneline --decorate
- `glog` : git log --oneline --decorate --graph
- `gl` : git pull

##### gitignore

> ~/.oh-my-zsh/plugins/gitignore/README.md

- `gi list`: List all the currently supported gitignore.io templates.
- `gi [TEMPLATENAME]`: Show git-ignore output on the command line, e.g. `gi java` to exclude class and package files.
- `gi [TEMPLATENAME] >> .gitignore`: Appending programming language settings to your projects .gitignore.

##### web-search

> ~/.oh-my-zsh/plugins/web-search/README.md

You can use the `web-search` plugin in these two forms:

- `web_search <context> <term> [more terms if you want]`
- `<context> <term> [more terms if you want]`

For example, these two are equivalent:

```sh
$ web_search google oh-my-zsh
$ google oh-my-zsh
```

Available search contexts are:

| Context               | URL                                      |
| --------------------- | ---------------------------------------- |
| `bing`                | `https://www.bing.com/search?q=`         |
| `google`              | `https://www.google.com/search?q=`       |
| `yahoo`               | `https://search.yahoo.com/search?p=`     |
| `ddg` or `duckduckgo` | `https://www.duckduckgo.com/?q=`         |
| `sp` or `startpage`   | `https://www.startpage.com/do/search?q=` |
| `yandex`              | `https://yandex.ru/yandsearch?text=`     |
| `github`              | `https://github.com/search?q=`           |
| `baidu`               | `https://www.baidu.com/s?wd=`            |
| `ecosia`              | `https://www.ecosia.org/search?q=`       |
| `goodreads`           | `https://www.goodreads.com/search?q=`    |
| `qwant`               | `https://www.qwant.com/?q=`              |
| `givero`              | `https://www.givero.com/search?q=`       |
| `stackoverflow`       | `https://stackoverflow.com/search?q=`    |
| `wolframalpha`        | `https://wolframalpha.com/input?i=`      |
| `archive`             | `https://web.archive.org/web/*/`         |
| `scholar`             | `https://scholar.google.com/scholar?q=`  |

##### colorize

> ~/.oh-my-zsh/plugins/colorize/README.md

- `ccat <file> [files]`: colorize the contents of the file (or files, if more than one are provided).
  If no files are passed it will colorize the standard input.

- `cless [less-options] <file> [files]`: colorize the contents of the file (or files, if more than one are provided) and open less.
  If no files are passed it will colorize the standard input.
  The LESSOPEN and LESSCLOSE will be overwritten for this to work, but only in a local scope.

##### sudo

> ~/.oh-my-zsh/plugins/sudo/README.md

Easily prefix your current or previous commands with `sudo` by pressing <kbd>esc</kbd> twice.

##### copyfile

> ~/.oh-my-zsh/plugins/copyfile/README.md

- `copyfile <filename>` : Puts the contents of a file in your system clipboard so you can paste it anywhere.

##### copydir

> ~/.oh-my-zsh/plugins/copydir/README.md

- `copydir` : Copy the $PWD to the system clipboard.

##### aliases

> ~/.oh-my-zsh/plugins/aliases/README.md

With lots of 3rd-party amazing aliases installed, this plugin helps list the shortcuts
that are currently available based on the plugins you have enabled.

- `acs` : Group all alias
- `acs <keyword>` : Quickly filter alias & highlight

</details>

### Neovim

#### Custom keybindings

- Cursor movement in Insert Mode
  - `Ctrl` `k` : Move cursor up
  - `Ctrl` `j` : Move cursor down
  - `Ctrl` `h` : Move cursor left
  - `Ctrl` `l` : Move cursor right
  - `Ctrl` `e` : Move cursor to the end of the line
  - `Ctrl` `a` : Move cursor to the start of the line

- Shortcuts for Codeium
  - `Tab` : Accept Codeium suggestion
  - `Ctrl` `f` : Next Codeium suggestion
  - `Ctrl` `b` : Previous Codeium suggestion
  - `Ctrl` `c` : Cancel Codeium suggestion
  - `Ctrl` `t` : Trigger Codeium suggestion

#### Default keybindings 

<https://www.lazyvim.org/keymaps>


#### Please read LazyVim Documentation

<https://www.lazyvim.org>
