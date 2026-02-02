# dotfiles

## Setting up

```shell
curl -fsSL https://raw.githubusercontent.com/nownabe/dotfiles/main/setup.sh | bash
```

### Chezmoi (deprecated)

```shell
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply nownabe
```

### Manual Installation

Install these tools:

- [UbuntuSans Nerd Font](https://www.nerdfonts.com/font-downloadsk) (`UbuntuSansMono Nerd Font Mono`)
- [Neovim](https://github.com/neovim/neovim)

### Secrets

Set secrets in `.zsh.d/secrets.zsh`.

| name                | description                                                                  |
| ------------------- | ---------------------------------------------------------------------------- |
| `OPENAI_API_KEY`    | [OpenAI API Key](https://platform.openai.com/settings/organization/api-keys) |
| `ANTHROPIC_API_KEY` | [Anthropic API Key](https://console.anthropic.com/settings/keys)             |

### Windows (WSL)

- Delete `Ctrl + v` keymap. Instead, use `Ctrl + Shift + v` to paste.

## Neovim

### Prerequisites

```shell
luarocks install tiktoken_core # for CopilotC-Nvim/CopilotChat.nvim
```

### Key Mappings

#### General Mappings

| Key | Action | Command |
| --- | ------ | ------- |

#### Buffers

| Key           | Action                    | Command |
| ------------- | ------------------------- | ------- |
| `Leader + bl` | Go to the previous buffer |         |
| `Leader + bh` | Go to the next buffer     |         |
| `Leader + bc` | Close the current buffer  |         |

#### Neo-Tree

| Key          | Action         | Command |
| ------------ | -------------- | ------- |
| `Leader + e` | Neotree toggle |         |
| `Leader + o` | Neotree focus  |         |

#### LSP Mappings

| Key           | Action          | Command |
| ------------- | --------------- | ------- |
| `Leader + lS` | Symbols Outline |         |

#### GitHub Copilot Chat

| Key           | Action                               | Command |
| ------------- | ------------------------------------ | ------- |
| `Leader + ce` | Explain the selected code            |         |
| `Leader + cr` | Review the selected code             |         |
| `Leader + cf` | Fix the code                         |         |
| `Leader + co` | Optimize the selected code           |         |
| `Leader + cd` | Generate docs for the selected code  |         |
| `Leader + ct` | Generate tests for the selected code |         |

In chat:

| Key        | Action                    |
| ---------- | ------------------------- |
| `q`        | Close the chat window     |
| `Ctrl + s` | Submit the current prompt |
