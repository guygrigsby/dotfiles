setlocal et sw=2 ts=2
au BufRead,BufWritePre *.toml :normal gg=G``
