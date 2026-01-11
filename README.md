# Vim integration for Lui

This is a Vim plugin for feeding buffer content to [Lui](https://github.com/gn0/lui), a command-line utility for interacting with local LLMs.

The plugin is written in Vim8 script but it uses a Neovim-specific API to handle queries asynchronously.
Vim compatibility would be a nice feature to add.

## Installation

Use your Vim package manager, or install it manually:

```
mkdir -p ~/.config/nvim/pack/gn0/start
cd ~/.config/nvim/pack/gn0/start
git clone https://github.com/gn0/lui.vim.git
nvim -u NONE -c "helptags lui.vim/doc" -c q
```

## Usage

Query `gemma3:27b` without setting any context:

```vim
:Lui -m gemma3:27b 'what Vim API can I use for asynchronous job execution?'
```

This will open a new scratch buffer with a placeholder text which is replaced when the model has completed answering the query.

Query with the contents of the current buffer as context, using a pre-specified prompt for sentence-by-sentence evaluation for non-idiomatic English (see [Lui's README](https://github.com/gn0/lui) for how this prompt can be configured):

```vim
:%Lui @english
```

Reuse the last scratch buffer for displaying the response:

```vim
:%Lui! @english
```

Send contents of a visual block as context, after selecting the block in visual mode:

```vim
:'<,'>Lui @english
```

Send the current buffer along with a README as context for code review:

```vim
:%Lui -i README.md -- 'review this source file as if you were a senior software engineer. the README explains the purpose of the program.'
```

## License

The source code is released under [CC0](https://creativecommons.org/public-domain/cc0/).

