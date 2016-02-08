"" =================
""  INIT
"" =================

" set encoding
set encoding=utf-8
let s:is_windows = has('win32') || has('win64')

"" =================
""  VIM SETUP
"" =================

if s:is_windows
  " Fix temp directories for Windows 7
  " set directory^=~\\tmp,$TMP,$TEMP
  " Change to home folder
  " cd ~
endif

" leader (to be set before plugin configs)
let mapleader = "\<Space>"

"" =================
""  PLUGINS
"" =================

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
let s:Include_path = expand('$HOME') . '/.vim/bundle/'
call vundle#begin()

let g:Included = {}

command! -nargs=+ Include call <SID>SetInclude(<f-args>)

function! s:SetInclude(plugin, ...)
  let split_string = split(a:plugin, '/')
  let priority = 100
  let after = []
  for parameter in a:000
    let split_para = split(parameter, ':')
    if split_para[0] == 'priority'
      let priority = split_para[1]
    elseif split_para[0] == 'after'
      call add(after, split_para[1])
    elseif !s:CheckDepends(split_para)
      return
    endif
  endfor
  if len(split_string) > 1
    let key = split_string[1]
  else
    let key = a:plugin
  endif
  let g:Included[key] = {'plugin': a:plugin, 'priority': priority, 'after': after, 'name': key}
endfunction

function! Included(string)
  return has_key(g:Included, a:string) && isdirectory(s:Include_path . a:string)
endfunction

function! s:CheckDepends(dependency)
  let split_type = a:dependency
  let type = split_type[0]
  if type == 'exe'
    let type = 'executable'
  elseif type == '!exe'
    let type = '!executable'
  endif
  let split_dependency = split(split_type[1], '|')
  let pass = 0
  for dependency in split_dependency
    if type == 'include'
      if has_key(g:Included, dependency)
        let pass = 1
        break
      endif
    elseif type == '!include'
      if !has_key(g:Included, dependency)
        let pass = 1
        break
      endif
    elseif eval(type . '(' . '"' . dependency . '"' . ")")
      let pass = 1
      break
    endif
  endfor
  return pass
endfunction

function! s:DoInclude()
  let sorted = []
  for key in keys(g:Included)
    call s:Insert(sorted, g:Included[key])
  endfor

  let done = {}
  let g:Sorted = deepcopy(sorted)

  while len(sorted)
    if s:CheckAfter(done, sorted[0].after)
      execute "Plugin '" . sorted[0].plugin . "'"
      let done[sorted[0].name] = 1
      let sorted[0].done = 1
      call remove(sorted, 0)
    else
      let plugin = remove(sorted, 0)
      call add(sorted, plugin)
    endif
  endwhile
endfunction

function! s:Insert(list, item)
  let i = 0
  while i < len(a:list)
    if a:list[i].priority <= a:item.priority
      break
    endif
    let i += 1
  endwhile
  call insert(a:list, a:item, i)
endfunction

function! s:CheckAfter(done, after)
  for plugin in a:after
    if has_key(g:Included, plugin) && !has_key(a:done, plugin)
      return 0
    endif
  endfor
  return 1
endfunction

"" =================
""  PLUGINS
"" =================

Include gmarik/Vundle.vim

" = Fuzzy search completion =
Include gelguy/cmd2.vim

"" ==== INTEGRATION ====

" = External shell integration =
" > for vimshell, requires compile (see readme)
" Include Shougo/vimproc.vim
" exe:vimfiles/bundle/vimproc.vim/autoload/vimproc_win32.dll
" Include Shougo/vimshell.vim
" Include tpope/vim-dispatch

" = Git integration =
" Include tpope/vim-fugitive exe:git
" Include tpope/vim-git exe:git
" Include gregsexton/gitv exe:git include:vim-fugitive
" Include airblade/vim-gitgutter exe:git
" Include kablamo/vim-git-log exe:git

" = Ag integration =
" Include rking/ag.vim exe:ag

" = Latex integration =
" Include lervag/vim-latex
" Include xuhdev/vim-latex-live-preview exe:evince|okular

"" ==== INTERFACE ====

" = custom statusline =
" Include bling/vim-airline has:gui_running
" Include itchyny/lightline.vim !has:gui_running

" = CtrlP file, buffer, ... finder =
Include ctrlpvim/ctrlp.vim
" Include tacahiroy/ctrlp-funky include:ctrlp.vim
" Include fisadev/vim-ctrlp-cmdpalette include:ctrlp.vim

" = File explorer =
Include scrooloose/nerdtree
Include jistr/vim-nerdtree-tabs include:nerdtree
" Include netrw.vim

" = Unite file, buffer, ... finder  =
" Include Shougo/unite.vim

" = Undo tree =
" Include sjl/gundo.vim has:python|python3

" = Tagbar =
" Include majutsushi/tagbar exe:ctags

" = Location and quickfix list =
" Include milkypostman/vim-togglelist

" = Session management =
" Include xolox/vim-session

" = Show registers prompt =
" Include junegunn/vim-peekaboo

" = Show cmdline suggestions =
" Include paradigm/SkyBison

" = Custom glyph icons
" Include ryanoasis/vim-webdevicons after:vim-airline after:nerdtree has:gui_running

"" ==== COMPLETION ====

" = Autocomplete =
" Include Shougo/neocomplete.vim has:lua
" Include Shougo/neocomplcache.vim
" Include ervandew/supertab

" = Python completion =
" Include davidhalter/jedi-vim has:python|python3

" = Snippets =
" Include Shougo/neosnippet.vim
" Include Shougo/neosnippet-snippets
" Include SirVer/ultisnips has:python|python3
" Include honza/vim-snippets

"" ==== MOVEMENT ====

" = Easy and fast movement =
Include Lokaltog/vim-easymotion

" = Expand selection region =
" Include terryma/vim-expand-region

"" ==== EDITING ====

" = Extra mappings =
" Include tpope/vim-unimpaired

" = more text objects
" Include wellle/targets.vim

" = textobj - user-defined text objects =
" Include kana/vim-textobj-user

" > {ai}l
Include kana/vim-textobj-line include:vim-textobj-user

" > {ai}i {ai}I
Include kana/vim-textobj-indent include:vim-textobj-user

" > {ai}o Ao
Include glts/vim-textobj-comment include:vim-textobj-user

" > {ai}t{char}
Include thinca/vim-textobj-between include:vim-textobj-user

" > {ai}b
Include Julian/vim-textobj-brace include:vim-textobj-user

" > {ai}/
Include kana/vim-textobj-lastpat include:vim-textobj-user

" > {ai}f
Include kana/vim-textobj-function include:vim-textobj-user
Include thinca/vim-textobj-function-javascript include:vim-textobj-function

" > {ai}d
Include machakann/vim-textobj-delimited include:vim-textobj-user

" > {ai}c {ai}C
Include coderifous/textobj-word-column.vim include:vim-textobj-user

" > {ai}e
Include kana/vim-textobj-entire include:vim-textobj-user

" > {ai}f
Include bps/vim-textobj-python include:vim-textobj-user

" > {ai}a
Include sgur/vim-textobj-parameter include:vim-textobj-user

" > {ai}q
Include beloglazov/vim-textobj-quotes include:vim-textobj-user

" = delimiter ({[ autocompletion =
Include Raimondi/delimitMate

" = end block completion =
Include tpope/vim-endwise

" = Change surrounding delimiters =
Include tpope/vim-surround

" = Toggle commenting =
Include scrooloose/nerdcommenter

" = Multiple cursor editing =
Include terryma/vim-multiple-cursors

" = Tabularize text blocks =
Include godlygeek/tabular

" = Toggle between join and splitting lines =
" Include AndrewRadev/splitjoin.vim

" = Toggle between patterns =
" Include AndrewRadev/switch.vim

" = Toggle between patterns =
" Include AndrewRadev/sideways.vim

" = Narrow text region =
" Include chrisbra/NrrwRgn

"" ==== COMMANDS ====

" = Buffer closing =
" Include moll/vim-bbye

" = Repeat plugin commands with . =
" Include tpope/vim-repeat

" = Fuzzy filter =
" Include tpope/vim-haystack

"" ==== SEARCH ====

" = Show substitution regions =
Include osyo-manga/vim-over

" = improved search =
" Include junegunn/vim-pseudocl
" Include junegunn/vim-oblique include:vim-pseudocl
" Include pgdouyon/vim-evanesco

" = clever-f =
Include rhysd/clever-f.vim

"" ==== CODE DISPLAY ====

" = Highlighting multiple words =
" Include vasconcelloslf/vim-interestingwords
" Include idbrii/vim-mark

" = ANSI escaping =
" Include AnsiEsc.vim

" = Highlight colors and ANSI escaping =
" Include chrisbra/Colorizer

" = Colorscheme switcher =
Include xolox/vim-misc
Include xolox/vim-colorscheme-switcher include:vim-misc

" = Colorschemes =
" Include altercation/vim-colors-solarized
" Include tomasr/molokai
" Include sjl/badwolf
" Include Pychimp/vim-luna
" Include jonathanfilip/vim-lucius
" Include nanotech/jellybeans.vim
" Include w0ng/vim-hybrid
" Include Zenburn
" Include whatyouhide/vim-gotham
" Include chriskempson/vim-tomorrow-theme
" Include vim-scripts/apprentice.vim
" Include endel/vim-github-colorscheme
" Include junegunn/seoul256.vim
" Include google/vim-colorscheme-primary
Include NLKNguyen/papercolor-theme
Include gosukiwi/vim-atom-dark

" = focused coding =
Include junegunn/limelight.vim

" = Colour matching of parantheses =
" Include junegunn/rainbow_parentheses.vim

" = Fine-tune colorschemes =
" Include zefei/vim-colortuner

"" ==== LANGUAGE/SYNTAX ====

" = Syntax checking =
Include scrooloose/syntastic

" = Language syntax =
" Include pangloss/vim-javascript
Include jelera/vim-javascript-syntax
Include othree/javascript-libraries-syntax.vim
" Include tikhomirov/vim-glsl

" = Code analysis =
" > very slow for large files
" Include marijnh/tern_for_vim exe:node

"" =================
""  VUNDLE
"" =================

" Keep Plugin commands between vundle#begin/end.
filetype off
call s:DoInclude()

" All of your Plugins must be added before the following line
call vundle#end()            " required
" To ignore plugin indent changes, instead use:
" filetype plugin on
filetype plugin indent on    " required

"" =================
""  PLUGINS CONFIG
"" =================

