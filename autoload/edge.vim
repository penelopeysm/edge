" =============================================================================
" URL: https://github.com/sainnhe/edge
" Filename: autoload/edge.vim
" Author: sainnhe
" Email: i@sainnhe.dev
" License: MIT License
" =============================================================================

function! edge#get_configuration() "{{{
  return {
        \ 'style': get(g:, 'edge_style', 'default'),
        \ 'dim_foreground': get(g:, 'edge_dim_foreground', 0),
        \ 'transparent_background': get(g:, 'edge_transparent_background', 0),
        \ 'dim_inactive_windows': get(g:, 'edge_dim_inactive_windows', 0),
        \ 'disable_italic_comment': get(g:, 'edge_disable_italic_comment', 0),
        \ 'enable_italic': get(g:, 'edge_enable_italic', 0),
        \ 'cursor': get(g:, 'edge_cursor', 'auto'),
        \ 'menu_selection_background': get(g:, 'edge_menu_selection_background', 'blue'),
        \ 'spell_foreground': get(g:, 'edge_spell_foreground', 'none'),
        \ 'show_eob': get(g:, 'edge_show_eob', 1),
        \ 'float_style': get(g:, 'edge_float_style', 'bright'),
        \ 'current_word': get(g:, 'edge_current_word', get(g:, 'edge_transparent_background', 0) == 0 ? 'grey background' : 'bold'),
        \ 'inlay_hints_background': get(g:, 'edge_inlay_hints_background', 'none'),
        \ 'lightline_disable_bold': get(g:, 'edge_lightline_disable_bold', 0),
        \ 'diagnostic_text_highlight': get(g:, 'edge_diagnostic_text_highlight', 0),
        \ 'diagnostic_line_highlight': get(g:, 'edge_diagnostic_line_highlight', 0),
        \ 'diagnostic_virtual_text': get(g:, 'edge_diagnostic_virtual_text', 'grey'),
        \ 'disable_terminal_colors': get(g:, 'edge_disable_terminal_colors', 0),
        \ 'better_performance': get(g:, 'edge_better_performance', 0),
        \ 'colors_override': get(g:, 'edge_colors_override', {}),
        \ }
endfunction "}}}
function! edge#get_palette(style, dim_foreground, colors_override) "{{{
  if &background ==# 'light' "{{{
    let palette = {
          \ '...General foreground and background...': [],
          \ 'fg':         ['#8a7178',   '240'],
          \ 'bg0':        ['#faf5f8',   '231'],
          \
          \ '...Syntax highlighting...': [],
          \ 'red':        ['#eb6c7f',   '167'],
          \ 'yellow':     ['#cea14b',   '172'],
          \ 'blue':       ['#5dade2',   '68'],
          \ 'green':      ['#53b865',   '107'],
          \ 'purple':     ['#cc89d9',   '134'],
          \ 'cyan':       ['#409fab',   '73'],
          \
          \ '...Folds foreground and background...': [],
          \ 'grey':       ['#bfa1a9',   '245'],
          \ 'bg1':        ['#faf0f7',   '255'],
          \
          \ '...Various other background colours...': [],
          \ 'bg_green':   ['#1bbf7d',   '107'],
          \ 'bg_blue':    ['#59a4db',   '68'],
          \ 'bg_red':     ['#ee718b',   '167'],
          \ 'bg_purple':  ['#bc7af3',   '134'],
          \ '...Background for visually selected text...': [],
          \ 'bg3':        ['#f0e8f0',   '253'],
          \ '...Background for matching parens etc...': [],
          \ 'bg4':        ['#f0e8f0',   '253'],
          \
          \ '...Lightline (I made these different variables...': [],
          \ 'bg_normal':    ['#e063b9',   '107'],
          \ 'bg_insert':    ['#2ab0f7',   '134'],
          \ 'bg_command':   ['#b46cf0',   '68'],
          \ 'bg_visual':    ['#68ba7d',   '167'],
          \ 'bg_replace':   ['#bc7af3',   '134'],
          \ 'bg_terminal':  ['#bc7af3',   '134'],
          \ 'bg_lightline': ['#f7e6f2',   '253'],
          \
          \ '...Diffs...': [],
          \ 'diff_red':   ['#f5dfdf',   '217'],
          \ 'diff_green': ['#d9edd8',   '150'],
          \ 'diff_blue':  ['#dbebee',   '153'],
          \ 'diff_yellow':['#fcf5e5',   '183'],
          \
          \ '...I have not changed the stuff below...': [],
          \ 'bg_grey':    ['#bcc5cf',   '246'],
          \ 'black':      ['#dde2e7',   '253'],
          \ 'grey_dim':   ['#bac3cb',   '249'],
          \ 'bg_dim':     ['#e8ebf0',   '254'],
          \ 'bg2':        ['#e8ebf0',   '254'],
          \ 'none':       ['NONE',      'NONE']
          \ } "}}}
  else
    throw 'To use this fork of edge, background must be set to light'
  endif
  return extend(palette, a:colors_override)
