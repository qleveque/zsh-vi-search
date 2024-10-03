#!/usr/bin/zsh
export ZSH_VI_SEARCH_DIRECTION
export ZSH_VI_SEARCH_STRING
export ZSH_VI_SEARCH_BUFFER
export ZSH_VI_SEARCH_KEYMAP
export ZSH_VI_SEARCH_MINIBUFFER
autoload -U read-from-minibuffer

# Custom commands
zvs-visual-mode() { ZSH_VI_SEARCH_KEYMAP=visual && zle .visual-mode}
zvs-zle-keymap-select() { ZSH_VI_SEARCH_KEYMAP=$KEYMAP }
zvs-deactivate-region() { ZSH_VI_SEARCH_KEYMAP=vicmd && zle .deactivate-region}
zvs-zle-line-pre-redraw() { on-zsh-vi-search-minibuffer-edited }
for widget in visual-mode zle-keymap-select deactivate-region zle-line-pre-redraw; do
  zle -N $widget zvs-$widget
done

# Highlight functions
zsh-vi-search-highlight() {
  [[ -v ZSH_VI_SEARCH_NOHL ]] && return
  region_highlight+=("$1 $2 fg=8,standout, memo=zsh-vi-search-highlighting")
}
zsh-vi-search-highlight-clear() {
  [[ -v ZSH_VI_SEARCH_NOHL ]] && return
  region_highlight=()
}

# Search for matches
zsh-vi-search-indices() {
  local positions="" grep_parameters=(-i)
  [[ -v ZSH_VI_SEARCH_GREP_PARAMETERS ]] && grep_parameters=($ZSH_VI_SEARCH_GREP_PARAMETERS)
  while IFS= read -r line; do
    [[ -z $line ]] && return
    local start="${line%%:*}" length="${#line#*:}"
    positions+="$start $(( start+length ))\n"
  done <<< $(echo "$ZSH_VI_SEARCH_BUFFER" | grep -bo ${(@)grep_parameters} -- "$1" 2> /dev/null)
  echo $positions\n
}

# On minibuffer edited callback
on-zsh-vi-search-minibuffer-edited() {
  (( ZSH_VI_SEARCH_MINIBUFFER != 1 )) && return
  zsh-vi-search-highlight-clear
  local positions=("${(@f)$(zsh-vi-search-indices "$BUFFER")}")
  for position in $positions; do
    local p=(${=position}) start=${p[1]} end=${p[2]} to_remove=$(( ${#ZSH_VI_SEARCH_BUFFER}+2 ))
    zsh-vi-search-highlight $(( start-to_remove )) $(( end-to_remove ))
  done
}

# Close minibuffer
close-minibuffer() { zle kill-whole-line && zle accept-line }
zle -N close-minibuffer

# Find the position of the word under the cursor
zsh-vi-search-cursor-index() {
  local prev next
  while IFS= read -r line; do
    (( line < CURSOR)) && prev=$line && continue
    (( line == CURSOR )) && echo $CURSOR && return
    (( line > CURSOR )) && next=$line && break
  done <<< $(echo $ZSH_VI_SEARCH_BUFFER | grep -bo '\<\w' | cut -d: -f1)
  [[ $ZSH_VI_SEARCH_BUFFER[(( CURSOR+1 ))] =~ '\w' ]] && echo $prev || echo $next
}

# Main widget
zsh-vi-search() {
  local keymap=$ZSH_VI_SEARCH_KEYMAP direction=1 char='' condition idx
  ZSH_VI_SEARCH_BUFFER=$BUFFER
  case $WIDGET in
    *-backward|*-cursor-rev) char='?' && ZSH_VI_SEARCH_DIRECTION=-1 ;|
    *-forward|*-cursor) char='/' && ZSH_VI_SEARCH_DIRECTION=1 ;|
    *-repeat-rev) direction=-1 ;|
    *-cursor*)
      local cursor_idx=$(zsh-vi-search-cursor-index)
      [[ -z $cursor_idx ]] && return || CURSOR=$cursor_idx
      ZSH_VI_SEARCH_STRING=$(echo "${BUFFER:$CURSOR}" | grep -o '^\w\+')
    ;|
    *-backward|*-forward)
      ZSH_VI_SEARCH_MINIBUFFER=1
      bindkey -e;
      read-from-minibuffer $char $ZSH_VI_SEARCH_PREFIX;
      bindkey -v
      ZSH_VI_SEARCH_MINIBUFFER=0 ZSH_VI_SEARCH_STRING=$REPLY
      [[ -z $ZSH_VI_SEARCH_STRING ]] && return
    ;|
  esac
  [[ $keymap == visual ]] && zle set-mark-command
  zsh-vi-search-highlight-clear
  local positions=("${(@f)$(zsh-vi-search-indices "$ZSH_VI_SEARCH_STRING")}")
  for position in $positions; do
    local p=(${=position}) start=${p[1]} end=${p[2]}
    zsh-vi-search-highlight $start $end
    if (( ZSH_VI_SEARCH_DIRECTION*direction == -1 )); then
      (( start + 1 <= CURSOR )) && idx=$start
    else
      (( start > CURSOR )) && [[ -z $idx ]] && idx=$start
    fi
  done
  [[ -n $idx ]] && INDEX=$idx CURSOR=$idx
}

# Instantiate widgets
for w in zsh-vi-search-{forward,backward,{repeat,cursor}{,-rev}}; do
  zle -N $w zsh-vi-search
done

# Set the keybindings
bindkey -M vicmd \/ zsh-vi-search-forward \? zsh-vi-search-backward
bindkey -M vicmd n zsh-vi-search-repeat N zsh-vi-search-repeat-rev
bindkey -M vicmd \* zsh-vi-search-cursor \# zsh-vi-search-cursor-rev
bindkey -M emacs '^[' close-minibuffer