" = cmd2.vim =
if Included('cmd2.vim')

  function! s:CustomFuzzySearch(string)
    let k = '\k'              " keyword
    let d = '\[._\-#]'        " delimiter
    let h = '\%(\[agls]\:\)\?' " head
    let result = '\V\<' . h
    let i = 0
    while i < len(substitute(a:string, '.', 'x', 'g'))
      let char = matchstr(a:string, ".", byteidx(a:string, i))
      let original_char = char
      if char == '\'
        if i == len(substitute(a:string, '.', 'x', 'g')) - 1
          let char .= '\'
        else
          let char .= matchstr(a:string, ".", byteidx(a:string, i+1))
        endif
        let offset = 1
      else
        let offset = 0
      endif
      " if i == 0
        " let result .= '\%(' . k . '\*' . d . '\)\?'
      " endif
      if offset == 0 && char =~ '\k'
        if toupper(char) !=# char
          if i == 0
            let result .= '\%(' . char . '\|' . toupper(char) . '\)'
          else
            let result .= '\%(\%(' . k . '\*' . d . '\)\?' . char . '\|' . k . '\*\%(' . toupper(char) . '\)\)'
          endif
        else
          if i == 0
            let result .= '\%(' . toupper(char) . '\)'
          else
            let result .= '\%(' . k .'\*' . d . '\?\)\?\%(' . toupper(char) . '\)'
          endif
        endif
      else
        if i == 0
          let result .= char
        else
          let result .= '\%(' . k . '\|' . d . '\)\*' . char . h
        endif
      endif
      let i += len(original_char) + offset
    endwhile
    let result .= k . '\*'
    return result
  endfunction

  function! s:CacheFuzzySearch(cmd)
    if !get(b:, 'cache_init', 0)
      call neocomplete#init#_sources(['buffer'])
      call neocomplete#available_sources().buffer.hooks.on_init(0)
      let b:cache_init = 1
    endif
    let candidates = neocomplete#available_sources().buffer.gather_candidates('')
    return neocomplete#filters#matcher_fuzzy#define().filter({'complete_str': a:cmd, 'candidates': candidates})
  endfunction

  function! s:PythonStrict(string)
    let k = '(?:\w|[_\-#])'      " keyword
    let result = g:Cmd2__complete_ignorecase ? '(?i)' : ''
    let result .= '\b' . a:string . k . '*'
    return result
  endfunction

  function! s:PythonFuzzy(string)
    let k = '[a-zA-Z0-9_\-#.]'      " keyword
    " let result = g:Cmd2__complete_ignorecase ? '(?i)' : ''
    let result = ''
    " if matchstr(a:string, ".", byteidx(a:string, 0)) =~ '\h'
      " let result .= '\b'
    " endif
    let result .= '(?:[agls]:)?' . k . '*'
    let i = 0
    while i < len(substitute(a:string, '.', 'x', 'g'))
      let char = matchstr(a:string, ".", byteidx(a:string, i))
      if char == '\'
        if i == len(substitute(a:string, '.', 'x', 'g'))
          let char .= '\\\'
        else
          let char .= matchstr(a:string, ".", byteidx(a:string, i+1))
        endif
        let offset = 1
      else
        let offset = 0
      endif
      if toupper(char) == char
        let result .= char
      else
        let result .= '[' . char . toupper(char) . ']'
      endif
      if char == ' ' && i == len(substitute(a:string, '.', 'x', 'g')) - 1
        let result .= k . '+'
      else
        let result .= k . '*'
      endif
      let i += 1 + offset
    endwhile
    return result
  endfunction

  function! s:PythonDelimited(string)
    let k = '[a-zA-Z0-9]'      " keyword
    let d = '[._\-#]'        " delimiter
    let h = '(?:[agls]:|_)?' " head
    let kd = '[a-zA-Z0-9_\-#.]' " keyword|delimiter

    let result = ''
    let i = 0
    let len = len(substitute(a:string, '.', 'x', 'g'))
    while i < len
      let char = matchstr(a:string, ".", byteidx(a:string, i))
      let original_char = char
      if char == '\'
        if i == len - 1  " last char
          let char .= '\\\'
          let offset = 1
        else
          let next_char = matchstr(a:string, ".", byteidx(a:string, i+1))
          if next_char == '\'
            let char .= '\\\'
            let offset = 1
          else
            let char .= next_char
            let offset = len(next_char)
          endif
        endif
      else
        let offset = 0
      endif
      if i == 0 && char =~ '\k'
        let result = '\b' . h
      endif
      if offset == 0 && char =~ '\k'
        if toupper(char) !=# char
          if i == 0
            let result .= '(?:' . kd . '*(?:' . toupper(char) . '|' . d . char . ')|' . char . ')'
            " let result .= '(?:' . kd . '*' . toupper(char) . '|' . '(?:' . kd . '*' . d . ')?' . char . ')'
            " let result .= '(?:' . char . '|' . toupper(char) . ')'
          else
            let result .= '(?:' . kd . '*(?:' . toupper(char) . '|' . d . char . ')|' . char . ')'
            " let result .= '(?:' . kd . '*' . toupper(char) . '|' . '(?:' . kd . '*' . d . ')?' . char . ')'
          endif
        else
          if i == 0
            let result .= kd . '*' . toupper(char)
          else
            let result .= kd . '*' . toupper(char)
          endif
        endif
      else
        if i == 0
          let result .=  h . kd . '*' . char . h
          " let result .= char
        else
          let result .= kd . '*' . char . h
        endif
      endif
      let i += len(original_char) + offset
    endwhile
    let result .= '(?:' . kd . '*' . k . ')?'
    " let result .= kd . '*'
    return result
  endfunction

  function! s:PythonSearch(cmd)
    if a:cmd[0] == '!'
      return Cmd2#ext#complete#GenerateCandidates(a:cmd[1:])
    endif
    let escape_cmd = escape(a:cmd, '|$*.[]()')
    let pattern = s:PythonFuzzy(escape_cmd)
    return s:PythonCmd(pattern, a:cmd, 're2')
  endfunction

  function! s:PythonApproxSearch(cmd)
    let escape_cmd = escape(a:cmd, '|$*.[]()')
    let pattern = '\b(?:' . s:PythonStrict(escape_cmd) . '){d<=1,i<=1}'
    return s:PythonCmd(pattern, a:cmd, 'regex')
  endfunction

  function! s:PythonCmd(pattern, cmd, engine)
    if has('python3')
      let cmd = 'python3 << EOF'
    elseif has('python')
      let cmd = 'python << EOF'
    endif
" python
exe cmd

import vim

try:
    engine = vim.eval('a:engine')
    re = __import__(engine)
except ImportError:
    import re

try:
    score
except NameError:
  def score(string, word, fuzziness):
    if string == word:
      return 1
    if word == "":
      return 0
    if re.match('[agls]:', string[0 : 2]):
      string = string[2:]
    if re.match('_', string[0 : 1]):
      string = string[1:]

    runningScore = 0
    lString = string.lower()
    strLength = len(string)
    lWord = word.lower()
    wordLength = len(word)
    startAt = 0
    fuzzies = 1
    fuzzyFactor = 1

    if fuzziness:
      fuzzyFactor = 1 - fuzziness
    if fuzziness:
      for i in range(wordLength):
        idxOf = lString.find(lWord[i], startAt)
        if idxOf == -1:
          fuzzies += fuzzyFactor
        else:
          if startAt == idxOf:
            charScore = 0.7
          else:
            charScore = 0.1
            if re.match('[ _.#\-:]', string[idxOf - 1]) or string[idxOf].isupper():
              charScore += 0.8
          if string[idxOf] == word[i]:
            charScore += 0.1
          runningScore += charScore
          startAt = idxOf + 1
    else:
        for i in range(worldLength):
            idxOf = lString.find(lWord[i], startAt)
            if idxOf == -1:
                return 0
            if startAt == idxOf:
                charScore = 0.7
            else:
                charScore = 0.1
                if re.match('[ _.#\-]', string[idxOf - 1]) or string[idxOf].isupper():
                    charScore += 0.8
            if string[idxOf] == word[i]:
                charScore += 0.1

            runningScore += charScore
            startAt = idxOf + 1

    finalScore = 0.5 * (runningScore / strLength + runningScore / wordLength) / fuzzies

    if lWord[0] == lString[0] and finalScore < 0.85:
        finalScore += 0.15

    return finalScore

buffer = vim.current.buffer
pattern = re.compile(vim.eval('a:pattern'))
string = vim.eval('g:Cmd2_pending_cmd[0]')
result = re.findall(pattern, '\n'.join(buffer[:]))
uniq = list(set(result))
filtered = filter(lambda x: len(x) > 0, uniq)
# sort = sorted(uniq, key=str.lower)

mru = vim.eval('g:Cmd2_search_mru_hash')
size = len(mru)
string = vim.eval('a:cmd')
# sort = sorted(filtered, key=lambda x: [int(mru.get(x, size)), x.lower()])
sort = sorted(filtered, key=lambda x: [int(mru.get(x, size)), 1 - score(x, string, 1), x.lower()])
vim.command('let results = %s' % sort)
EOF

    return results
  endfunction

  function! s:PythonCache(cmd)
    if !get(b:, 'cache_init', 0)
      call neocomplete#init#_sources(['buffer'])
      call neocomplete#available_sources().buffer.hooks.on_init(0)
      let b:cache_init = 1
    endif
    let candidates = neocomplete#available_sources().buffer.gather_candidates('')
    let escape_cmd = escape(a:cmd, '|$^*.()[]')
    let pattern = s:PythonDelimited(escape_cmd)
    if has('python3')
      let cmd = 'python3 << EOF'
    elseif has('python')
      let cmd = 'python << EOF'
    endif
" python
exe cmd

try:
    import re2 as re
except ImportError:
    import re

candidates = vim.eval('candidates')
pattern = vim.eval('pattern')
result = [ x for x in candidates if re.match(pattern, x) ]
sort = sorted(list(set(result)),  key=str.lower)
vim.command('let results = %s' % sort)
EOF
return results

  endfunction

  function! s:RubySearch(cmd)
    let escape_cmd = escape(a:cmd, '|$^*.()[]')
    let pattern = s:PythonDelimited(a:cmd)
ruby << EOF
buffer = VIM::evaluate("getline(0, '$')").join("\n")
pattern = VIM::evaluate('pattern')
result = buffer.scan(Regexp.new(pattern))
result.uniq!
result.sort!
result.map { |s| "'#{s}'" }.join(',')
command = "let results = #{result}"
VIM::command(command)
EOF
return results
  endfunction

  function! s:RubyCache(cmd)
    if !get(b:, 'cache_init', 0)
      call neocomplete#init#_sources(['buffer'])
      call neocomplete#available_sources().buffer.hooks.on_init(0)
      let b:cache_init = 1
    endif
    let candidates = neocomplete#available_sources().buffer.gather_candidates('')
    let escape_cmd = escape(a:cmd, '|$^*.()[]')
    let pattern = s:PythonDelimited(escape_cmd)
