---
title: Vim plugins lost in the Vundle
---

Once in a while I try to audit my vim configuration, plugins, etc. Although I try
to be vigilant against it, I inevitably end up with plugins that go unused for
months and cause some minor wtf moments when I see them later and can't remember
what they're for.

Even worse: it's a vicious, time consuming cycle. I find myself having a
hard time parting from some of these plugins after I rediscover their purpose.
So I end up refreshing my knowledge of their mappings, using them for a few
days, and forgetting about them again because for whatever reason they just aren't
sticking as part of my workflow.

In an effort to document some this discovery and once and for all expunge
some of these plugins from my Vundle, I decided it's worth writing up a quick
review of a few plugins I have tried, but just haven't stuck.

## Vundle organization

As you've probably inferred, I currently use
[*Vundle*](https://github.com/VundleVim/Vundle.vim) to manage my vim bundle.
I've considered trying [Tim Pope's *Pathogen*](https://github.com/tpope/vim-pathogen),
but that's a topic for another post. Anyway, my
[`.vimrc.bundles`](https://github.com/mlr/dotfiles/blob/master/vimrc.bundles)
file looks like this:

{% highlight vim linenos=table %}
set nocompatible
filetype off

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" Let Vundle manage Vundle
" Define bundles via Github repos
Bundle 'gmarik/vundle'

" Core enhancements
Bundle 'chriskempson/base16-vim'
Bundle 'danro/rename.vim'
Bundle 'itchyny/lightline.vim'
Bundle 'vim-scripts/ShowTrailingWhitespace'
Bundle 'vim-scripts/DeleteTrailingWhitespace'
Bundle 'tpope/vim-unimpaired'

" IDE-like enhancements
Bundle 'scrooloose/nerdtree'
Bundle 'scrooloose/syntastic'
Bundle 'kien/ctrlp.vim'
Bundle 'rking/ag.vim'
Bundle 'nathanaelkane/vim-indent-guides'
Bundle 'tpope/vim-fugitive'
Bundle 'gregsexton/gitv'
Bundle 'benmills/vimux'
Bundle 'jgdavey/vim-turbux'

" Code editing enhancements
Bundle 'tsaleh/vim-matchit'
Bundle 'tpope/vim-endwise'
Bundle 'tpope/vim-surround'
Bundle 'vim-scripts/tComment'
Bundle 'godlygeek/tabular'
Bundle 'goldfeld/vim-seek'
Bundle 'PeterRincker/vim-argumentative'
Bundle 'tommcdo/vim-exchange.git'
Bundle 'terryma/vim-expand-region'
Bundle 'kana/vim-textobj-user'
Bundle 'nelstrom/vim-textobj-rubyblock'
Bundle 'jgdavey/vim-blockle'

" File type handlers
Bundle 'xenoterracide/html.vim'
Bundle 'vim-ruby/vim-ruby'
Bundle 'tpope/vim-bundler'
Bundle 'tpope/vim-rails'
Bundle 'tpope/vim-haml'
Bundle 'tpope/vim-markdown'
Bundle 'mustache/vim-mustache-handlebars'
Bundle 'kchmck/vim-coffee-script'
Bundle 'slim-template/vim-slim.git'

" Snippets
Bundle 'MarcWeber/vim-addon-mw-utils'
Bundle 'tomtom/tlib_vim'
Bundle 'garbas/vim-snipmate'

filetype on
{% endhighlight %}

As you can see it's organized into 5 semi-defined sections:

1. Core enhancements
2. IDE-like enhancements
3. Code editing enhancements
4. File type handlers
5. Snippets

Sections 1, 4 and 5 tend to be fairly unchanging. Sections 2 and 3 are where the
most churn tends to happens. There's four plugins in particular that I wanted to
review for removal:

{% highlight vim %}
Bundle 'goldfeld/vim-seek'
Bundle 'PeterRincker/vim-argumentative'
Bundle 'tommcdo/vim-exchange.git'
Bundle 'terryma/vim-expand-region'
{% endhighlight %}

## Vim seek

[https://github.com/goldfeld/vim-seek](https://github.com/goldfeld/vim-seek)

> Seek makes navigating long lines effortless, acting like f but taking two characters.

![Vim seek install date]({{site.url}}/images/posts/vim-bundle-vim-seek.png){: .console-image }

I remember installing [vim-seek](https://github.com/goldfeld/vim-seek) because
my habit when writing code tends to be to use the `f` character to motion jump
around to the part of the line I need to change. The problem comes when the line
has more than one of a given character, which tends to happen more often than not.
Vim seek maps the `s` character to behave similar to find, but takes two
characters then jumps to the first instance of those two characters.

This works great, but I found myself forgetting the key mapping was there.
Furthermore, I simply adjusted my habit from tending to use the `f` key to
invoke find to using the `/` key to invoke a pattern search and typing a couple
characters to search within the whole file.

This has the added bonus of not needing to be on the same line as the search
term and I can use `?` (`shift + /`) similar to `F` to search backward. Now I tend to
just type `/` and begin typing the code I'm trying to jump to.

**Conclusion: removed from bundle**

## argumentative.vim

[https://github.com/PeterRincker/vim-argumentative](https://github.com/PeterRincker/vim-argumentative)

> Argumentative aids with manipulating and moving between function arguments.

As can be seen in the example below, argumentative lets you easily swap the
order of method arguments. Argumentative defines the `>,` and `<,` mappings. You
simply place the cursor on one argument and use the former to swap it right and
the latter to swap it left.

![Vim argumentative usage]({{site.url}}/images/posts/vim-bundle-vim-argumentative.gif){: .console-image }

In addition, it defines two new text objects `a,` and `i,` which allows you to
further manipulate function arguments. For instance `vi,` and `va,` can be used to
make a visual selection inside the method argument under the cursor or select around it, respectively.

Although I still love the idea of this plugin, I have not noticed myself using
it after having installed it over a year ago. Swapping the order of arguments is
just not something I do often enough to develop a muscle memory for the
key mappings.

**Conclusion: removed from bundle**

## exchange.vim

[https://github.com/tommcdo/vim-exchange](https://github.com/tommcdo/vim-exchange)

> Easy text exchange operator for Vim

This plugin allows you to quickly swap two lines or two large regions of text.
Vimcasts provides an excellent cover of exchange.vim's features in their vimcast
[*Swapping two regions of text with
exchange.vim*](http://vimcasts.org/episodes/swapping-two-regions-of-text-with-exchange-vim/).

Similar to argumentative.vim, this is a plugin I must have installed figuring I
would use it a lot. Even as of writing this it still feels like this is something
I do often enough to warrant custom key mappings for.

In practice though, I tend to just visually select and cut a chunk of code then
use motion keys to jump to the position I want it to be, then paste. I rarely
entirely swap two lines or pieces of code with one another.

**Conclusion: removed from bundle**

## Vim expand region

[https://github.com/terryma/vim-expand-region](https://github.com/terryma/vim-expand-region)

> Vim plugin that allows you to visually select increasingly larger regions of
> text using the same key combination.

![Vim expand region usage]({{site.url}}/images/posts/vim-bundle-vim-expand-region.gif){: .console-image }

Using the `+` and `_` key mappings provided by vim-expand-region, you can easily
grow and shrink a visual selection as seen above.

Since I don't typically visually select some piece of text before operating on
it, I don't need to modify my selection very often. I tend to just yank or change
inside of whatever text object I'm in. For example `yi(` or `ci[`.

I do frequently select entire blocks of code, for instance an if statement to
indent further, but in that case I typically place my cursor on the `if` or the
`end` and do `V%` to select to the entire block.

**Conclusion: removed from bundle**

## RIP plugins

I ended up removing all four plugins I reviewed today. I think they provide great
functionality, but in the end I used them less times than I can count on one hand
and they had been installed for over a year on average.

On a positive note, I can now look to this write-up if I stumble upon any of
these plugins in the future and want to give any of them another try.
