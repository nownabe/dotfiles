" Altenative escape
:imap jj <Esc>

" Windows
nnoremap <silent> <Leader>wh <C-w>h
nnoremap <silent> <Leader>wj <C-w>j
nnoremap <silent> <Leader>wk <C-w>k
nnoremap <silent> <Leader>wl <C-w>l

" denite.nvim
if executable('rg')
  call denite#custom#var('file_rec', 'command',
    \ ['rg', '--files', '--hidden', '--glob', '!.git'])
else
  call denite#custom#var('file_rec', 'command',
    \ ['ag', '--follow', '--nocolor', '--nogroup', '--hidden', '-g', '.', '--ignore', '.git'])
endif

call denite#custom#map('insert', '<C-j>', '<denite:move_to_next_line>')
call denite#custom#map('insert', '<C-k>', '<denite:move_to_previous_line>')
call denite#custom#map('insert', '<C-v>', '<denite:do_action:vsplit>')
call denite#custom#map('insert', '<C-h>', '<denite:do_action:split>')
call denite#custom#map('insert', 'jj', '<denite:enter_mode:normal>')
call denite#custom#map('normal', 'jj', '<denite:quit>')

nnoremap <silent> <Leader>ff :Denite file_rec<CR>
nnoremap <silent> <Leader>fb :Denite buffer<CR>
nnoremap <silent> <Leader>fn :Denite file file:new<CR>