ruby << EOF
candidates = VIM::evaluate('candidates')
pattern = Regexp.new(VIM::evaluate('pattern'))
result = candidates.select! { |x| pattern.match(x) }
result.uniq!
result.sort!
result.map { |s| "'#{s}'" }.join(',')
command = "let results = #{result}"
VIM::command(command)
EOF
return results

  endfunction

  function! s:PerlSearch(cmd)
    let escape_cmd = escape(a:cmd, '|$^*.()[]')
    let pattern = s:PythonDelimited(a:cmd)
perl << EOF
$buffer = join("\n", VIM::Eval('getline(0, \'$\')'));
$pattern = VIM::Eval('pattern');
@matches = [];
while ($buffer =~ m/${pattern}/g )
{
    push @matches, $&;
}
$result = '[\'' . join('\',\'', @matches) . '\']';
VIM::DoCommand("let results = $result");
EOF
return results
  endfunction

  function! s:LiteralPattern(cmd)
    return a:cmd
  endfunction

  function! s:Peekaboo()
    if Included('vim-peekaboo')
      call peekaboo#peek(1, 'ctrl-r',  0)
    endif
  endfunction

  augroup Cmd2hi
    au!
    autocmd VimEnter * call s:MakeCmd2MenuHi()
    autocmd ColorScheme * call s:MakeCmd2MenuHi()
  augroup END

  function! s:MakeCmd2AirlineTheme(...)
    if !exists('g:colors_name')
      return
      endif
    if get(s:, 'old_colors', '') == g:colors_name . '.' . &background && !(a:0 && a:1) || !Included('vim-airline')
      return
    else
      let s:old_colors = g:colors_name . '.' . &background
    endif
    let palette = g:airline#themes#{g:airline_theme}#palette
    let dark =  palette['normal']['airline_c']
    let light = palette['replace']['airline_a']
    let white = palette['insert']['airline_a']
    let theme = {
        \ 'Cmd2dark'   : dark,
        \ 'Cmd2light'  : light,
        \ 'Cmd2white'  : white,
        \ 'Cmd2arrow1' : [ light[1] , white[1] , light[3] , white[3] , ''     ] ,
        \ 'Cmd2arrow2' : [ white[1] , light[1] , white[3] , light[3] , ''     ] ,
        \ 'Cmd2arrow3' : [ light[1] , dark[1]  , light[3] , dark[3]  , ''     ] ,
        \ }
    for key in keys(theme)
      call airline#highlighter#exec(key, theme[key])
    endfor

    call s:MakeCmd2MenuHi()
  endfunction

  function! s:MakeCmd2MenuHi()
    if !exists('g:colors_name')
      return
      endif
      let s:old_colors = g:

    if g:colors_name == 'solarized' && &background == 'dark'
      hi! Cmd2Menu ctermfg=254 ctermbg=235 guifg=#BBB5A2 guibg=#073642
      hi! Cmd2MenuSelected ctermfg=254 ctermbg=235 guifg=#BBB5A2 guibg=#073642 gui=standout
    else
      hi! link Cmd2Menu airline_c
      hi! link Cmd2MenuSelected airline_a
    endif
  endfunction

  let g:render = Cmd2#render#New().WithInsertCursor()

  function! g:render.ModifyAirlineMenu()
    call s:MakeCmd2AirlineTheme(1)
    return self
  endfunction

  " vim --cmd "profile start prof.txt" --cmd "profile! file *suggest*" --cmd "profile! file *render*"
  let g:Cmd2_options = {
        \ 'cursor_blink': 1,
        \ 'loop_sleep': 0,
        \ 'preload': 1,
        \ 'menu_separator': ' · ',
        \ 'menu_more': '…',
        \ '_complete_ignorecase': 1,
        \ '_complete_uniq_ignorecase': 0,
        \ '_complete_fuzzy': 1,
        \ '_complete_loading_text': '...',
        \ '_suggest_complete_hl': 'Error',
        \ '_suggest_show_suggest': 1,
        \ '_suggest_min_length': 0,
        \ '_suggest_space_trigger': 0,
        \ '_suggest_no_trigger': [
            \ '\m^ec\%[ho] ',
            \ '\m^let .*=',
            \ '\m\*\*',
            \ '^Git ',
            \ ],
        \ '_suggest_middle_trigger': 0,
        \ '_suggest_jump_complete': 1,
        \ '_suggest_esc_menu': 1,
        \ '_suggest_bs_suggest': 1,
        \ '_suggest_enter_search_complete': 2,
        \ '_suggest_tab_longest': 1,
        \ '_suggest_enter_suggest': 2,
        \ '_suggest_search_profile': 0,
        \ '_suggest_hlsearch': 1,
        \ }

  if Included('vim-airline')
    let g:Cmd2_options['_suggest_render'] = 'g:render.WithInsertCursor().WithAirlineMenu2().ModifyAirlineMenu()'
    " let Cmd2_options['_suggest_render'] = 'Cmd2#render#New().WithInsertCursor().WithAirlineMenu2()'
    " let Cmd2_options['menu_hl'] = 'airline_x'
    " let Cmd2_options['menu_separator_hl'] = 'airline_x'
    let g:Cmd2_options['menu_hl'] = 'Cmd2Menu'
    let g:Cmd2_options['menu_separator_hl'] = 'Cmd2Menu'
    let g:Cmd2_options['menu_selected_hl'] = 'Cmd2MenuSelected'

    hi! link CursorLine airline_x
    hi! link CursorLineNr airline_y
  endif

  if !empty($CONEMUBUILD)
    let g:Cmd2_options['loop_sleep']= 1
  endif
        " \ '_suggest_render': 'Cmd2#render#New().WithInsertCursor().WithAirlineMenu()',
        " \ '_complete_string_pattern': '\Vs/\zs\(\.\+\)\$',
        " \ '_complete_string_pattern': '\v([gs]\/\zs)?([gs]\/|\/)@!(.+)$',
        " \ '_complete_generate': function('s:CacheFuzzySearch'),
        " \ '_complete_middle_pattern': '\%(\k\*\[_\-#]\)\?',
        " \ 'menu_next': 'Â»',
        " \ 'menu_previous': 'Â«',
        " \ '\v^\s*def': 'δ',
        " \ '\v^\s*let': 'λ',
        " \ '': {
        " \ '\v^\s*function': 'ƒ',
        " \ },

  if exists('g:Cmd2_default_options')
    call Cmd2#init#Options(g:Cmd2_default_options)
  endif

  " if !exists('g:Cmd2_search_mru') || empty(g:Cmd2_search_mru)
    " let g:Cmd2_search_mru = ['g:Cmd2_options']
  " endif

  let g:Cmd2_cmd_mappings = {
        \ 'w': {'command': 'Cmd2#functions#Cword', 'type': 'function', 'flags': 'Cr'},
        \ "\<Plug>Cmd2Tab": {'command': "Cmd2#functions#TabForward", 'type': 'function', 'flags': 'C'},
        \ "\<Plug>Cmd2STab": {'command': "Cmd2#functions#TabBackward", 'type': 'function', 'flags': 'C'},
        \ "\<Tab>": {'command': "\<Plug>Cmd2Tab", 'type': 'remap', 'flags': 'C'},
        \ "\<S-Tab>": {'command': "\<Plug>Cmd2STab", 'type': 'remap', 'flags': 'C'},
        \ 'iw': {'command': 'iw', 'type': 'text', 'flags': 'Cpv'},
        \ 'ap': {'command': 'ap', 'type': 'line', 'flags': 'pv'},
        \ 'af': {'command': 'af', 'type': 'line', 'flags': 'pv'},
        \ 'aaaaaaaaaaaaaaaaaaaa': {'command': 'aaaa', 'type': 'literal', 'flags': 'pv'},
        \ 's': {'command': 's/###/###/g', 'type': 'snippet'},
        \ 'S': {'command': 'Cmd2#functions#CopySearch', 'type': 'function'},
        \ 'b': {'command': 'Cmd2#functions#Back', 'type': 'function', 'flags': 'rC'},
        \ 'e': {'command': 'Cmd2#functions#End', 'type': 'function', 'flags': 'rC'},
        \ 'gn': {'command': '###g/###/normal! ###', 'type': 'snippet'},
        \ 'gk': {'command': '###g/###/normal! ### ### ### ###', 'type': 'snippet'},
        \ 'th': {'command': 'tab h ###', 'type': 'snippet'},
        \ "QF": {'command': 'Cmd2#ext#quicksearch#Forward', 'type': 'function'},
        \ "QB": {'command': 'Cmd2#ext#quicksearch#Backward', 'type': 'function'},
        \ 'Complete': {'command': function('Cmd2#ext#complete#Main'), 'type': 'function', 'flags': 'p'},
        \ 'C': {'command': function('Cmd2#ext#complete#Main'), 'type': 'function', 'flags': 'p'},
        \ '^': {'command': '^', 'type': 'normal!', 'flags': 'r'},
        \ 'j': {'command': 'j', 'type': 'normal!', 'flags': 'Cr'},
        \ 'D': {'command': 'こここここここここここここここここここここここここここここここここここここここここここここここここここ', 'type': 'literal', 'flags': ''},
        \ 'd': {'command': '●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●', 'type': 'literal', 'flags': ''},
        \ 'a': {'command': 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaabcdef^', 'type': 'literal', 'flags': ''},
        \ 'a1': {'command': '1a2a3a4a5a', 'type': 'literal', 'flags': 'rC'},
        \ 'c': {'command': function('Cmd2#ext#complete#Main'), 'type': 'function'},
        \ 'h': {'command': "\<BS>\<BS>", 'type': 'literal'},
        \ 'Peekaboo': {'command': function('s:Peekaboo'), 'type': 'function'},
        \ "\<C-R>": {'command': '12345', 'type': 'literal'},
        \ }

  cmap <C-S> <Plug>(Cmd2)
  cmap <C-B> <Plug>(Cmd2Suggest)

  nmap : :<C-B>
  nmap / /<C-B>
  nmap ? ?<C-B>
  vmap : :<C-B>
  " vmap / /<Plug>(Cmd2SuggestVisual)

  nnoremap g: :
  vnoremap g: :
  nnoremap g/ /
  nnoremap g? ?

  set wildcharm=<Tab>

  cmap <expr> <Tab> Cmd2#ext#complete#InContext() ? "\<Plug>(Cmd2Complete)" : "\<Tab>"

  " cmap <expr> <C-N> getcmdtype() =~ '\v[\?\/]' ? "\<Plug>Cmd2QF" : "\<C-N>"
  " cmap <expr> <C-P> getcmdtype() =~ '\v[\?\/]' ? "\<Plug>Cmd2QB" : "\<C-P>"

  " cmap <expr> <CR> <SID>EnterSearch()

  function! s:EnterSearch()
    if getcmdtype() != '/'
      return "\<CR>"
    endif
    if search(getcmdline(), 'wn')
      return "\<CR>"
    else
      let cmdline = getcmdline()
      let string = matchstr(cmdline, g:Cmd2__complete_string_pattern)
      let pattern = call(g:Cmd2__complete_pattern_func, [string])
      if search(pattern, 'n')
        return "\<Plug>(Cmd2Complete)\<CR>"
      else
        return "\<CR>"
      endif
    endif
  endfunction

  cmap <C-R> <Plug>(Cmd2)Peekaboo
  cmap <F2> <Plug>(search)
  cnoremap <expr> <Plug>(search) Search()

  function! Search()
    if empty(getcmdline())
      return ""
    endif
    if !exists('g:pos')
      let pos = getpos('.')
      let g:opos = pos
    else
      let pos = g:pos
    endif
    call cursor(pos[1], pos[2])
    call search(getcmdline(), 'c')
    let g:pos = getpos('.')
    let @/ = getcmdline()
    set hls
    redraw
    let a = getchar()
    let a = type(a) == 0 ? nr2char(a) : a
    if a == "\<F2>"
      let g:pos[2] += strlen(getcmdline())
      if g:pos[2] > strlen(getline(g:pos[1]))
        let g:pos[2] = 1
        let g:pos[1] += 1
      endif
      call feedkeys(a)
    elseif a == "\<Esc>"
      unlet g:pos
      set nohls
      call feedkeys("\<C-C>")
    elseif a == "\<CR>"
      call feedkeys("\<C-C>")
      call feedkeys(":call cursor(" . g:pos[1] . "," . g:pos[2] . ")\<CR>")
      call feedkeys(":call search('" . getcmdline() . "'," . "'c')\<CR>")
      unlet g:pos
      set nohls
    else
      call feedkeys(a . "\<F2>")
    endif
    return ""
  endfunction

endif

" = ctrlp.vim =
if Included('ctrlp.vim')
  let g:ctrlp_map = '<leader>p'
  let g:ctrlp_cmd = 'CtrlP'
  let g:ctrlp_working_path_mode = 'ra'
  let g:ctrlp_switch_buffer = 'ET'
  let g:ctrlp_custom_ignore = {
        \ 'dir': 'node_modules\\',
        \ 'file': '\~$'
        \ }
  nnoremap <leader>b :CtrlPBuffer<CR>
  nnoremap <leader>m :CtrlPMRU<CR>
  nnoremap <leader>l :CtrlPLine<CR>
  nnoremap <leader>P :CtrlPMixed<CR>

  if executable('ag')
    let g:ctrlp_user_command = 'ag -i --nocolor --nogroup --hidden --ignore .git --ignore .svn --ignore .hg --ignore .DS_Store -g "" %s'
  endif

endif

" = ctrlp-funky =
if Included('ctrlp-funky')
  nnoremap <leader>pf :CtrlPFunky<CR>

endif

" = vim-ctrlp-cmdpalette =
if Included('vim-ctrlp-cmdpalette')
  nnoremap <leader>pc :CtrlPCmdPalette<CR>

endif

" = unite.vim =
if Included('unite.vim')
  call unite#custom#profile('default', 'context', {
        \   'start_insert': 1,
        \   'winheight': 10,
        \   'direction': 'botright',
        \ })
  call unite#custom#source('file_rec', 'ignore_pattern', 'node_modules/')
  " call unite#filters#matcher_default#use(['matcher_fuzzy'])
  nnoremap <leader>u :<C-u>Unite file_rec<CR>
  if s:is_windows && executable('ag')
    let g:unite_source_rec_async_command =
          \ 'ag --follow --nocolor --nogroup --hidden -g ""'
  endif

  augroup Unite
    au!
    autocmd FileType unite imap <buffer> <Esc> <Plug>(unite_exit)
  augroup END

