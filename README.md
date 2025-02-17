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

- iStats

  ```sh
  # For showing cpu temperature and fan speed in the tmux status bar.
  sudo gem install iStats
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
