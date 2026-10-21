# FAQ

## Why does `:Commands` fail with fzf's “invalid border style” error?

This occurs when the installed `fzf.vim` plugin passes an option that the fzf
binary selected by Vim does not support. The diagnostic captured in
`/tmp/tmptmp` showed the `:Commands` invocation passing:

```text
--list-border --header-border inline --info inline-right --no-separator
```

In the checked setup, the versions were:

- `fzf.vim` source: a newer checkout that uses `--header-border inline` for
  `:Commands` (and for some other commands).
- Selected executable: `~/.vim/bundle/fzf/bin/fzf`, version **0.71.0**.
- The `inline` header-border style was added in fzf **0.72.0**.

Thus fzf 0.71 rejects `inline` as an invalid border style. This is a
plugin/binary version mismatch, not a problem with Vim's command list. Vim's
fzf integration selects the newest version it finds among the fzf binary on
`PATH` and the binary bundled in the fzf plugin. In this setup, the bundled
0.71 executable was selected over `/usr/bin/fzf` 0.67 and `~/.fzf/bin/fzf`
0.45. The generic minimum-version check does not detect this newer,
command-specific option requirement.

### Fix

In Vim, run:

```vim
:call fzf#install()
```

This runs the checked-out fzf install script with `--bin`, updating the
plugin's bundled executable without changing shell configuration. The current
installer in this checkout targets fzf **0.74.5**. Restart Vim after it
finishes so the plugin selects the updated executable.

Verify the path and version in Vim with:

```vim
:echo fzf#exec()
:echo system(fzf#exec() . ' --version')
```

The selected executable should be `~/.vim/bundle/fzf/bin/fzf` and its version
should be at least 0.72.0. Updating only the `fzf.vim` source is not sufficient
if its bundled fzf executable remains old. The installed distro fzf 0.67 and
`~/.fzf/bin/fzf` 0.45 are also too old for this option.