endif
if Included('neocomplcache.vim')
  let g:acp_enableAtStartup = 0
  let g:neocomplcache_enable_at_startup = 0
  " NeoComplCacheDisable
  nnoremap <F2> :NeoComplCacheToggle<CR>
  inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
  function! s:my_cr_function()
    return neocomplcache#smart_close_popup() . "\<CR>"
    " For no inserting <CR> key.
    "return pumvisible() ? neocomplcache#close_popup() : "\<CR>"
  endfunction
  " <TAB>: completion.
  inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
  " <C-h>, <BS>: close popup and delete backword char.
  inoremap <expr><C-h> neocomplcache#smart_close_popup()."\<C-h>"
  inoremap <expr><BS> neocomplcache#smart_close_popup()."\<C-h>"
  inoremap <expr><C-y>  neocomplcache#close_popup()
  inoremap <expr><C-e>  neocomplcache#cancel_popup()
endif

" = neocomplete.vim =
if Included('neocomplete.vim')
  let g:neocomplete#ctags_command = ""
  " > Disable AutoComplPop.
  let g:acp_enableAtStartup = 0
  " Use neocomplete.
  let g:neocomplete#enable_at_startup = 1
  " Use smartcase.
  let g:neocomplete#enable_smart_case = 1
  " Set minimum syntax keyword length.
  let g:neocomplete#sources#syntax#min_keyword_length = 3
  let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'

  " Define keyword.
  if !exists('g:neocomplete#keyword_patterns')
    let g:neocomplete#keyword_patterns = {}
  endif

  let g:neocomplete#keyword_patterns['default'] = '\h\w*'

  " Plugin key-mappings.
  inoremap <expr><C-g>     neocomplete#undo_completion()
  inoremap <expr><C-l>     neocomplete#complete_common_string()

  imap <expr> <Tab> "\<C-R>=<SID>i_tab()\<CR>"
  function! s:i_tab()
    return (Included('neosnippet.vim') && neosnippet#jumpable()) ? neosnippet#mappings#jump_impl()
          \ : (Included('ultisnips') && <SID>Ulti_Jump_Forwards_Res() > 0) ? ""
          \ : pumvisible() ? "\<C-n>"
          \ : <SID>check_back_space() ? <SID>do_smart_tab()
          \ : "\<Tab>"
    " \ : neocomplete#start_manual_complete()
  endfunction

  inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<S-TAB>"
  imap <expr> <S-Tab> "\<C-R>=<SID>i_s_tab()\<CR>"
  function! s:i_s_tab()
    return (Included('ultisnips') && <SID>Ulti_Jump_Backwards_Res() > 0) ? ""
          \ : pumvisible() ? "\<C-p>"
          \ : "\<S-TAB>"
  endfunction

  " <CR>: close popup and save indent.
  imap <expr><CR> pumvisible() ? neocomplete#close_popup() . "\<CR>"
        \ : Included('delimitMate') ? "\<C-R>=delimitMate#ExpandReturn()\<CR>" . (Included('vim-endwise') ? "\<Plug>DiscretionaryEnd" : "")
        \ : "\<CR>" . (Included('vim-endwise') ? "\<Plug>DiscretionaryEnd" : "")

  imap <expr> <S-CR> "\<C-R>=<SID>i_s_cr()\<CR>"
  function! s:i_s_cr()
    return (Included('neosnippet.vim') && neosnippet#expandable()) ? neosnippet#mappings#expand_impl()
          \ : (Included('ultisnips') && <SID>Ulti_Expand_Res() > 0) ? ""
          \ : pumvisible() ? neocomplete#close_popup() . "\<CR>"
          \ : Included('delimitMate') ? delimitMate#ExpandReturn()
          \ : "\<CR>"
  endfunction

  " <C-h>, <BS>: close popup and delete backword char.
  inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
  inoremap <expr><BS> pumvisible() ? neocomplete#smart_close_popup()."\<C-h>" :
          \ Included('delimitMate') ? delimitMate#BS() : "\<BS>"
  inoremap <expr><C-e>  neocomplete#cancel_popup()

  function! s:check_back_space()
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~ '\s'
  endfunction

  function! s:do_smart_tab()
    if getline('.')[0:col('.')] =~ '^\s*$'
      if line('.') - 1
        " Not first line
        let line_above = getline(line('.')-1)
        let white_space_start = matchstr(line_above, '\v^\s+')
        if strdisplaywidth(white_space_start) > virtcol('.')
          let target = strdisplaywidth(white_space_start) - virtcol('.')
          let insert_chars = ""
          while target > &tabstop
            let insert_chars .= "\<Tab>"
            let target -= &tabstop
          endwhile
          while target >= 0
            let insert_chars .= " "
            let target -= 1
          endwhile
          return insert_chars
        endif
      endif
    endif
    return "\<Tab>"
  endfunction

  if !exists('g:neocomplete#force_omni_input_patterns')
    let g:neocomplete#force_omni_input_patterns = {}
  endif

  if Included('jedi-vim')
    let g:jedi#completions_enabled = 0
    let g:jedi#auto_vim_configuration = 0
    let g:neocomplete#force_omni_input_patterns.python =
          \ '\%([^. \t]\.\|^\s*@\|^\s*from\s.\+import \|^\s*from \|^\s*import \)\w*'
    " alternative pattern: '\h\w*\|[^. \t]\.\w*'
  endif

endif

" = neosnippet.vim =
if Included('neosnippet.vim')
  " Plugin key-mappings.
  imap <C-k>     <Plug>(neosnippet_expand_or_jump)
  smap <C-k>     <Plug>(neosnippet_expand_or_jump)
  xmap <C-k>     <Plug>(neosnippet_expand_target)

  " For snippet_complete marker.
  if has('conceal')
    set conceallevel=2 concealcursor=i
  endif

  " Enable snipMate compatibility feature.
  " let g:neosnippet#enable_snipmate_compatibility = 1

  " Tell Neosnippet about the other snippets
  if s:is_windows
    let g:neosnippet#snippets_directory='~/vimfiles/bundle/vim-snippets/snippets,~/vimfiles/snippets'
  else
    let g:neosnippet#snippets_directory='~/.vim/bundle/vim-snippets/snippets,~/.vim/snippets'
  endif

endif

" = ultisnips =
if Included('ultisnips')

  let g:UltiSnipsSnippetsDir='~/.vim/snippets'
  if has('python3')
    let g:UltiSnipsUsePythonVersion = 3
  elseif has('python')
    let g:UltiSnipsUsePythonVersion = 2
  endif

  let g:UltiSnipsExpandTrigger = "\<Plug>(DoNothing)"
  let g:UltiSnipsListSnippets = "\<Plug>(DoNothing)"
  let g:UltiSnipsJumpForwardTrigger = "\<Plug>(DoNothing)"
  let g:UltiSnipsJumpBackwardTrigger = "\<Plug>(DoNothing)"

  let g:ulti_expand_res = 0 "default value, just set once
  function! s:Ulti_Expand_Res()
    call UltiSnips#ExpandSnippet()
    return g:ulti_expand_res
  endfunction

  let g:ulti_jump_forwards_res = 0 "default value, just set once
  function! s:Ulti_Jump_Forwards_Res()
    call UltiSnips#JumpForwards()
    return g:ulti_jump_forwards_res
  endfunction

  let g:ulti_jump_backwards_res = 0 "default value, just set once
  function! s:Ulti_Jump_Backwards_Res()
    call UltiSnips#JumpBackwards()
    return g:ulti_jump_backwards_res
  endfunction
endif

" = vim-colors-solarized =
if Included('vim-colors-solarized')
  let g:solarized_italic = 0
  if !exists(':ToggleBG')     " Needed to initialise togglebg command
    call togglebg#map("")
  endif
  noremap <silent> <F5> :ToggleBG<CR>

endif

" = vim-airline =
if Included('vim-airline')
  set laststatus=2
  set encoding=utf-8
  let g:airline_powerline_fonts = 1
  if !exists('g:airline_symbols')
    let g:airline_symbols = {}
  endif
  let g:airline_symbols.space = "\ua0"
  let g:airline#extensions#whitespace#enabled = 0
  let g:airline#extensions#tabline#enabled = 1
  let g:airline#extensions#tabline#tab_nr_type = 1
  let g:airline#extensions#tabline#show_tab_nr = 1

  " let g:airline_theme = 'solarized'

endif

" = nerdtree =
if Included('nerdtree')
  let g:NERDTreeChDirMode=1
  let NERDTreeCascadeOpenSingleChildDir=1
  nnoremap <leader>n :NERDTree<CR>

endif

" = vim-nerdtree-tabs =
if Included('vim-nerdtree-tabs')
  if Included('nerdtree')
    let g:nerdtree_tabs_open_on_gui_startup=0
    let g:nerdtree_tabs_open_on_new_tab = 1
    nnoremap <silent> ¬ :NERDTreeTabsToggle<CR>
  endif

endif

" = vim-fugitive =
if Included('vim-fugitive')
  ca Gs Gstatus
  nnoremap <leader>gs :silent! Gstatus<CR>
  nnoremap <leader>gd :silent! Gdiff<CR>
  nnoremap <leader>gb :silent! Gblame<CR>
  nnoremap <leader>gp :silent! Git push<CR>
  nnoremap <leader>gy :silent! Git pull<CR>
  nnoremap <leader>gz :silent! Git stash<CR>
  nnoremap <leader>gl :silent! Glog! --<CR>:copen<CR>

endif

" = syntastic =
if Included('syntastic')
  let g:syntastic_auto_loc_list = 2
  let g:syntastic_always_populate_loc_list = 1

  if !s:is_windows && executable(expand('$HOME') . '/.vim/lacheck')
    let g:syntastic_tex_checkers = ['lacheck']
    let g:syntastic_tex_lacheck_exec = expand('$HOME') . '/.vim/lacheck'
  endif

endif

" = vim-easymotion =
if Included('vim-easymotion')
  let g:EasyMotion_leader_key = '<leader>'
  map <leader>e <Plug>(easymotion-prefix)
  map <leader>ew <Plug>(easymotion-bd-wl)
  map <leader>eW <Plug>(easymotion-bd-Wl)
  map <leader>ej <Plug>(easymotion-bd-jk)
  map <leader>ek <Plug>(easymotion-bd-jk)

  " Bi-directional find motion
  " Jump to anywhere you want with minimal keystrokes, with just one key binding.
  " `s{char}{label}`
  nmap <leader>es <Plug>(easymotion-s)
  nmap <leader>e/ <Plug>(easymotion-sn)

  " Turn on case sensitive feature
  let g:EasyMotion_smartcase = 1

  let g:EasyMotion_keys = 'abcdfghijklmnoprstuvxyzqwe'
  let g:EasyMotion_do_shade = 1

endif

" = nerdcommenter =
if Included('nerdcommenter')
  let g:NERDSpaceDelims = 1

endif

" = vim-colorscheme-switcher =
if Included('vim-colorscheme-switcher')
  let g:colorscheme_switcher_exclude = [
        \ 'blue', 'darkblue', 'default', 'delek',
        \ 'desert', 'elflord', 'evening', 'industry',
        \ 'koehler', 'luna-term', 'morning', 'murphy',
        \ 'pablo', 'peachpuff', 'ron', 'shine', 'slate',
        \ 'torte', 'zellner', 'gotham256', 'hybrid-light',
        \ 'Tomorrow-Night', 'Tomorrow-Night-Blue', 'Tomorrow-Night-Eighties',
        \ 'Tomorrow-Night-Bright', 'seoul256-light',
        \ ]

endif

" = vim-togglelist =
if Included('vim-togglelist')
  let g:toggle_list_no_mappings=1
  nnoremap <script> <silent> <leader>w :call ToggleLocationList()<CR>
  nnoremap <script> <silent> <leader>q :call ToggleQuickfixList()<CR>

endif

" = gundo.vim =
if Included('gundo.vim')
  let g:gundo_prefer_python3 = 1
  nnoremap <leader>U :GundoToggle<CR>
endif


" = tagbar =
if Included('tagbar')
  " let g:tagbar_autoupdate_when_tagbar_close = 0
  nnoremap <F9> :TagbarToggle<CR>

endif

" = vim-snipmate =
if Included('vim-snipmate')
  imap <C-J> <Plug>snipMateNextOrTrigger
  smap <C-J> <Plug>snipMateNextOrTrigger

endif

" = supertab =
if Included('supertab')
  let g:SuperTabCrMapping = 0      " Compatibility with delimitMate

endif

" = delimitMate =
if Included('delimitMate')
  let g:delimitMate_expand_cr = 1
  let g:delimitMate_expand_space = 1
  let g:delimitMate_jump_expansion = 1

  " delimitMate overrides
  let delimitMate_leader = "<C-G>"

  let delimitMate_map = [
        \ ['{', '{'],
        \ ['}', '}'],
        \ ['(', '('],
        \ [')', ')'],
        \ ['[', '['],
        \ [']', ']'],
        \ ["\'", "\'"],
        \ ["\"", "\""],
        \ ]

  for each in delimitMate_map
    let cmd = 'inoremap ' . delimitMate_leader . each[0] . ' ' . each[1]
    exe cmd
  endfor

  augroup delimitMateFileType
    au!
    au FileType tex let b:delimitMate_quotes = "\" ' $"
  augroup END
endif

" = vim-over =
if Included('vim-over')
  nnoremap <leader>o :OverCommandLine<CR>

endif

" = vim-interestingwords =
if Included('vim-interestingwords')
  let g:interestingWordsGUIColors = ['#8CCBEA', '#A4E57E', '#FFDB72', '#FF7272', '#FFB3FF', '#9999FF']
  let g:interestingWordsRandomiseColors = 1
  let g:interestingWordsCycleColors = 1
  let g:interestingWordsCaseSensitive = 1

endif

" = vim-mark =
if Included('vim-mark')
  let g:mwDefaultHighlightingPalette = 'maximum'

endif

" = javascript-libraries-syntax.vim =
if Included('javascript-libraries-syntax.vim')
  augroup JavascriptLibraries
    au!
    autocmd BufReadPre *_spec.js let b:javascript_lib_use_jasmine = 1
  augroup END

endif

" = switch.vim =
if Included('switch.vim')
  " let g:switch_custom_definitions = [
  " \   {
  " \     '\<[a-z0-9]\+_\k\+\>': {
  " \       '_\(.\)': '\U\1'
  " \     },
  " \     '\<[a-z0-9]\+[A-Z]\k\+\>': {
  " \       '\([A-Z]\)': '_\l\1'
  " \     },
  " \   }
  " \ ]
  let g:switch_custom_definitions = [
        \   {
        \     '\<[a-zA-Z0-9]\+_\k\+\>': {
        \       '_\(.\)': '\U\1'
        \     },
        \     '\<[a-zA-Z0-9]\+[A-Z]\k\+\>': {
        \       '\(.\)\([A-Z]\)': '\1_\l\2'
        \     },
        \   }
        \ ]
  nnoremap <silent> - :Switch<cr>

endif

" = sideways.vim =
if Included('sideways.vim')
  nnoremap <leader>[ :SidewaysLeft<cr>
  nnoremap <leader>] :SidewaysRight<cr>

endif

" = vim-expand-region =
if Included('vim-expand-region')
  map <leader>= <Plug>(expand_region_expand)
  map <leader>- <Plug>(expand_region_shrink)

endif

" = NrrwRgn =
if Included('NrrwRgn')
  xmap <leader>N <Plug>NrrwrgnDo

endif


" = vim-textobj-user =
if Included('vim-textobj-comment')
  let g:textobj_comment_no_default_key_mappings = 1
  xmap ao <Plug>(textobj-comment-a)
  omap ao <Plug>(textobj-comment-a)
  xmap io <Plug>(textobj-comment-i)
  omap io <Plug>(textobj-comment-i)
  xmap Ao <Plug>(textobj-comment-big-a)
  omap Ao <Plug>(textobj-comment-big-a)

endif

if Included('vim-textobj-delimited')
  let g:textobj_delimited_no_default_key_mappings = 1
  xmap ad <Plug>(textobj-delimited-forward-a)
  omap ad <Plug>(textobj-delimited-forward-a)
  xmap id <Plug>(textobj-delimited-forward-i)
  omap id <Plug>(textobj-delimited-forward-i)

endif

if Included('vim-textobj-between')
  let g:textobj_between_no_default_key_mappings = 1
  xmap at <Plug>(textobj-between-a)
  omap at <Plug>(textobj-between-a)
  xmap it <Plug>(textobj-between-i)
  omap it <Plug>(textobj-between-i)

endif

if Included('vim-textobj-parameter')
  let g:textobj_parameter_no_default_key_mappings = 1
  xmap aa <Plug>(textobj-parameter-a)
  omap aa <Plug>(textobj-parameter-a)
  xmap ia <Plug>(textobj-parameter-i)
  omap ia <Plug>(textobj-parameter-i)

endif

if Included('vim-textobj-brace')
  let g:textobj_brace_no_default_key_mappings = 1
  xmap ab <Plug>(textobj-brace-a)
  omap ab <Plug>(textobj-brace-a)
  xmap ib <Plug>(textobj-brace-i)
  omap ib <Plug>(textobj-brace-i)

endif

" = vim-session =
if Included('vim-session')
  let g:session_autosave = 'no'
  let g:session_autoload = 'no'

endif

" = ag.vim =
if Included('ag.vim')
  nnoremap <leader>a :Ag<Space>
  let g:ag_prg= 'ag --column'

endif

" = rainbow_parentheses.vim =
if Included('rainbow_parentheses.vim')
  let g:rainbow#colors = { 'dark':[
        \ ['red', 'red1'],
        \ ['yellow', 'orange1'],
        \ ['green', 'yellow1'],
        \ ['cyan', 'greenyellow'],
        \ ['magenta', 'green1'],
        \ ['red', 'springgreen1'],
        \ ['yellow', 'cyan1'],
        \ ['green', 'slateblue1'],
        \ ['cyan', 'magenta1'],
        \ ['magenta', 'purple1']]
        \ }

