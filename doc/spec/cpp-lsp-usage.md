# C/C++ LSP with clangd

This Vim configuration uses `vim-lsp` as the LSP client and
`vim-lsp-settings` to register the `clangd` server for C and C++ buffers. It
resolves `clangd` and the C++ compiler from `PATH`, so the same vimrc works with
Linux distro packages and Homebrew LLVM on macOS.

## Install and prerequisites

Install a clangd toolchain and make it available on `PATH`:

```bash
# macOS (Homebrew)
brew install llvm
export PATH="$(brew --prefix llvm)/bin:$PATH"

# Debian/Ubuntu Linux
sudo apt install clangd g++
```

For project-aware diagnostics, provide a current `compile_commands.json` for
the project (for example, by configuring CMake with
`-DCMAKE_EXPORT_COMPILE_COMMANDS=ON`). clangd takes each file's working
directory, defines, language standard, and explicit project include paths from
that database. Make sure it was generated using the same ROS distribution and
compiler that are used to build the project.

## Configuration

The `vim-lsp` setup resolves the tools dynamically:

```vim
let s:clangd = exepath('clangd')
if empty(s:clangd)
    let s:clangd = 'clangd'
endif
let s:cpp_compiler = exepath('clang++')
if empty(s:cpp_compiler)
    let s:cpp_compiler = exepath('c++')
endif
let s:clangd_cmd = [s:clangd]
if !empty(s:cpp_compiler)
    call add(s:clangd_cmd, '--query-driver=' . s:cpp_compiler)
endif
let g:lsp_settings['clangd']['cmd'] = s:clangd_cmd
```

ALE uses the same resolved `clangd` executable and compiler-query path. If a
project's compilation database invokes a different compiler, make that compiler
available on `PATH` (or adjust the resolution in `vimrc`) so clangd can query
the matching toolchain.

## Why `--query-driver` is used

The C++ standard library's implicit include paths normally do not appear as
`-I` arguments in `compile_commands.json`; the compiler supplies them itself.
clangd can infer these paths, but when several GCC versions are installed its
guess can differ from the compiler selected by the build. For example, clangd
may then fail to resolve standard headers such as `<filesystem>` and report
cascading errors in otherwise valid code.

`--query-driver=<compiler>` is an allowlist: it permits clangd to run that
specific compiler to discover its built-in include paths and target details.
It does **not** add or hard-code header directories. Keep the resolved path
aligned with the compiler command in the database, rather than choosing a
different compiler merely because it has a higher version number.

`vim-lsp-settings` searches `PATH` before its private server directory, so a
system or Homebrew `clangd` on `PATH` is used directly. Its clangd installer
also uses a clangd already on `PATH` when one exists; `:LspInstallServer clangd`
therefore does not necessarily create an isolated local copy. A user-managed
copy can become stale or disagree with the host toolchain.

## Verify

Check the compiler and server selected by the shell:

```bash
command -v clangd clang++ c++
clangd --version
clang++ --version  # or c++ if the project uses that compiler
```

After changing the Vim configuration, restart Vim or restart the LSP server.
The resolved server command and `--query-driver` path should appear in
`~/vim-lsp.log`. If errors remain, check
that the current file has an entry in the project's compilation database and
that the database uses the installed ROS distribution (currently
`/opt/ros/lyrical`).
