#!/bin/bash

VIMRC_PATH="$HOME/.vimrc"

cat <<EOF > "$VIMRC_PATH"
set nu
set ai
set si
set cindent
set sts=4
set ts=4
set shiftwidth=4
set wmnu
set laststatus=2
set ignorecase
set hlsearch
set nocompatible
set ruler
set mouse=a
set fileencodings=utf-8,euc-kr
set fencs=ucs-bom,utf-8,euc-kr
set showmatch
syntax on
filetype indent on
set bs=indent,eol,start
set title
EOF