endif

" = vim-endwise =
if Included('vim-endwise')
  let g:endwise_no_mappings = 1
  augroup endwise-custom
    au!
    autocmd FileType tex
        \ let b:endwise_words = '' |
        \ let b:endwise_pattern = '\\begin{\zs[a-zA-Z0-9*]*\ze}' |
        \ let b:endwise_addition = '\\end{&}' |
        \ let b:endwise_syngroups = 'texBeginEndName' |
  augroup END

endif

" = clever-f.vim =
if Included('clever-f.vim')
  let g:clever_f_fix_key_direction = 1

endif

" = jedi-vim =
if Included('jedi-vim')
  let g:jedi#auto_vim_configuration = 0
  let g:jedi#goto_assignments_command = ""
  let g:jedi#goto_definitions_command = ""
  let g:jedi#documentation_command = ""
  let g:jedi#usages_command = ""
  let g:jedi#completions_command = ""
  let g:jedi#rename_command = ""
  autocmd FileType python setlocal omnifunc=jedi#completions

endif

" = vim-peekaboo =
if Included('vim-peekaboo')
  " since <C-R> is mapped over and we want <C-R>= to work as normal
  imap <C-R>= <C-R>=
  cmap <C-R>= <C-R>=
  nmap <C-R>= <C-R>=

