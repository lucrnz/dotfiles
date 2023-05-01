if isdirectory('./node_modules') && isdirectory('./node_modules/prettier')
  let g:coc_global_extensions += ['coc-prettier']
endif

if isdirectory('./node_modules') && isdirectory('./node_modules/eslint')
  let g:coc_global_extensions += ['coc-eslint']
endif

autocmd BufEnter *.{js,jsx,ts,tsx} :syntax sync fromstart
autocmd BufLeave *.{js,jsx,ts,tsx} :syntax sync clear

autocmd FileType *.{js,jsx,ts,tsx} nmap <silent> gd <Plug>(coc-definition)
autocmd FileType *.{js,jsx,ts,tsx} nmap <silent> gy <Plug>(coc-type-definition)
autocmd FileType *.{js,jsx,ts,tsx} nmap <silent> gr <Plug>(coc-references)
autocmd FileType *.{js,jsx,ts,tsx} nmap <silent> rn <Plug>(coc-rename)