endfunction "}}}
function! edge#highlight(group, fg, bg, ...) "{{{
  execute 'highlight' a:group
        \ 'guifg=' . a:fg[0]
        \ 'guibg=' . a:bg[0]
        \ 'ctermfg=' . a:fg[1]
        \ 'ctermbg=' . a:bg[1]
        \ 'gui=' . (a:0 >= 1 ?
          \ a:1 :
          \ 'NONE')
        \ 'cterm=' . (a:0 >= 1 ?
          \ a:1 :
          \ 'NONE')
        \ 'guisp=' . (a:0 >= 2 ?
          \ a:2[0] :
          \ 'NONE')
endfunction "}}}
function! edge#syn_gen(path, last_modified, msg) "{{{
  " Generate the `after/syntax` directory.
  let full_content = join(readfile(a:path), "\n") " Get the content of `colors/edge.vim`
  let syn_conent = []
  let rootpath = edge#syn_rootpath(a:path) " Get the path to place the `after/syntax` directory.
  call substitute(full_content, '" syn_begin.\{-}syn_end', '\=add(syn_conent, submatch(0))', 'g') " Search for 'syn_begin.\{-}syn_end' (non-greedy) and put all the search results into a list.
  for content in syn_conent
    let syn_list = []
    call substitute(matchstr(matchstr(content, 'syn_begin:.\{-}{{{'), ':.\{-}{{{'), '\(\w\|-\)\+', '\=add(syn_list, submatch(0))', 'g') " Get the file types. }}}}}}
    for syn in syn_list
      call edge#syn_write(rootpath, syn, content) " Write the content.
    endfor
  endfor
  call edge#syn_write(rootpath, 'text', "let g:edge_last_modified = '" . a:last_modified . "'") " Write the last modified time to `after/syntax/text/edge.vim`
  let syntax_relative_path = has('win32') ? '\after\syntax' : '/after/syntax'
  if a:msg ==# 'update'
    echohl WarningMsg | echom '[edge] Updated ' . rootpath . syntax_relative_path | echohl None
    call edge#ftplugin_detect(a:path)
  else
    echohl WarningMsg | echom '[edge] Generated ' . rootpath . syntax_relative_path | echohl None
    execute 'set runtimepath+=' . fnamemodify(rootpath, ':p') . 'after'
  endif