endif

" = lightline.vim =
if Included('lightline.vim')
  set laststatus=2
  let g:lightline = {
        \ 'colorscheme': 'solarized',
        \ 'active': {
        \   'left': [ [ 'mode', 'paste' ], [ 'fugitive', 'filename' ], ['ctrlpmark'] ],
        \   'right': [ [ 'syntastic', 'lineinfo' ], ['percent'], [ 'fileformat', 'fileencoding', 'filetype' ] ]
        \ },
        \ 'component_function': {
        \   'fugitive': 'MyFugitive',
        \   'filename': 'MyFilename',
        \   'fileformat': 'MyFileformat',
        \   'filetype': 'MyFiletype',
        \   'fileencoding': 'MyFileencoding',
        \   'mode': 'MyMode',
        \   'ctrlpmark': 'CtrlPMark',
        \ },
        \ 'component_expand': {
        \   'syntastic': 'SyntasticStatuslineFlag',
        \ },
        \ 'component_type': {
        \   'syntastic': 'error',
        \ },
        \ 'separator': { 'left': '', 'right': '' },
        \ 'subseparator': { 'left': '', 'right': '' }
        \ }

  function! MyModified()
    return &ft =~ 'help' ? '' : &modified ? '+' : &modifiable ? '' : '-'
  endfunction

  function! MyReadonly()
    return &ft !~? 'help' && &readonly ? '' : ''
  endfunction

  function! MyFilename()
    let fname = expand('%:t')
    return fname == 'ControlP' ? g:lightline.ctrlp_item :
          \ fname == '__Tagbar__' ? g:lightline.fname :
          \ fname =~ '__Gundo\|NERD_tree' ? '' :
          \ &ft == 'vimfiler' ? vimfiler#get_status_string() :
          \ &ft == 'unite' ? unite#get_status_string() :
          \ &ft == 'vimshell' ? vimshell#get_status_string() :
          \ ('' != MyReadonly() ? MyReadonly() . ' ' : '') .
          \ ('' != fname ? fname : '[No Name]') .
          \ ('' != MyModified() ? ' ' . MyModified() : '')
  endfunction

  function! MyFugitive()
    try
      if expand('%:t') !~? 'Tagbar\|Gundo\|NERD' && &ft !~? 'vimfiler' && exists('*fugitive#head')
        let mark = ''  " edit here for cool mark
        let _ = fugitive#head()
        return strlen(_) ? mark._ : ''
      endif
    catch
    endtry
    return ''
  endfunction

  function! MyFileformat()
    return winwidth(0) > 70 ? &fileformat : ''
  endfunction

  function! MyFiletype()
    return winwidth(0) > 70 ? (strlen(&filetype) ? &filetype : 'no ft') : ''
  endfunction

  function! MyFileencoding()
    return winwidth(0) > 70 ? (strlen(&fenc) ? &fenc : &enc) : ''
  endfunction

  function! MyMode()
    let fname = expand('%:t')
    return fname == '__Tagbar__' ? 'Tagbar' :
          \ fname == 'ControlP' ? 'CtrlP' :
          \ fname == '__Gundo__' ? 'Gundo' :
          \ fname == '__Gundo_Preview__' ? 'Gundo Preview' :
          \ fname =~ 'NERD_tree' ? 'NERDTree' :
          \ &ft == 'unite' ? 'Unite' :
          \ &ft == 'vimfiler' ? 'VimFiler' :
          \ &ft == 'vimshell' ? 'VimShell' :
          \ winwidth(0) > 60 ? lightline#mode() : ''
  endfunction

  function! CtrlPMark()
    if expand('%:t') =~ 'ControlP'
      call lightline#link('iR'[g:lightline.ctrlp_regex])
      return lightline#concatenate([g:lightline.ctrlp_prev, g:lightline.ctrlp_item
            \ , g:lightline.ctrlp_next], 0)
    else
      return ''
    endif
  endfunction

  let g:ctrlp_status_func = {
        \ 'main': 'CtrlPStatusFunc_1',
        \ 'prog': 'CtrlPStatusFunc_2',
        \ }

  function! CtrlPStatusFunc_1(focus, byfname, regex, prev, item, next, marked)
    let g:lightline.ctrlp_regex = a:regex
    let g:lightline.ctrlp_prev = a:prev
    let g:lightline.ctrlp_item = a:item
    let g:lightline.ctrlp_next = a:next
    return lightline#statusline(0)
  endfunction

  function! CtrlPStatusFunc_2(str)
    return lightline#statusline(0)
  endfunction

  let g:tagbar_status_func = 'TagbarStatusFunc'

  function! TagbarStatusFunc(current, sort, fname, ...) abort
    let g:lightline.fname = a:fname
    return lightline#statusline(0)
  endfunction

  augroup AutoSyntastic
    autocmd!
    autocmd BufWritePost *.c,*.cpp call s:syntastic()
  augroup END
  function! s:syntastic()
    SyntasticCheck
    call lightline#update()
  endfunction

  let g:unite_force_overwrite_statusline = 0
  let g:vimfiler_force_overwrite_statusline = 0
  let g:vimshell_force_overwrite_statusline = 0

endif

" = limelight.vim =
if Included('limelight.vim')
  let g:limelight_conceal_ctermfg = 10

endif

