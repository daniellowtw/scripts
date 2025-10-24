function! s:DumpContToFile(reg_cont, fname)
	if !filereadable(a:fname)
		echoerr a:fname . " does not exist"
		return
	endif
	execute "redir! > " . a:fname
	silent echon a:reg_cont
	redir END
	echo "Dumped to remote clipboard"
endfunction
nnoremap <silent> <Space>c :call <SID>DumpContToFile(@", expand("~")."/clip")<CR>

