" Title:        Python Copy Reference
" Description:  A plugin to Copy Reference of a Python class/method/function.
" Maintainer:   Ranel Padon<https://github.com/ranelpadon>

" Prevents the plugin from being loaded multiple times. If the loaded
" variable exists, do nothing more. Otherwise, assign the loaded
" variable and continue running this instance of the plugin.
if exists("g:loaded_python_copy_reference")
    finish
endif

let g:loaded_python_copy_reference = 1

" Exposes the plugin's functions for use as commands in Vim.
command! -nargs=0 PythonCopyReferenceDotted call python_copy_reference#dotted()
command! -nargs=0 PythonCopyReferencePytest call python_copy_reference#pytest()