" = vim-multiple-cursors =
if Included('vim-multiple-cursors')
  let g:multi_cursor_normal_maps = {'c':1, 'd':1, 'f':1, 'y':1, 't':1, 'r':1}
  let g:multi_cursor_exit_from_insert_mode = 0

  " Called once right before you start selecting multiple cursors
  function! Multiple_cursors_before()
    if exists(':NeoCompleteLock')==2
      exe 'NeoCompleteLock'
    endif
  endfunction

  " Called once only when the multiple selection is canceled (default <Esc>)
  function! Multiple_cursors_after()
    if exists(':NeoCompleteUnlock')==2
      exe 'NeoCompleteUnlock'
    endif
  endfunction

  " let g:multi_cursor_insert_map_tree = {
        " \ ' ': {'a': {}},
        " \ }

  " let s:multi_cursor_ia_textobj = {'w': {}, 'W': {},
        " \ '"': {}, '''': {},
        " \ '{': {}, '}': {},
        " \ '(': {}, ')': {},
        " \ '[': {}, ']': {},
        " \ 'a': {}, '-': {}, 'b': {} }

  " let g:multi_cursor_normal_textobj_tree = {
        " \ 'i': s:multi_cursor_ia_textobj,
        " \ 'a': s:multi_cursor_ia_textobj,
        " \ 'f': {'any': {}},
        " \ 't': {'any': {}},
        " \ '$': {},
        " \ '^': {},
        " \ '%': {},
        " \ }

  " let g:multi_cursor_normal_opfunc_tree = {
        " \ ' ': {'a': {}},
        " \ 'd': {},
        " \ 'y': {},
        " \ 'c': {},
        " \ 'f': {},
        " \ 'r': {},
        " \ }

endif

" =  vim-webdevicons =
if Included('vim-webdevicons')
  let g:webdevicons_enable_airline_tabline = 0

endif

"" =================
""  END PLUGINS CONFIG
"" =================

"" =================
""  MAPPINGS
"" =================

" timeout for key sequences
set timeoutlen=300

" Y to yank till end of line
nnoremap Y y$

" delete buffer without changing window layout
nnoremap <leader>d :Bdelete<CR>

" insert newline in normal mode
nnoremap <S-CR> :call <SID>CustomCR(0)<CR>
nnoremap <C-CR> :call <SID>CustomCR(1)<CR>
nnoremap <silent> <CR> :call <SID>CustomCR(2)<CR>

function! s:CustomCR(mode)
  if &buftype ==# 'quickfix'
    exe "normal! \<CR>"
    return
  elseif &buftype ==# 'help'
    exe "silent! normal! \<C-]>"
    return
  endif
  let fold_status = CheckFold()
  if a:mode == 2
    if fold_status == 3 || fold_status == 4
      normal! zv
      return
    elseif fold_status == 1
      normal! zc
      return
    endif
  endif
  let saveview = winsaveview()
  if (a:mode == 0)
    normal! o
    call winrestview(saveview)
  elseif (a:mode == 1)
    normal! O
    call winrestview(saveview)
  else
    silent! normal! o
  endif
endfunction

" easy vimrc handling
nnoremap <leader>v :e $MYVIMRC<cr>
nnoremap <leader>s :source $MYVIMRC<cr>

" Omnicomplete
inoremap <C-Space> <C-x><C-o>

" map q to close help files
augroup CloseHelpFiles
  au!
  autocmd BufWinEnter * if (&l:buftype ==# 'help' || &l:buftype ==# 'quickfix') | nnoremap <buffer> q :q<CR> | endif
augroup END

" close location and quickfix windows
nnoremap <silent> <leader>x :ccl<CR>:lcl<CR>

" open folds with double click
nnoremap <2-LeftMouse> :call ClickFolds()<CR>

let g:in_double_click_function = 0

function! ClickFolds()
  let fold_status = CheckFold()
  if fold_status == 3 || fold_status == 4
    normal! zv
  elseif fold_status == 1
    normal! zc
  elseif fold_status == 0
    exe "normal! \<2-LeftMouse>"
  endif
endfunction

function! CheckFold()
  " returns 0 - cursor not in fold
  "         1 - cursor at start of open fold
  "         2 - cursor in middle of open fold
  "         3 - cursor at start of closed fold
  "         4 - cursor in middle of closed fold
  if foldclosed(line('.')) != -1
    if foldclosed(line('.')) == line('.')
      " Current line is start of fold and fold is closed
      return 3
    else
      " Current line is middle of fold and fold is closed
      return 4
    endif
  elseif foldlevel(line('.')) != 0
    " Current line is in a fold but the fold is open
    let old_view = winsaveview()
    let current_line = line('.')
    let current_fold_level = foldlevel(current_line)
    " Go to the start of fold
    " case  1: current line is start of fold
    "      a): the fold does not have a parent fold
    "       -> cursor remains at current line
    "      b): the fold has a parent fold
    "       -> cursor moves up (foldlevel will decrease)
    "
    "       2: current line is not start of fold
    "       -> cursor moves up (foldlevel does not decrease)
    normal! [z
    if line('.') == current_line || foldlevel(line('.')) < current_fold_level
      " case 1a: cursor remains at current line
      " case 1b: foldlevel decreased
      " Cursor is at start of open fold
      call winrestview(old_view)
      return 1
    else
      " Cursor is in middle of open fold
      call winrestview(old_view)
      return 2
    endif
  endif
  " Cursor not in fold
  return 0
endfunction

"" =================
""  WINDOWS
"" =================

if executable('gvimfullscreen.dll')
  nnoremap <F11> :call libcallnr('gvimfullscreen.dll', 'ToggleFullScreen', 0)<CR>
endif

vnoremap <BS> d

" CTRL-C CTRL-Insert are Copy
vnoremap <C-C> "+y

" CTRL-V Paste
" noremap <C-V> "+gP

" cnoremap <C-V> <C-R>+


" Use CTRL-Q to do what CTRL-V used to do
" noremap <C-Q> <C-V>

" Use CTRL-S for saving, also in Insert mode
noremap <C-S> :update<CR>
vnoremap <C-S> <C-C>:update<CR>
inoremap <C-S> <C-O>:update<CR>

" CTRL-A is Select all
noremap <C-A> gggH<C-O>G
inoremap <C-A> <C-O>gg<C-O>gH<C-O>G
onoremap <C-A> <C-C>gggH<C-O>G
snoremap <C-A> <C-C>gggH<C-O>G
xnoremap <C-A> <C-C>ggVG

"" =================
""  PROJECT
"" =================

if s:is_windows
  let g:project_dir = '~/vimfiles/bundle/cmd2.vim'
else
  let g:project_dir = '~/.vim/bundle/cmd2.vim'
endif

" Project directory
nnoremap <silent> <leader>r :call OpenProject(1)<CR>

function! OpenProject(nerdtree)
  exe 'cd' g:project_dir
  if (a:nerdtree)
    if Included('nerdtree')
      if Included('vim-nerdtree-tabs')
        NERDTreeTabsOpen
      else
        NERDTree
      endif
    endif
  endif
endfunction

"" =================
""  UI CONFIG
"" =================

" enable mouse
set mouse=a

" remove splash screen
" set shortmess+=Is

" syntax highlighting
syntax enable

" display incomplete commands
set showcmd

" split windows to the right
" not using splitbelow
set splitright

" hide GVIM toolbars
set guioptions-=m
set guioptions-=T
set guioptions-=t
set guioptions-=r
set guioptions-=L
set guioptions-=l

" Initial window is maximised (only works in windows)
if s:is_windows
  augroup FullScreen
    au!
    au GUIEnter * simalt ~x
  augroup END
endif

" GVIM font (custom font for powerline)
" different font names for unix and windows
if s:is_windows
  " set guifont=Inconsolata_for_Powerline:h13:cANSI
  set guifont=Inconsolata_for_Powerline_PNFT_:h13:cANSI
else
  set guifont=Inconsolata\ for\ Powerline\ 13
endif

" highlight current line
" set cursorline

" visual autocomplete for command menu
set wildmenu

" Command <Tab> completion, longest common part, then all.
set wildmode=longest:full,full

" don't use preview window for completion
set completeopt-=preview

" don't redraw during macros
set lazyredraw

" show line numbers
set number

" don't wrap lines
" set nowrap

" Hide GUI tabline
set go-=e

" if a file is changed outside of vim, automatically reload it without asking
set autoread

" allow backspacing over everything
set backspace=2

" Remove error bells
set noerrorbells visualbell t_vb=
augroup ErrorBells
  au!
  autocmd GUIEnter * set visualbell t_vb=
augroup END

" when scrolling, keep cursor 10 lines away from screen border
set scrolloff=10

" remove | characters in window borders
set fillchars+=vert:\     " whitespace needed

" wrap long lines
set wrap

" switch to existing buffer if file exists
set switchbuf=useopen,usetab

" hide buffers when not shown
set hidden

" open diffs in vertical split, show filler lines
set diffopt=vertical,filler

" use directx rendering
if s:is_windows
  " set renderoptions=type:directx,
    " \gamma:1.5,contrast:0.5,geom:1,
    " \renmode:5,taamode:1,level:0.5
endif

" don't conceal characters at cursorline
set concealcursor=

" jump to last known cursor position when file is opened
augroup FileOpen
  au!
  autocmd BufReadPost *
        \ if line("'\"") > 1 && line("'\"") <= line("$") |
        \   exe "normal! g`\"" |
        \ endif
augroup END

" setting syntax colors for vimrc
augroup VimrcSyntax
  au!
  au BufEnter _vimrc,.vimrc call <SID>VimrcComments()
  au SourceCmd _vimrc,.vimrc source $MYVIMRC | call <SID>VimrcComments()
        \ | call <SID>RefreshAirline()
        \ | call s:MakeCmd2AirlineTheme(1)
augroup END

function! s:VimrcComments()
  syntax match VimrcHeaderBorder /\v\"\" \=.*/
  hi link VimrcHeaderBorder SpecialComment

  syntax match VimrcHeader1 /\v\"\" .*/
  hi link VimrcHeader1 SpecialComment

  syntax match VimrcHeader2 /\v\" \=.*/
  hi link VimrcHeader2 SpecialComment

  syntax match VimrcComment /\v\" \>.*/
  hi link VimrcComment vimSet

  syntax match IncludeWord /\v<Include>/
  hi link IncludeWord vimCommand

  syntax match IncludeArgs /\v(<Include>)@<=.*/ contains=IncludeArgsKeyword
  hi link IncludeArgs String

  syntax match IncludeArgsKeyword /\v(\!?has|exe|include|exists|priority|after):/
  hi link IncludeArgsKeyword Statement

  hi! link vimIsCommand Normal
endfunction

function! s:RefreshAirline()
  if Included('vim-airline')
    let g:airline_theme = g:colors_name
    AirlineRefresh
  endif
endfunction

"" =================
""  WHITESPACE
"" =================

" set indentation
set tabstop=2
set expandtab
set shiftwidth=2
set softtabstop=2
set smartindent
set autoindent

" Show trailing whitespace
set list listchars=tab:»·,trail:·

" function for cleaning trailing whitespace
nnoremap <silent> <F10> :call RemoveWhiteSpace()<CR>

" auto-clean trailing whitespace on write
augroup RemoveWhiteSpace
  au!
  autocmd BufWrite * :call <SID>RemoveWhiteSpace()
augroup END

function! s:RemoveWhiteSpace()
  let save_view = winsaveview()
  if exists(':keeppatterns')
    keeppatterns %s/\s\+$//e
  endif
  call winrestview(save_view)
endfunction

"" =================
""  COLORSCHEME
"" =================

if has('gui_running') || &t_Co >= 16

  set background=dark

  " colorscheme solarized
  " colorscheme gotham
  " colorscheme molokai
  " colorscheme badwolf
  " colorscheme luna
  " colorscheme lucius
  " colorscheme jellybeans
  " colorscheme hybrid
  " colorscheme zenburn
  " colorscheme primary
  colorscheme PaperColor

endif

"" =================
""  SEARCH
"" =================

" incremental search

" highlight matches
set hlsearch

" turn off search highlight until next search
nnoremap <silent> <leader>h :noh<CR>

" highlight last inserted text
nnoremap gV `[v`]

function! GetCmdLine()
  let g:cmd = getcmdline()
  let g:cmd_pos = getcmdpos()
  return g:cmd
endfunction
cmap <F7> <C-\>eGetCmdLine()<CR>

" rehighlights the last pasted text
nnoremap <expr> gb '`[' . strpart(getregtype(), 0, 1) . '`]'

"" =================
""  MOVEMENT
"" =================

" hjkl training
map <up> <nop>
map <down> <nop>
map <left> <nop>
map <right> <nop>
imap <up> <nop>
imap <down> <nop>
imap <left> <nop>
imap <right> <nop>

" faster hjkl movement
nnoremap H 5h
nnoremap J 5j
nnoremap K 5k
nnoremap L 5l
xnoremap H 5h
xnoremap J 5j
xnoremap K 5k
xnoremap L 5l

" move between windows
noremap <C-j> <C-W>j
noremap <C-k> <C-W>k
noremap <C-h> <C-W>h
noremap <C-l> <C-W>l

" move between tabs
nnoremap <C-Tab> gt
nnoremap <C-S-Tab> gT

" Allow arrow keys in Visual Block
set keymodel-=stopsel

" move cursor to middle of line
nnoremap gm :call cursor(0, strlen(getline('.'))/2)<CR>

"" =================
""  EDITING
"" =================

" Move a line of text using ALT+[jk] or Comamnd+[jk] on mac
nnoremap <M-j> mz:m+<cr>`z
nnoremap <M-k> mz:m-2<cr>`z
vnoremap <M-j> :m'>+<cr>`<my`>mzgv`yo`z
vnoremap <M-k> :m'<-2<cr>`>my`<mzgv`yo`z

" visual shifting (does not exit Visual mode)
vnoremap < <gv
vnoremap > >gv

" insert only one space when joining lines with punctuation
set nojoinspaces

" join lines (J remapped in as 5j)
nnoremap <leader>j :join<CR>

" unjoin lines
nnoremap <leader>J i<CR><Esc>k$

" Ctrl-Y copies character above line
inoremap <expr> <c-y> (pumvisible() ? "<Esc>a" : <SID>CtrlY())

function! s:CtrlY()
  if Included('neocomplete')
    call neocomplete#close_popup()
  endif
  return strpart(getline(line('.')-1), virtcol('.')-1, 1)
endfunction

" Remap <C-BS> to <Del>
inoremap <C-BS> <Del>

"" =================
""  AUTOCOMPLETE
"" =================

augroup autocomplete
  au!
  autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
  autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
  " autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
  " autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
  autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
augroup END

"" =================
""  BACKUPS
"" =================

" better backup, swap and undos storage
" // at the end so full file path with directories are saved in tmp
set noswapfile
set directory=~/vimfiles/dirs/swap//
set backup
set backupdir=~/vimfiles/dirs/backups//
set undofile
set undodir=~/vimfiles/dirs/undos//
set viminfo+=n~/vimfiles/dirs/viminfo

" create needed directories if they don't exist
if !isdirectory(&backupdir)
  call mkdir(&backupdir, "p")
endif
if !isdirectory(&directory)
  call mkdir(&directory, "p")
endif
if !isdirectory(&undodir)
  call mkdir(&undodir, "p")
endif

"" =================
""  FUNCTIONS
"" =================

" Create scratch buffers
function! ScratchEdit(cmd, options)
  let a:name = tempname()
  exe a:cmd a:name
  setl buftype=nofile bufhidden=wipe nobuflisted
  if !empty(a:options) | exe 'setl' a:options | endif
  let buf_nr = 1
  let scratch_type = 'tmp'
  if (&ft ==# 'javascript')
    let scratch_type = '.js'
  endif
  while 1
    if !bufexists('[' . scratch_type . ' ' . buf_nr . ']')
      break
    endif
    let buf_nr = buf_nr + 1
  endwhile
  let buf_name = '[' . scratch_type . ' ' . buf_nr . ']'
  exe 'silent file' buf_name
endfunction

command! -bar -nargs=* Sedit call ScratchEdit('edit', <q-args>)
command! -bar -nargs=* Ssplit call ScratchEdit('split', <q-args>)
command! -bar -nargs=* Svsplit call ScratchEdit('vsplit', <q-args>)
command! -bar -nargs=* Stabedit call ScratchEdit('tabe', <q-args>)

nnoremap <leader>ts :call ScratchEdit('e', '')<CR>
nnoremap <leader>tj :call ScratchEdit('e', 'ft=javascript')<CR>

"" =================
""  SPLASHSCREEN
"" =================

let g:splash_screen_loaded = 0

if s:is_windows
  let g:splash_screen_file = '~\vimfiles\vim_ANSI.splash'
else
  let g:splash_screen_file = '~\.vim\vim_ANSI.splash'
endif

augroup splashscreen
  au!
  autocmd VimEnter * call SplashScreen()
augroup END

function! RemoveSplashScreen()
  if g:splash_screen_loaded
    au! splashscreen
    au! removesplashscreen
    au! resizesplashscreen
    silent! Bdelete! 1
    if Included('vim-airline')
      let g:airline_section_a = airline#section#create_left(['mode', 'paste', 'capslock', 'iminsert'])
      AirlineRefresh
    endif
  else
    let g:splash_screen_loaded = 1
    nnoremap <silent> <buffer> q :q<CR>
    nnoremap <silent> <buffer> r :call OpenProject(1)<CR>
    nnoremap <silent> <buffer> v :e $MYVIMRC<CR>
    nnoremap <silent> <buffer> t :call ScratchEdit('e', '')<CR>
    nnoremap <silent> <buffer> j :call ScratchEdit('e', 'ft=javascript')<CR>
    nnoremap <silent> <buffer> m :CtrlPMRU<CR>
  endif
endfunction

let g:splash_screen_text =
\ "   ____     _       U  ___ u\n" .
      \ "  |  _\"\\   |\"|       \\/\"_ \\/__        __\n" .
      \ " /| | | |U | | u     | | | |\\\"\\      /\"/\n" .
      \ " U| |_| |\\\\| |/__.-,_| |_| |/\\ \\ /\\ / /\\\n" .
      \ "  |____/ u |_____|\\_)-\\___/U  \\ V  V /  U\n" .
      \ "   |||_    //  \\\\      \\\\  .-,_\\ /\\ /_,-.\n" .
      \ "  (__)_)  (_\")(\"_)    (__)  \\_)-'  '-(_/\n" .
      \ "\n" .
      \ "Vim $VIMVERSION"


function! SplashScreen()
  if !argc()
    setl
          \ nonumber
          \ nocursorline
          \ nocursorcolumn
          \ buftype=nofile
          \ bufhidden=wipe
          \ nobuflisted
          \ nolist
          \ nowrap
    let status_line_command = 'setl statusline=' . escape($VIMRUNTIME, ' \/')
    exe status_line_command
    if exists('g:splash_screen_file') && filereadable(expand(g:splash_screen_file))
      let g:splash_screen_file_text = join(readfile(expand(g:splash_screen_file)), "\n")
      put =g:splash_screen_file_text
    elseif exists('g:splash_screen_text')
      put =g:splash_screen_text
    else
      put =g:splash_screen_default
    endif
    silent! call RemoveWhiteSpace()
    let maxcol = 0
    let lnum = 1
    while lnum <= line("$")
      call cursor(lnum, 0)
      let countcol = Countcol(lnum)
      if countcol > maxcol
        let maxcol = countcol
      endif
      let lnum += 1
    endwhile
    let patch_no = GetPatchNo()
    let version_no = version[0] . '.' . substitute(version[1:-1], '0\+', '', '') . (patch_no ? '.' . patch_no : '')
    exe 'silent file Vim\' version_no
    if Included('vim-airline')
      let g:airline_section_a = airline#section#create([$VIMRUNTIME,'',''])
    endif
    silent! /\$VIMVERSION/
    call histdel('/', -1)
    exe 's/\$VIMVERSION/'version_no'/e'
    call histdel('/', -1)
    let align_spaces = repeat(' ', (maxcol - col('$'))/2)
    exe 'normal! I' align_spaces
    let old_a = @a
    silent exe 'normal! gg"ayG'
    let g:splash_screen_contents = @a
    let @a = old_a
    augroup resizesplashscreen
      autocmd VimResized <buffer> call JustifyContents()
    augroup END
    call JustifyContents()
    " AnsiEsc
  endif
  au! splashscreen
endfunction

function! Countcol(line)
  let line = getline(a:line)
  let line = substitute(line, '\[\(\d\|;\)\{-}m', '', 'g')
  return strdisplaywidth(line)
endfunction

function! AuRemoveSplashScreen()
  augroup removesplashscreen
    autocmd TextChanged,TabLeave,WinEnter,CursorMoved,InsertEnter * call RemoveSplashScreen()
  augroup END
endfunction

function! GetPatchNo()
  let major_version = v:version/100
  let minor_version = v:version - major_version*100
  let patch_no = 999
  while patch_no > 0
    if has("patch" . patch_no)
      break
    endif
    let patch_no -= 1
  endwhile
  return patch_no
endfunction

function! JustifyContents()
  silent! au! removesplashscreen
  let save_view = winsaveview()
  exe 'normal! gg"_dG'
  put =g:splash_screen_contents
  let maxcol = 0
  let lnum = 1
  while lnum <= line("$")
    call cursor(lnum, 0)
    let countcol = Countcol(lnum)
    if countcol > maxcol
      let maxcol = countcol
    endif
    let lnum += 1
  endwhile
  let lnum = 1
  let old_search = @/
  exe '%s/^/'(repeat(' ', (winwidth(0) - maxcol)/2))'/'
  let @/ = old_search
  call cursor(1, 0)
  let lines_to_add = max([0, winheight(0) - line('$')])/2
  exe ('normal! ' . lines_to_add . 'O')
  call cursor(line('$'), 1)
  exe ('normal! ' . (winheight(0) - line('$')) . 'o')
  silent! call RemoveWhiteSpace()
  call winrestview(save_view)
  call AuRemoveSplashScreen()
endfunction

"" =================
""  WINSLIDE
"" =================

" function! OpenVerticalWindow(height)
  " let height = a:height
  " res 0
  " let current = 0
  " let time = 0
  " while current < height
    " let current = printf('%.0f', floor(LinearTween(round(time), round(0), round(height), round(10.0))))
    " if current >= height - 1
      " break
    " endif
    " execute "res " . current
    " redraw
    " let time += 1
    " sleep 1m
  " endwhile
  " execute "res" . height
" endfunction

" function! OpenHorizontalWindow(width)
  " let old_wrap  = &wrap
  " setl nowrap
  " let width = a:width
  " vertical res 0
  " let current = 0
  " let time = 0
  " let factor = width/180.0
  " while current < width
    " let current = printf('%.0f', floor(EaseOutExpo(round(time), round(0), round(width), round(factor * 30.0))))
    " if current >= width - 1
      " break
    " endif
    " execute "vertical res " . current
    " redraw
    " let time += 1
    " sleep 1m
  " endwhile
  " let &wrap = old_wrap
  " execute "vertical res" . width
" endfunction

" function! OpenHorizontal(command, ...)
  " let old_wrap = &wrap
  " if a:0 > 0 && a:1 == 'left'
    " let old_splitright = &splitright
    " set nosplitright
  " endif
  " setl nowrap
  " execute a:command
  " call OpenHorizontalWindow(winwidth(0))
  " let &wrap = old_wrap
  " if a:0 > 0 && a:1 == 'left'
    " let &splitright = old_splitright
  " endif
" endfunction

" function! OpenVertical(command, ...)
  " let old_wrap = &wrap
  " if a:0 > 0 && a:1 == 'left'
    " let old_splitright = &splitright
    " set nosplitright
  " endif
  " setl nowrap
  " execute a:command
  " call OpenVerticalWindow(winheight(0))
  " let &wrap = old_wrap
  " if a:0 > 0 && a:1 == 'left'
    " let &splitright = old_splitright
  " endif
" endfunction

" " nnoremap <C-Down> :call OpenVertical(':h')<CR>
" " nnoremap <C-Up> :call OpenVertical(":to split $MYVIMRC")<CR>

" " nnoremap <C-Left> :call OpenHorizontal(':NERDTree', 'left')<CR>
" " nnoremap <C-Right> :call OpenHorizontal(':GundoToggle', 'right')<CR>

" " t = current time, b = start, c = change, d = duration
" function! LinearTween(t, b, c, d)
  " return a:c * a:t / a:d + a:b
" endfunction

" function! EaseOutQuad(t, b, c, d)
  " let t = a:t / a:d
  " return -a:c * t * (t-2) + a:b
" endfunction

" function! EaseOutExpo(t, b, c, d)
  " return a:c * ( -pow(2, -10 * a:t/a:d ) + 1 ) + a:b
" endfunction

" function! EaseOutCirc(t, b, c, d)
  " let t = a:t / a:d
  " let t -= 1
  " return a:c * sqrt(1 - t * t) + a:b
" endfunction

"" =================
""  CONSOLE VIM
"" =================

if !empty($CONEMUBUILD)
  set term=xterm
  let &t_AB="\e[48;5;%dm"
  let &t_AF="\e[38;5;%dm"
  set t_Co=256
  let g:solarized_termcolors = 16
  set background=dark
  colorscheme PaperColor
  set termencoding=utf8
  " termcap codes for cursor shape changes on entry and exit to
  " /from insert mode
  " doesn't work
  "let &t_ti="\e[1 q"
  "let &t_SI="\e[5 q"
  "let &t_EI="\e[1 q"
  "let &t_te="\e[0 q"
endif

if !has('gui_running')
  " instant handling of Esc
  set ttimeoutlen=0

endif

"" =================
""  OTHERS
"" =================
filetype plugin on
:nnoremap <F9> :setl noai nocin nosi inde=<CR>
