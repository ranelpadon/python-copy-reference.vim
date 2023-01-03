let g:python_copy_reference = get(g:, 'python_copy_reference', {})

function! python_copy_reference#_jump_to_parent()
    " Specialized version of `Python_jump`:
    " https://github.com/vim/vim/blob/v8.2.5172/runtime/ftplugin/python.vim#L88

    " Move to the start of line so that inner `def`/`class` will not be included in search.
    normal! 0

    " `v` to avoid escaping `()` and `|`.
    let pattern = '\v^(class|def|async def)'
    " `b` flag to search backward.
    let flags = 'Wb'

    " Search the nearest `def`/`class` backward.
    call search(pattern, flags)
endfunction


function! python_copy_reference#_get_nearest_name()
    " Move to next word if it's not `def`/`class` yet.
    if expand('<cword>') == 'async'
        execute 'normal! w'
    endif

    execute 'normal! w'

    return expand('<cword>')
endfunction


function! python_copy_reference#_get_reference(path_format, separator)
    let file_path = expand(a:path_format)
    let reference = python_copy_reference#_remove_prefixes(file_path)

    if a:separator == '.'
        let reference = substitute(reference, '\/', a:separator, 'g')
    endif

    let current_word = expand('<cword>')
    let pattern = '\v^(class|def|async)'
    if match(current_word, pattern) == -1
        " Return the file path.
        return reference
    endif

    let current_column = col('.')
    let name = python_copy_reference#_get_nearest_name()

    " `def`/`class` is already at the gutter/edge.
    if current_column == 1
        " Return the file path + function/class.
        return reference . a:separator . name
    else
        call python_copy_reference#_jump_to_parent()
        let parent_name = python_copy_reference#_get_nearest_name()

        " Return the file path + function/class + inner function/class/method.
        return reference . a:separator . parent_name . a:separator . name
    endif
endfunction

function! python_copy_reference#_remove_prefixes(reference)
  if !has_key(g:python_copy_reference, 'remove_prefixes')
    return a:reference
  endif

  for path in g:python_copy_reference['remove_prefixes']
    let pattern = '^' . path . '/'

    if match(a:reference, pattern) == 0
      return substitute(a:reference, pattern, "", "g")
    endif
  endfor

  return a:reference
endfunction


function! python_copy_reference#_copy_reference(format)
    " Mark the current cursor/column location.
    " Use `X` instead of `x` to minimize collision with user's marks.
    execute 'normal! mX'

    " The cursor could be in an indented/nested function/class/method.
    " So, move the cursor to the start of line to check if it has `def`/`class` keyword.
    execute 'normal! ^'

    if a:format == 'dotted'
        " Path format (without file extension): foo/bar/baz
        let path_format = '%:r'
        let separator = '.'
    elseif a:format == 'pytest'
        " Path format (with file extension): foo/bar/baz.py
        let path_format = '%:p:.'
        let separator = '::'
    endif

    let reference = python_copy_reference#_get_reference(path_format, separator)
    echomsg 'Copied reference: ' . reference

    " Copy to system clipboard.
    let @+ = reference

    " Go back to marked/initial cursor for better UX.
    execute 'normal! `X'
endfunction


function! python_copy_reference#dotted()
    call python_copy_reference#_copy_reference('dotted')
endfunction


function! python_copy_reference#pytest()
    call python_copy_reference#_copy_reference('pytest')
endfunction
