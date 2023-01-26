python-copy-reference.vim
=========================
Inspired by PyCharm's `Copy Reference` feature. Copies the reference of a Python module/class/method/function so that you could discuss it with colleagues or use it to run unit tests in a separate terminal tab/tmux window. Supports the dotted (Python's `unittest`/Django's `manage.py test`) or Pytest format.


Introduction
------------
PyCharm has a [Copy Reference feature](https://www.jetbrains.com/help/pycharm/working-with-source-code.html#copy_paste) which creates a reference string for the target Python module/class/method/function name in the current line. The copied reference is useful in various scenarios:
- running the automated tests (Python's `unittest`, Django's `manage.py test`, `pytest`, etc)
- discussing the reference with other devs (e.g. in Code Reviews)
- importing the reference in Python REPL

PyCharm has that feature for a long time. But VS Code [refused](https://github.com/Microsoft/vscode/issues/12518) to implement it. And there's no VS Code extension similar to it yet. This is one of the Vim plugins I was seeking also before, but couldn't find it, so I created it.


Module/Class/Method/Function Reference
--------------------------------------
Assuming that we have `apps/foo/bar.py` file with the given codes. The commented lines are the copied reference if the cursor is at the line with `def`/`class` keyword.

- Dotted Format (ala-PyCharm's `Copy Reference`)
    ```python
    """
    Default value (elsewhere in the file):
    apps.foo.bar
    """

    # apps.foo.bar.function_1
    def function_1():
        pass


    # apps.foo.bar.function_2
    async def function_2():
        pass


    # apps.foo.bar.function_decorator
    def function_decorator():

        # apps.foo.bar.function_decorator.inner_function
        def inner_function():
            pass


    # apps.foo.bar.Baz
    class Baz():

        # apps.foo.bar.Baz.Meta
        class Meta:
            pass

        # apps.foo.bar.Baz.method_1
        def method_1(self):
            pass
    ```

- Pytest Format
    ```python
    """
    Default value (elsewhere in the file):
    apps/foo/bar.py
    """

    # apps/foo/bar.py::function_1
    def function_1():
        pass


    # apps/foo/bar.py::function_2
    async def function_2():
        pass


    # apps/foo/bar.py::function_decorator
    def function_decorator():

        # apps/foo/bar.py::function_decorator::inner_function
        def inner_function():
            pass


    # apps/foo/bar.py::Baz
    class Baz():

        # apps/foo/bar.py::Baz::Meta
        class Meta:
            pass

        # apps/foo/bar.py::Baz::method_1
        def method_1(self):
            pass
    ```

- Import Format
    ```python
    """
    Default value (elsewhere in the file):
    from apps.foo import bar
    """

    # from app.foo.bar import function_1
    def function_1():
        pass

    # from apps.foo.bar import Baz
    class Baz():

        # from apps.foo import bar
        class Meta:
            pass

        # from apps.foo import bar
        def method_1(self):
            pass

    ```

For example, when the cursor is placed anywhere in this line:

`def method_1(self):`

Then, the copied reference will be `apps.foo.bar.Baz.method_1` (for the Dotted format), which could be used to run the that specific test (assuming it is a test case/method). Likewise, a message will be displayed in the status line for better UX:

`Copied reference: apps.foo.bar.Baz.method_1`

The `pytest` format is included since `pytest` is quite popular. Interestingly, PyCharm [still not addressed](https://intellij-support.jetbrains.com/hc/en-us/community/posts/115000094324-Change-Pycharm-s-Copy-Reference-path-format) the feature request to support the `pytest` format in its `Copy Reference` feature.


Installation
------------

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'ranelpadon/python-copy-reference.vim'
```


Mappings
--------
There are no default mappings, but could easily create them. For example:
```
nnoremap <Leader>rd :PythonCopyReferenceDotted<CR>
nnoremap <Leader>rp :PythonCopyReferencePytest<CR>
nnoremap <Leader>ri :PythonCopyReferenceImport<CR>
```


Usage
-----
Just place the cursor anywhere in the line with your target class/method/function name. Once you pressed your mappings, the reference will be copied in the system clipboard. Then, you could paste it anywhere.

You can also optionally configure the behaviour of the plugin using the following settings inside the mapping: `let g:python_copy_reference = {"setting": "value"}`.

- `remove_prefixes` - an array of strings to be removed at the beginning of a copied path e.g. `["src"]`.

Testing
-------
This project uses [Vader](https://github.com/junegunn/vader.vim) to run the tests. After installing Vader, run the tests like this:

```bash
vim -c 'Vader! test/*'
```
