# zsh-vi-search
Adds support for searching the current zsh buffer with vi search mode.
It supports match highlighting and visual mode search.

## Installation

### Antigen
```
  antigen bundle Whenti/zsh-vi-search
```

### Manually
Download [zsh-vi-search.zsh](https://raw.githubusercontent.com/Whenti/zsh-vi-search/master/zsh-vi-search.zsh) and source it somewhere in your `.zshrc` file.

## Usage

+ <kbd>/</kbd> Search forward
+ <kbd>?</kbd> Search backward
+ <kbd>n</kbd> Repeat last search
+ <kbd>N</kbd> Repeat last search in the opposite direction
+ <kbd>*</kbd> Search forward the word under the cursor
+ <kbd>#</kbd> Search backward the word under the cursor

## Configure
This plugin uses `grep` to match patterns, and you can change this command behaviour by tweaking the `ZSH_VI_SEARCH_GREP_PARAMETERS` variable.
```
  # default is (-i) to perform case insensitive searches
  ZSH_VI_SEARCH_GREP_PARAMETERS=(-i --fixed-strings)
```
You can also tweak the `ZSH_VI_SEARCH_PREFIX` variable to automatically add a prefix to your search.
```
  # default is ''
  ZSH_VI_SEARCH_PREFIX='\<'
```

## Credits
This plugin was inspired by Soheil Rashidi's [zsh-vi-search.zsh](https://github.com/soheilpro/zsh-vi-search) plugin.
