# C/C++ LSP with clangd

This Vim configuration uses `vim-lsp` as the LSP client and
`vim-lsp-settings` to register the `clangd` server for C and C++ buffers. On
this Ubuntu machine, it intentionally uses the system clangd rather than a
second copy downloaded into vim-lsp-settings' private server directory.

## Install and prerequisites

Install the distro-provided server and the C++ toolchain:

```bash
sudo apt install clangd g++
```

For project-aware diagnostics, provide a current `compile_commands.json` for
the project (for example, by configuring CMake with
`-DCMAKE_EXPORT_COMPILE_COMMANDS=ON`). clangd takes each file's working
directory, defines, language standard, and explicit project include paths from
that database. Make sure it was generated using the same ROS distribution and
compiler that are used to build the project.

## Configuration

The `vim-lsp` clangd configuration in `vimrc` is:

```vim
let g:lsp_settings = get(g:, 'lsp_settings', {})
let g:lsp_settings['clangd'] = get(g:lsp_settings, 'clangd', {})
let g:lsp_settings['clangd']['cmd'] = ['/usr/bin/clangd', '--query-driver=/usr/bin/c++']
```

ALE has its own clangd invocation, so the configuration also points it at the
system server and passes the same compiler-query option:

```vim
let g:ale_cpp_clangd_executable = '/usr/bin/clangd'
let g:ale_cpp_clangd_options = '--query-driver=/usr/bin/c++'
```

These settings choose the system clangd and allow it to query the compiler
used by the compile commands. On the current machine, `/usr/bin/c++` resolves
to G++ 15.2.0. If a project's compilation database invokes a different
compiler, change the query-driver path to match that compiler executable.

## Why `--query-driver` is used

The C++ standard library's implicit include paths normally do not appear as
`-I` arguments in `compile_commands.json`; the compiler supplies them itself.
clangd can infer these paths, but when several GCC versions are installed its
guess can differ from the compiler selected by the build. For example, clangd
may then fail to resolve standard headers such as `<filesystem>` and report
cascading errors in otherwise valid code.

`--query-driver=/usr/bin/c++` is an allowlist: it permits clangd to run that
specific compiler to discover its built-in include paths and target details.
It does **not** add or hard-code header directories. Keep the path aligned with
the compiler command in the database, rather than choosing a different
compiler merely because it has a higher version number.

`vim-lsp-settings` searches `PATH` before its private server directory, so the
system `/usr/bin/clangd` is a first-class choice. Its clangd installer also
uses a clangd already on `PATH` when one exists; `:LspInstallServer clangd`
therefore does not necessarily create an isolated local copy. A user-managed
copy can become stale or disagree with the host toolchain.

## Verify

Check the compiler and server selected by the shell:

```bash
command -v clangd c++
clangd --version
c++ --version
```

After changing the Vim configuration, restart Vim or restart the LSP server.
The new server command should appear in `~/vim-lsp.log` with both
`/usr/bin/clangd` and `--query-driver=/usr/bin/c++`. If errors remain, check
that the current file has an entry in the project's compilation database and
that the database uses the installed ROS distribution (currently
`/opt/ros/lyrical`).
