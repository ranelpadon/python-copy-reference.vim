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


function! python_copy_reference#_get_module(path_format, separator)
    let file_path = expand(a:path_format)
    " Truncate files opened with full paths using CWD.
    let file_path = fnamemodify(file_path, ":.")
    let module = python_copy_reference#_remove_prefixes(file_path)

    if a:separator == '.'
        let module = substitute(module, '\/', a:separator, 'g')
    endif

    return module
endfunction


function! python_copy_reference#_get_attribute_parts(allow_nested)
    let current_word = expand('<cword>')
    let pattern = '\v^(class|def|async)'

    if match(current_word, pattern) == -1
        return []
    endif

    let current_column = col('.')
    let name = python_copy_reference#_get_nearest_name()

    " `def`/`class` is already at the gutter/edge.
    if current_column == 1
        " Return the file path + function/class.
        return [name]
    elseif !a:allow_nested
        return []
    else
        call python_copy_reference#_jump_to_parent()
        let parent_name = python_copy_reference#_get_nearest_name()

        " Return the file path + function/class + inner function/class/method.
        return [parent_name, name]
    endif
endfunction


function! python_copy_reference#_remove_prefixes(file_path)
    if !has_key(g:python_copy_reference, 'remove_prefixes')
        return a:file_path
    endif

    for path in g:python_copy_reference['remove_prefixes']
        let pattern = '^' . path . '/'

        if match(a:file_path, pattern) == 0
            return substitute(a:file_path, pattern, '', 'g')
        endif
    endfor

    return a:file_path
endfunction


function! python_copy_reference#_get_reference(format)
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
        let allow_nested = 1
    elseif a:format == 'pytest'
        " Path format (with file extension): foo/bar/baz.py
        let path_format = '%:p:.'
        let separator = '::'
        let allow_nested = 1
    elseif a:format == 'import'
        " Path format (without file extension): foo/bar/baz
        let path_format = '%:r'
        let separator = '.'
        let allow_nested = 0
    endif

    let module = python_copy_reference#_get_module(path_format, separator)
    let attribute_parts = python_copy_reference#_get_attribute_parts(allow_nested)
    let reference = join([module] + attribute_parts, separator)

    " Go back to marked/initial cursor for better UX.
    execute 'normal! `X'

    return reference
endfunction


function! python_copy_reference#dotted()
    let reference = python_copy_reference#_get_reference('dotted')
    echomsg 'Copied reference: ' . reference
    let @+ = reference
endfunction


function! python_copy_reference#pytest()
    let reference = python_copy_reference#_get_reference('pytest')
    echomsg 'Copied reference: ' . reference
    let @+ = reference
endfunction


function! python_copy_reference#import()
    let reference = python_copy_reference#_get_reference('import')

    " Convert 'x.y.z' into 'x.y import z'
    let reference = substitute(reference, '^\(.*\)\.\([^.]*\)$', '\1 import \2', 'g')
    let reference = 'from ' . reference

    " Copy to system clipboard.
    echomsg 'Copied reference: ' . reference
    let @+ = reference
endfunction