endfunction "}}}
function! edge#syn_write(rootpath, syn, content) "{{{
  " Write the content.
  let syn_path = a:rootpath . '/after/syntax/' . a:syn . '/edge.vim' " The path of a syntax file.
  " create a new file if it doesn't exist
  if !filereadable(syn_path)
    call mkdir(a:rootpath . '/after/syntax/' . a:syn, 'p')
    call writefile([
          \ "if !exists('g:colors_name') || g:colors_name !=# 'edge'",
          \ '    finish',
          \ 'endif'
          \ ], syn_path, 'a') " Abort if the current color scheme is not edge.
    call writefile([
          \ "if index(g:edge_loaded_file_types, '" . a:syn . "') ==# -1",
          \ "    call add(g:edge_loaded_file_types, '" . a:syn . "')",
          \ 'else',
          \ '    finish',
          \ 'endif'
          \ ], syn_path, 'a') " Abort if this file type has already been loaded.
  endif
  " If there is something like `call edge#highlight()`, then add
  " code to initialize the palette and configuration.
  if matchstr(a:content, 'edge#highlight') !=# ''
    call writefile([
          \ 'let s:configuration = edge#get_configuration()',
          \ 'let s:palette = edge#get_palette(s:configuration.style, s:configuration.dim_foreground, s:configuration.colors_override)'
          \ ], syn_path, 'a')
  endif
  " Append the content.
  call writefile(split(a:content, "\n"), syn_path, 'a')
  " Add modeline.
  call writefile(['" vim: set sw=2 ts=2 sts=2 et tw=80 ft=vim fdm=marker fmr={{{,}}}:'], syn_path, 'a')
endfunction "}}}
function! edge#syn_rootpath(path) "{{{
  " Get the directory where `after/syntax` is generated.
  if (matchstr(a:path, '^/usr/share') ==# '') " Return the plugin directory. The `after/syntax` directory should never be generated in `/usr/share`, even if you are a root user.
    return fnamemodify(a:path, ':p:h:h')
  else " Use vim home directory.
    if has('nvim')
      return stdpath('config')
    else
      return expand('~') . '/.vim'
    endif
  endif
endfunction "}}}
function! edge#syn_newest(path, last_modified) "{{{
  " Determine whether the current syntax files are up to date by comparing the last modified time in `colors/edge.vim` and `after/syntax/text/edge.vim`.
  let rootpath = edge#syn_rootpath(a:path)
  execute 'source ' . rootpath . '/after/syntax/text/edge.vim'
  return a:last_modified ==# g:edge_last_modified ? 1 : 0
endfunction "}}}
function! edge#syn_clean(path, msg) "{{{
  " Clean the `after/syntax` directory.
  let rootpath = edge#syn_rootpath(a:path)
  " Remove `after/syntax/**/edge.vim`.
  let file_list = split(globpath(rootpath, 'after/syntax/**/edge.vim'), "\n")
  for file in file_list
    call delete(file)
  endfor
  " Remove empty directories.
  let dir_list = split(globpath(rootpath, 'after/syntax/*'), "\n")
  for dir in dir_list
    if globpath(dir, '*') ==# ''
      call delete(dir, 'd')
    endif
  endfor
  if globpath(rootpath . '/after/syntax', '*') ==# ''
    call delete(rootpath . '/after/syntax', 'd')
  endif
  if globpath(rootpath . '/after', '*') ==# ''
    call delete(rootpath . '/after', 'd')
  endif
  if a:msg
    let syntax_relative_path = has('win32') ? '\after\syntax' : '/after/syntax'
    echohl WarningMsg | echom '[edge] Cleaned ' . rootpath . syntax_relative_path | echohl None
  endif
endfunction "}}}
function! edge#syn_exists(path) "{{{
  return filereadable(edge#syn_rootpath(a:path) . '/after/syntax/text/edge.vim')
endfunction "}}}
function! edge#ftplugin_detect(path) "{{{
  " Check if /after/ftplugin exists.
  " This directory is generated in earlier versions, users may need to manually clean it.
  let rootpath = edge#syn_rootpath(a:path)
  if filereadable(edge#syn_rootpath(a:path) . '/after/ftplugin/text/edge.vim')
    let ftplugin_relative_path = has('win32') ? '\after\ftplugin' : '/after/ftplugin'
    echohl WarningMsg | echom '[edge] Detected ' . rootpath . ftplugin_relative_path | echohl None
    echohl WarningMsg | echom '[edge] This directory is no longer used, you may need to manually delete it.' | echohl None
  endif
endfunction "}}}

" vim: set sw=2 ts=2 sts=2 et tw=80 ft=vim fdm=marker fmr={{{,}}}:
