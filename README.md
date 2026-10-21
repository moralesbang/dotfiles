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

### Skills

`.claude/skills/` queda fuera de git. Las skills `work-*` y las de Matt Pocock se
instalan desde work-harness (`skills/README.md`).

No instales skills para todos los agentes; el hook `block-skills-all-agents.sh` lo impide.

### Hooks locales

`.claude/hooks/local/` queda fuera de git. Si existe `session-start.sh` ahí,
`SessionStart` lo ejecuta: es el lugar para integraciones propias de cada máquina.

## ccstatusline

`~/.config/ccstatusline` es un symlink a `~/Projects/dotfiles/.config/ccstatusline`;
Claude Code lo usa vía `statusLine` (`bunx -y ccstatusline@latest`).
