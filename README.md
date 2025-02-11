# dotfiles

## Setting up

### General

Install favorites:

* byobu (`sudo apt install byobu`)
* [Neovim](https://github.com/neovim/neovim)
* [UbuntuSans Nerd Font](https://www.nerdfonts.com/font-downloadsk) (`UbuntuSansMono Nerd Font Mono`)

Set secrets in `.zsh.d/secrets.zsh`.

| name | description |
| ---- | ----------- |
| `OPENAI_API_KEY` | [OpenAI API Key](https://platform.openai.com/settings/organization/api-keys) |
| `ANTHROPIC_API_KEY` | [Anthropic API Key](https://console.anthropic.com/settings/keys) |

### Windows (WSL)

* Delete `Ctrl + v` keymap. Instead, use `Ctrl + Shift + v` to paste.


## Neovim

### General Mappings

| Key | Action | Command |
| --- | ------ | ------- | 

### Buffers

| Key | Action | Command |
| --- | ------ | ------- | 
| `Leader + bl` | Go to the previous buffer | |
| `Leader + bh` | Go to the next buffer | |
| `Leader + bc` | Close the current buffer | |

### Neo-Tree

| Key | Action | Command |
| --- | ------ | ------- | 
| `Leader + e` | Neotree toggle | |
| `Leader + o` | Neotree focus | |

### LSP Mappings

| Key | Action | Command |
| --- | ------ | ------- | 
| `Leader + lS` | Symbols Outline | |
