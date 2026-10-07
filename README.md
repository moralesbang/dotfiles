# Bang's dotfiles

## Claude Code

La carpeta `~/.claude` es un symlink a `~/Projects/dotfiles/.claude`.
Git incluye la configuración, instrucciones, skills locales, hooks, scripts y temas.
Los historiales, sesiones, cachés, plugins descargados, skills sincronizadas y otros
datos locales permanecen en esa carpeta, pero están excluidos por `.gitignore`.
`~/.claude.json` permanece fuera del repo.

Para enlazar en otra instalación, cuando `~/.claude` no exista:

```sh
ln -s "$HOME/Projects/dotfiles/.claude" "$HOME/.claude"
```

Si ya existe, respáldala y combina su contenido antes de crear el symlink.
