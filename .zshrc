source $HOME/.zplug/init.zsh

zplug 'zplug/zplug', hook-build: 'zplug --self-manage'
zplug 'nownabe/zshrc'
zplug 'mafredri/zsh-async'
zplug 'sindresorhus/pure', use:pure.zsh, as:theme

if ! zplug check --verbose; then
  zplug install
fi

zplug load --verbose