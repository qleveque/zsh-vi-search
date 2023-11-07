# zsh-vi-search

Adds support for vi search directly in the zsh buffer.

## Installation

### Antigen
With [antigen](https://github.com/zsh-users/antigen), add the following line to your `.zshrc`.
```
  antigen bundle qleveque/zsh-vi-search
```

### Manually
Download [zsh-vi-search.zsh](https://raw.githubusercontent.com/qleveque/zsh-vi-search/master/zsh-vi-search.zsh) and source it in your `.zshrc`.

## Usage

In zsh vi mode (`bindkey -v`) for both `vicmd` and `visual` modes:

+ <kbd>/</kbd> Forward search
+ <kbd>?</kbd> Backward search
+ <kbd>*</kbd> Forward search of the word under the cursor
+ <kbd>#</kbd> Backward search of the word under the cursor
+ <kbd>n</kbd> Repeat last search
+ <kbd>N</kbd> Repeat last search in the opposite direction

## Configure
- `ZSH_VI_SEARCH_GREP_PARAMETERS` (default `(-i)`): the parameters of the `grep` command used to match search patterns.
- `ZSH_VI_SEARCH_PREFIX` (default `''`): automatically add this prefix to your search.
- `ZSH_VI_SEARCH_NOHL` (default is unset): set it to any value to disable search highlighting.

```
# Example
ZSH_VI_SEARCH_GREP_PARAMETERS=(-i --fixed-strings)
ZSH_VI_SEARCH_PREFIX='\<'
```


## Conflicts
In case search highlighting is enabled, this plugin should be loaded after [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting).

## Credits
This plugin was inspired by Soheil Rashidi's [zsh-vi-search.zsh](https://github.com/soheilpro/zsh-vi-search) plugin.
