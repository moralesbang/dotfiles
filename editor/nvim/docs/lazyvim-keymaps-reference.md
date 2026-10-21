# Referencia de mappings y arquitectura de LazyVim

## Alcance y versión consultada

- **Consulta:** 2026-10-03, exclusivamente sobre fuentes oficiales y en modo read-only para la configuración local.
- **LazyVim:** versión **16.0.1**, commit [`999700997f72227187d49d8b92667183dc7fc809`](https://github.com/LazyVim/LazyVim/commit/999700997f72227187d49d8b92667183dc7fc809), publicado el 2026-09-08. Es el `main` devuelto por GitHub durante esta consulta; los enlaces al código de este documento están fijados a ese commit. [Versión][version]
- **Dependencias examinadas para entender el mecanismo:** `folke/snacks.nvim` en `882c996cf28183f4d63640de0b4c02ec886d01f2` (2026-05-25), `folke/lazy.nvim` en `306a05526ada86a7b30af95c5cc81ffba93fef97` (2025-12-17) y `folke/which-key.nvim` en `3aab2147e74890957785941f0c1ad87d0a44c15a` (2025-10-28). Son snapshots adicionales consultados, **no un lockfile que garantice las versiones instaladas de cualquier usuario**. [Snacks][snacks-keymap], [lazy.nvim][lazy-keys], [which-key][wk-docs]
- Se contrastó el código con [el catálogo oficial de keymaps](https://www.lazyvim.org/keymaps), [su configuración](https://www.lazyvim.org/configuration/keymaps), [las reglas de plugins](https://www.lazyvim.org/configuration/plugins) y [la configuración LSP](https://www.lazyvim.org/plugins/lsp). El sitio es documentación viva; cuando falta una entrada o hay ambigüedad, aquí prevalece el código fijado.
- El inventario es estático: no se inició una instalación de LazyVim ni se validó en ejecución el soporte de capabilities de cada servidor LSP.
- No se modificaron mappings, plugins ni cambios existentes del usuario. La única incorporación al repositorio es este archivo. La configuración local usa `vim.pack`, no `lazy.nvim`, y conserva la separación indicada por `.config/nvim/CLAUDE.md`.

## 1. Conclusión: una gramática compartida, no un archivo enorme

Lo más trasladable de LazyVim es su **vocabulario de acciones** y la separación entre **acción**, **contexto**, **implementación** y **ayuda visual**. No todos sus mappings están en `config/keymaps.lua`: una configuración efectiva combina varios propietarios. [Core][core], [plugins][editor], [LSP][lsp-spec], [extras seleccionados][defaults]

| Capa | Ubicación upstream | Qué aporta |
| --- | --- | --- |
| Core | `lua/lazyvim/config/keymaps.lua` | Movimientos, buffers, ventanas, diagnósticos, terminales y acciones globales. También llama a Snacks y utilidades de LazyVim: «core» no significa «sin plugins». |
| Plugins predeterminados | `lua/lazyvim/plugins/editor.lua`, `ui.lua`, `util.lua`, `formatting.lua`, etc. | `keys` al lado de la configuración del plugin; también mappings en `on_attach`, `opts` o helpers. |
| LSP | `plugins/lsp/init.lua` → `opts.servers["*"].keys` y `opts.servers.<server>.keys` | Mappings buffer-local condicionados por cliente, capabilities y `enabled`. |
| Providers predeterminados seleccionables | `plugins/extras/editor/snacks_picker.lua`, `snacks_explorer.lua`, `extras/coding/blink.lua`, etc. | Implementaciones elegidas de picker, explorer y completion. Estar bajo `extras/` **no implica necesariamente que sean opt-in**. |
| Extras realmente opcionales | `plugins/extras/dap/core.lua`, `test/core.lua`, lenguajes, etc. | Amplían o reemplazan acciones cuando están habilitados. |
| Usuario | `lua/config/keymaps.lua` y specs propios bajo `lua/plugins/` | Overrides globales, de plugins y de servidores, cada uno en su capa correcta. |
| Descubrimiento | `which-key` → `opts.spec`, `group`, `desc`, `proxy`, `expand` | Presenta la gramática y los mappings disponibles; no es la implementación de todas las acciones. |

El catálogo web reúne capas y extras, e incluso muestra algunos mappings LSP duplicados por provider. **No es una lista de todo lo que está activo en cualquier instalación** ni incluye necesariamente los creados en callbacks. Por ejemplo, los hunks de Gitsigns se definen en `on_attach`, los movimientos de Treesitter en `FileType`, y `Run Lua` usa `ft = "lua"` dentro del archivo core. [Catálogo][catalog], [Gitsigns][gitsigns], [Treesitter][ts-moves], [Lua core][core-tail]

## 2. Carga, orden y ownership

### Orden observado

1. `lazyvim.plugins` llama a `require("lazyvim.config").init()`. Este añade LazyVim al runtimepath y carga **options antes del init de lazy.nvim**. Los defaults fijan `<leader>` a espacio y `<localleader>` a `\`. [Bootstrap][bootstrap], [init de options][init-options], [leaders][options]
2. La configuración de options se carga primero desde `lazyvim.config.options` y luego desde `config.options` del usuario, mediante el mismo `M.load` usado para las otras categorías. [Loader][config-load]
3. Las specs de plugins se importan y se combinan. El orden externo esperado es **`lazyvim.plugins` → extras → `plugins` del usuario**; LazyVim lo comprueba. Los extras de `lazyvim.json` y los providers por defecto se recopilan y ordenan también en `plugins/xtras.lua`. [Comprobación][import-order], [extras][xtras]
4. `LazyVim.setup` registra un callback para `User VeryLazy`; allí carga `keymaps`. En lazy.nvim, `VeryLazy` ocurre después de `LazyDone` y de procesar los autocmds de `VimEnter`. [Setup][setup], [evento][verylazy]
5. `M.load("keymaps")` carga **defaults primero, usuario después**: `lazyvim.config.keymaps` → `User LazyVimKeymapsDefaults` → `config.keymaps` → `User LazyVimKeymaps`. `defaults.keymaps = false` permite omitir los defaults, pero no el archivo del usuario. [Loader][config-load], [default configurable][version]
6. Las specs `keys` pueden haber reservado una combinación antes de que se cargue el core. `safe_keymap_set` evita pisar las combinaciones que lazy.nvim ya administra. Más tarde aparecen mappings buffer-local al attach de Gitsigns, al cliente LSP o al filetype correspondiente. [Safe wrapper][safe], [handler lazy][lazy-keys], [Gitsigns][gitsigns], [Snacks keymap][snacks-keymap]

**No hay un único «último archivo gana» universal:** una spec se resuelve por identidad y modo; un mapping buffer-local prevalece sobre el global del mismo modo; un callback posterior puede registrar otra implementación. Desactivar un mapping de plugin en el archivo de mappings globales no elimina su spec ni su registro contextual. Las instrucciones oficiales distinguen estos canales por esa razón. [Overrides oficiales][custom-keymaps], [plugin overrides][custom-plugins], [resolución lazy][lazy-keys], [LSP contextual][snacks-keymap]

### Providers actuales y diferencias entre instalaciones

Para una instalación nueva, este snapshot elige **Snacks picker**, **Snacks explorer** y **blink.cmp**. Puede cambiar por `vim.g.lazyvim_picker`, `vim.g.lazyvim_explorer`, `vim.g.lazyvim_cmp`, o por extras explícitos. Instalaciones con `install_version < 8` conservan como primera elección **fzf** y **neo-tree**. Por eso una guía antigua puede describir FzfLua, Telescope o Neo-tree sin que sea la configuración nueva actual. [Selección y compatibilidad][defaults]

Snacks y LazyVim se cargan con `lazy = false`; otros plugins pueden cargarse por `event`, `cmd`, `ft` o `keys`. Elegir otro picker no elimina todas las dependencias de Snacks: el core sigue usando sus terminales, toggles, buffers, Git, etc. [Bootstrap][bootstrap], [Core][core], [lazy loading][lazy-loading]

## 3. Cómo representan los mappings

### Core: función pequeña más opciones explícitas

Ejemplos reales de `config/keymaps.lua`:

```lua
local map = LazyVim.safe_keymap_set

map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", {
  desc = "Down", expr = true, silent = true,
})

map({ "n", "x" }, "<leader>cf", function()
  LazyVim.format({ force = true })
end, { desc = "Format" })
```

`j` se mueve por líneas visuales si no hay count y por líneas reales si lo hay. `expr = true` evalúa una expresión o usa las teclas devueltas por una función; no debe interpretarse como «ejecutar un comando cualquiera». `desc` es texto de ayuda, no lógica de ejecución. Las llamadas usan comandos cuando basta y closures cuando hay selección de contexto o un API. [Ejemplos core][core-edit], [Format][core-code]

### Qué hace realmente `safe_keymap_set`

- Convierte el modo en una lista y filtra cada modo consultando `lazy.core.handler.handlers.keys:have(lhs, mode)`.
- Omite los modos que lazy.nvim administra; esto protege, por ejemplo, los overrides de `[b` y `]b` por Bufferline o `[q` y `]q` por Trouble.
- Define `silent = true` salvo `silent = false` explícito.
- En esta versión, si llega `remap = true` y **no** se está en VSCode, elimina esa opción. El core escribe `remap = true` en algunos mappings de ventanas para permitir integración con VSCode, pero en Neovim normal no se conserva.
- Delega en **`Snacks.keymap.set`**, que entiende `ft`, `lsp` y `enabled`, además de las opciones normales. Por eso el core puede declarar `<localleader>r` con `ft = "lua"`.
- **No es un detector general de colisiones:** no compara toda la configuración del usuario ni todos los mappings existentes mediante `maparg`; su check específico es la reserva de lazy.nvim por `lhs` y modo.
- **No inventa `desc`:** casi todas las acciones lo incluyen, pero puntuación de undo e indentación no lo hacen.

El propio archivo dice expresamente: **no usar `LazyVim.safe_keymap_set` en la configuración del usuario; usar `vim.keymap.set`**. No es un helper portátil para `vim.pack`. [Implementación][safe], [advertencia][core-edit], [handler `have`][lazy-keys], [Snacks keymap][snacks-keymap]

### Plugins: `keys` es mapping y mecanismo de carga

Ejemplo real del explorer seleccionado:

```lua
keys = {
  { "<leader>fe", function()
    Snacks.explorer({ cwd = LazyVim.root() })
  end, desc = "Explorer Snacks (root dir)" },
  { "<leader>fE", function()
    Snacks.explorer()
  end, desc = "Explorer Snacks (cwd)" },
  { "<leader>e", "<leader>fe", desc = "Explorer Snacks (root dir)", remap = true },
}
```

En una spec lazy, `[1]` es `lhs`, `[2]` es `rhs`, `mode` por defecto es `"n"`, `ft` limita a buffers de esos filetypes, y las demás opciones se pasan al mapping. Aquí `remap = true` **sí importa**: el alias `<leader>e` debe ejecutar el mapping `<leader>fe`, no escribir sus teclas literalmente. [Explorer][explorer], [keys spec][lazy-loading]

lazy.nvim instala un handler temporal: al pulsar la tecla carga los plugins asociados, reemplaza el handler por el mapping real y reinyecta `lhs`. Si `rhs` no está presente, `config()` del plugin debe crear el mapping real. El handler final pasa las opciones declaradas a `vim.keymap.set`; **no debe atribuirse a todos los `keys` el default `silent = true` del wrapper de LazyVim**. [Implementación lazy][lazy-keys]

### Modos y contexto

| Identificador | Significado |
| --- | --- |
| `n` | Normal |
| `i` | Insert |
| `x` | Visual, sin Select |
| `v` | Visual y Select; no es exactamente lo mismo que `x` |
| `s` | Select |
| `o` | Operator-pending |
| `c` | Command-line |
| `t` | Terminal-job |

El inventario conserva los modos del código: mover líneas usa `v`, mientras que format y code actions usan `x`. Una misma tecla puede tener dueños distintos sin colisión si cambian modo o buffer: `<C-k>` navega ventanas en `n`, da signature help en `i` con LSP, y tiene comportamiento propio en un terminal/picker. [Core][core-edit], [LSP][lsp-keys], [terminal][terminal-keys], [picker interno][picker-defaults]

`nowait = true`, presente en `gr`, evita esperar una continuación de una combinación más larga; `remap = true` permite que el RHS invoque otros mappings; `expr = true` devuelve teclas según el contexto. No son defaults intercambiables. [LSP][lsp-keys], [Explorer][explorer], [Noice][noice]

## 4. Gramática: prefijos, parejas y alcance

Los siguientes grupos están declarados por which-key para `n` y `x`. Las glosas mnemónicas son una interpretación del vocabulario elegido, no un parser que fuerce todos los sufijos. [Grupos upstream][which-key]

| Prefijo | Grupo declarado / idea |
| --- | --- |
| `<leader>b` | `buffer` |
| `<leader>c` | `code`: format, rename, diagnostics de línea, code actions, symbols |
| `<leader>d` | `debug`; `<leader>dp` es `profiler` |
| `<leader>f` | `file/find`: files, explorer, recent, terminal |
| `<leader>g` | `git`; `<leader>gh` es `hunks` |
| `<leader>q` | `quit/session` |
| `<leader>s` | `search`: grep y búsqueda de entidades |
| `<leader>u` | `ui`: toggles, inspección, colorscheme |
| `<leader>w` | `windows`, proxy de `<C-w>` |
| `<leader>x` | `diagnostics/quickfix` |
| `<leader><tab>` | `tabs`, distintos de buffers |
| `[` / `]` | `prev` / `next`: buffer, diagnostic, hunk, todo, function... |
| `g` | `goto`; `gs` se anuncia como `surround` |
| `z` | `fold` y comportamiento nativo relacionado |

Una categoría declarada no garantiza que estén implementadas todas sus acciones. Por ejemplo, `debug` existe en which-key aunque DAP sea opcional, y `gs` aparece como grupo aunque `mini.surround` sea un extra. Los accesos directos más frecuentes evitan un subgrupo: `<leader><space>` files, `<leader>/` grep, `<leader>,` buffers, `<leader>e` explorer y `<leader>:` command history. [Grupos][which-key], [picker][picker-keys], [explorer][explorer], [surround opcional][surround]

### Root no es lo mismo que cwd

`LazyVim.root()` detecta la raíz **del buffer actual** con prioridad:

1. workspace folders / `root_dir` de los clientes LSP del buffer;
2. el ancestro con los patrones configurados, por defecto `.git` o `lua`;
3. cwd como fallback.

La primera categoría con resultados gana; dentro de ella se priorizan paths más profundos. La selección se cachea por buffer y se invalida en eventos como `LspAttach`, `BufWritePost`, `DirChanged` y `BufEnter`. `LazyVim.root.git()` busca además un ancestro `.git` desde la raíz detectada. Por tanto, **root no es siempre el Git root ni el cwd del proceso**. [Implementación root][root]

`LazyVim.pick(command, opts)` devuelve una closure, no abre el picker al leer la spec. Cuando se ejecuta, asigna `opts.cwd = LazyVim.root(...)` si no hay cwd explícito y `root ~= false`. Las variantes cwd usan `{ root = false }`; la raíz se decide al ejecutar la acción. [Adaptador][pick]

| Pareja / combinación | Diferencia real |
| --- | --- |
| `<leader>ff` / `<leader>fF` | Files en root / files en cwd |
| `<leader>sg` / `<leader>sG` | Grep en root / grep en cwd |
| `<leader>sw` / `<leader>sW` | Palabra o selección en root / cwd |
| `<leader>fe` / `<leader>fE`, `<leader>e` / `<leader>E` | Explorer en root / cwd |
| `<leader>ft` / `<leader>fT` | Terminal en root / cwd |
| `<leader>gg` / `<leader>gG` | Lazygit en Git root detectado / cwd |
| `<leader>gl` / `<leader>gL` | Git log en Git root detectado / cwd, en el core; un provider puede reemplazar `gl` |
| `<leader>fr` / `<leader>fR` | Recientes / recientes filtrados por cwd, con Snacks; no asumir que es una pareja root/cwd idéntica a `ff/fF` |
| `<leader>uf` / `<leader>uF` | Autoformat global / override del buffer |
| `<leader>ghs` / `<leader>ghS` | Stage hunk / stage buffer |
| `[h` / `[H`, `]h` / `]H` | Hunk anterior / primero; siguiente / último |

Fuentes de estas parejas: [picker][picker-keys], [explorer][explorer], [core Git/terminal][core-tail], [format toggles][format-util], [Gitsigns][gitsigns].

**Mayúscula no significa «incluye ignorados».** En `fF/sG/sW` cambia cwd; en `fB` amplía buffers; en `gI/gP` amplía el estado de issues/PRs; en `uF` cambia scope. Con Snacks, ocultos e ignorados son opciones distintas (`hidden`, `ignored`) y toggles internos `<A-h>` / `<A-i>`; files los desactiva por defecto. [Picker LazyVim][picker-keys], [Snacks files][picker-files], [toggles internos][picker-defaults]

## 5. Inventario completo del archivo core

Se agrupan aliases y pares en una fila, manteniendo sus modos y condiciones. Son **99 `lhs` textuales distintos** en `config/keymaps.lua` de este snapshot, contando toggles y mappings condicionales; no es el total de mappings de la distribución ni de combinaciones `(modo, lhs)`, y algunos aliases pueden equivaler al mismo keycode en un terminal. No todos quedan activos si hay overrides de plugins. Fuente de toda esta sección: [core completo][core].

### Movimiento, edición y ventanas básicas

| Teclas | Modos | Acción / detalle |
| --- | --- | --- |
| `j`, `<Down>` | `n`, `x` | Abajo; `gj` sin count, `j` con count |
| `k`, `<Up>` | `n`, `x` | Arriba; `gk` sin count, `k` con count |
| `<C-h>`, `<C-j>`, `<C-k>`, `<C-l>` | `n` | Ventana izquierda, abajo, arriba, derecha |
| `<C-Up>`, `<C-Down>` | `n` | Altura `+2` / `-2` |
| `<C-Left>`, `<C-Right>` | `n` | Anchura `-2` / `+2` |
| `<A-j>`, `<A-k>` | `n`, `i`, `v` | Mover línea/selección abajo/arriba; normal y visual respetan count |
| `<Esc>` | `i`, `n`, `s` | Limpiar `hlsearch`, detener snippet y devolver Escape |
| `n`, `N` | `n`, `x`, `o` | Siguiente/anterior resultado, independientemente de la dirección de búsqueda; normal añade `zv` |
| `,`, `.`, `;` | `i` | Insertar carácter y breakpoint de undo; sin `desc` |
| `<C-s>` | `i`, `x`, `n`, `s` | Guardar y volver a Normal |
| `<leader>K` | `n` | Ejecutar el `K` nativo (`keywordprg`), aunque LSP tenga su propio `K` |
| `<`, `>` | `x` | Indentar y conservar selección con `gv`; sin `desc` |
| `gco`, `gcO` | `n` | Añadir comentario debajo / encima |

Fuente: [core, líneas 7–92][core-edit]. Los aliases de navegación de buffers y ventanas pueden tener implementación posterior de plugins.

### Buffers, archivos, listas y diagnósticos

| Teclas | Modos | Acción / detalle |
| --- | --- | --- |
| `<S-h>`, `[b` | `n` | Buffer anterior; base `bprevious` |
| `<S-l>`, `]b` | `n` | Buffer siguiente; base `bnext` |
| `<leader>bb`, `` <leader>` `` | `n` | Buffer alternativo (`e #`) |
| `<leader>bd` | `n` | `Snacks.bufdelete()` |
| `<leader>bo` | `n` | Eliminar otros buffers |
| `<leader>bi` | `n` | Eliminar buffers invisibles |
| `<leader>bD` | `n` | `:bd`, eliminación de buffer y ventana según el comportamiento nativo |
| `<leader>fn` | `n` | Archivo/buffer nuevo, `enew` |
| `<leader>xl` | `n` | Abrir/cerrar location list, con manejo de error |
| `<leader>xq` | `n` | Abrir/cerrar quickfix, con manejo de error |
| `[q`, `]q` | `n` | Item anterior/siguiente de quickfix; Trouble puede reemplazarlos |
| `<leader>cf` | `n`, `x` | Format forzado mediante `LazyVim.format` |
| `<leader>cd` | `n` | Diagnósticos de línea en float |
| `[d`, `]d` | `n` | Diagnóstico anterior/siguiente |
| `[e`, `]e` | `n` | Error anterior/siguiente |
| `[w`, `]w` | `n` | Warning anterior/siguiente |

Los saltos de diagnósticos usan `vim.diagnostic.jump`, respetan count y muestran float. Los diagnósticos globales no requieren un mapping LSP buffer-local. [Core buffers][core-edit], [listas y código][core-code]

### Toggles e inspección

Todos los siguientes son `n`. Se crean mediante `Snacks.toggle(...):map(...)`, salvo `ur`, `ui` y `uI`. [Core toggles][core-toggle], [core final][core-tail]

| Teclas | Acción / scope |
| --- | --- |
| `<leader>uf`, `<leader>uF` | Autoformat global / buffer |
| `<leader>us` | Spelling |
| `<leader>uw` | Wrap |
| `<leader>uL` | Relative number |
| `<leader>ul` | Line numbers |
| `<leader>ud` | Diagnostics |
| `<leader>uc` | Conceal level: `0` / valor activo |
| `<leader>uA` | Tabline: `0` / valor activo |
| `<leader>uT` | Treesitter highlight |
| `<leader>ub` | Background light/dark |
| `<leader>uD` | Dimming |
| `<leader>ua` | Animations |
| `<leader>ug` | Indent guides |
| `<leader>uS` | Smooth scroll |
| `<leader>dpp` | Profiler |
| `<leader>dph` | Profiler highlights |
| `<leader>uh` | Inlay hints, si existe `vim.lsp.inlay_hint` |
| `<leader>ur` | Clear search + diff update + redraw |
| `<leader>ui` | Inspect position (`vim.show_pos`) |
| `<leader>uI` | Inspect Treesitter tree |
| `<leader>wm`, `<leader>uZ` | Zoom |
| `<leader>uz` | Zen |

El toggle recibe `get`, `set` y nombre. `:map` genera `desc = "Toggle " .. name` y registra la acción; su integración con which-key añade descripción e icono dinámicos según el estado (`Enable ...` / `Disable ...`). No hay que duplicar esa lógica dentro de cada mapping. El global de autoformat se usa si el buffer no tiene override. [Toggle implementation][snacks-toggle], [format scope][format-util]

### Git, terminal, splits, tabs y utilidades

| Teclas | Modos | Acción / condición |
| --- | --- | --- |
| `<leader>gg`, `<leader>gG` | `n` | Lazygit en Git root / cwd; solo si `lazygit` es ejecutable |
| `<leader>gl`, `<leader>gL` | `n` | Git log en Git root / cwd, con Snacks picker |
| `<leader>gb` | `n` | Git log de la línea actual (`git_log_line`) |
| `<leader>gf` | `n` | Historial Git del archivo actual |
| `<leader>gB` | `n`, `x` | Abrir URL Git en navegador |
| `<leader>gY` | `n`, `x` | Copiar URL Git al registro `+` |
| `<leader>ft`, `<leader>fT` | `n` | Toggle terminal en root / cwd |
| `<C-/>`, `<C-_>` | `n`, `t` | Focus/create terminal en root; si ya tiene foco, ocultar; segundo mapping con `which_key_ignore` |
| `<leader>-` | `n` | Split debajo |
| `<leader>\|` | `n` | Split a la derecha |
| `<leader>wd` | `n` | Cerrar ventana |
| `<leader><tab><tab>` | `n` | Tab nuevo |
| `<leader><tab>f`, `<leader><tab>l` | `n` | Primer/último tab |
| `<leader><tab>[`, `<leader><tab>]` | `n` | Tab anterior/siguiente |
| `<leader><tab>d` | `n` | Cerrar tab |
| `<leader><tab>o` | `n` | Cerrar otros tabs |
| `<leader>qq` | `n` | Quit all (`qa`, no `qa!`) |
| `<leader>l` | `n` | Interfaz de lazy.nvim |
| `<leader>L` | `n` | Changelog de LazyVim |
| `<localleader>r` | `n`, `x` | Ejecutar Lua con Snacks debug; buffer-local para `ft = "lua"` |

Fuente: [core, líneas 167–215][core-tail], [acción Lazy][core-code]. El comentario upstream dice «floating terminal», pero el mapping no especifica float: en el snapshot de Snacks consultado, un shell sin `cmd` se abre por defecto abajo; un `cmd` explícito por defecto en float. El estilo es configurable. No asumir una ventana flotante por el comentario. [Terminal backend][snacks-terminal]

## 6. Snacks picker/explorer: inventario del provider predeterminado nuevo

Fuente de todos los mappings globales de picker siguientes: [`snacks_picker.lua`, líneas 58–112][picker-keys]. Modo `n`, excepto donde se indique. No son mappings del archivo core, aunque se activen por defecto en una instalación nueva.

### Accesos frecuentes y archivos

| Teclas | Acción |
| --- | --- |
| `<leader><space>`, `<leader>ff` | Files en root |
| `<leader>/`, `<leader>sg` | Grep en root |
| `<leader>,`, `<leader>fb` | Buffers |
| `<leader>:` , `<leader>sc` | Command history |
| `<leader>n` | Notification history |
| `<leader>fB` | Todos los buffers: `{ hidden = true, nofile = true }` |
| `<leader>fc` | Files del directorio de configuración |
| `<leader>fF` | Files en cwd |
| `<leader>fg` | Git files |
| `<leader>fr` | Recent |
| `<leader>fR` | Recent filtrado por cwd |
| `<leader>fp` | Projects |
| `<leader>fe`, `<leader>e` | Explorer en root; `e` es alias con remap |
| `<leader>fE`, `<leader>E` | Explorer en cwd; `E` es alias con remap |

Explorer tiene su propia spec seleccionable: [source][explorer]. `fB` no es «files con ignorados»: `hidden` ahí significa buffers no listados, no archivos ocultos del filesystem. [Tipos de buffers Snacks][picker-buffers]

### Git y búsqueda de entidades

| Teclas | Acción |
| --- | --- |
| `<leader>gd` | Git diff, hunks |
| `<leader>gD` | Git diff con `{ base = "origin", group = true }` |
| `<leader>gs` | Git status |
| `<leader>gS` | Git stash |
| `<leader>gi`, `<leader>gI` | GitHub issues abiertas / todos los estados |
| `<leader>gp`, `<leader>gP` | GitHub PRs abiertas / todos los estados |
| `<leader>sb` | Líneas del buffer |
| `<leader>sB` | Grep sobre buffers abiertos |
| `<leader>sG` | Grep en cwd |
| `<leader>sw`, `<leader>sW` | Palabra/selección en root / cwd, modos `n`, `x` |
| `<leader>sp` | Buscar specs de plugins de lazy.nvim |
| `<leader>s"` | Registers |
| `<leader>s/` | Search history |
| `<leader>sa` | Autocmds |
| `<leader>sC` | Commands |
| `<leader>sd` | Diagnostics |
| `<leader>sD` | Diagnostics del buffer |
| `<leader>sh` | Help pages |
| `<leader>sH` | Highlights |
| `<leader>si` | Icons |
| `<leader>sj` | Jumps |
| `<leader>sk` | Keymaps |
| `<leader>sl` | Location list |
| `<leader>sM` | Man pages |
| `<leader>sm` | Marks |
| `<leader>sR` | Resume último picker |
| `<leader>sq` | Quickfix |
| `<leader>su` | Undotree |
| `<leader>uC` | Colorschemes |

Este provider también sustituye `gd/gr/gI/gy` del LSP, añade `ss/sS/gai/gao` buffer-local y redefine `st/sT` de todo-comments. Se detallan en sus secciones; no son mappings independientes que deban duplicarse. [LSP provider][picker-lsp], [TODO provider][picker-todo]

### Mappings dentro del picker, no globales

LazyVim añade los siguientes a `opts.picker.win.input.keys`; se usan **en el input del picker**, no en todos los buffers. [Integración LazyVim][picker-internal], [Trouble][picker-trouble], [Flash][picker-flash]

| Teclas | Modos | Acción / dependencia |
| --- | --- | --- |
| `<A-c>` | `n`, `i` | Alternar cwd del picker entre root del buffer de origen y cwd |
| `<A-t>` | `n`, `i` | Abrir resultados en Trouble, si está disponible |
| `<A-s>` | `n`, `i` | Flash sobre la lista, si Flash está disponible |
| `s` | `n` | Flash sobre la lista, si Flash está disponible |

Una selección útil de **defaults de Snacks**, no inventados por LazyVim: `<CR>` confirmar, `<C-j>/<C-k>` o `<C-n>/<C-p>` moverse, `<Tab>/<S-Tab>` seleccionar, `<C-s>/<C-v>/<C-t>` abrir split/vsplit/tab, `<C-q>` enviar a quickfix, `<A-h>` ocultos, `<A-i>` ignorados, `<A-p>` preview y `?` ayuda. En input tienen los modos declarados por Snacks (normal/insert para la mayoría); `<Esc>` en Normal cancela, no se debe suponer que en Insert cierra directamente. [Defaults de Snacks][picker-defaults]

### Qué cambia con Telescope o FzfLua

Los providers comparten aliases como `<leader><space>`, `/`, `,`, `ff/fF`, `sg/sG`, `sw/sW`, `sk`, `ss/sS`, pero **no son tablas idénticas**:

- Telescope añade `so` para options y usa sus propios comandos, mappings del prompt y extensiones; `gd/gr/gI/gy` se redefinen en la spec LSP del provider.
- FzfLua añade `gd` de Git diff por files, y mappings locales de terminal para el buffer `fzf`; también cambia la implementación de navegación LSP.
- Ambos pueden reemplazar `<leader>gl` con commits; los mappings core que llaman directamente a Snacks siguen siendo otra capa.
- Acciones como `sp`, `su`, `si`, issues/PRs o call hierarchy de Snacks no deben darse por idénticas en todos los backends. Tampoco hay que copiar nombres internos como `grep_word` a Telescope sin traducirlos.
- `LazyVim.pick` reduce parte de la diferencia: registra un provider y traduce comandos genéricos (`files`, `live_grep`, `oldfiles`) a sus APIs. No hace que cualquier comando específico exista en todos los providers.

Fuentes: [Telescope keys][telescope], [Telescope LSP][telescope-lsp], [FzfLua keys/LSP][fzf], [adaptador][pick], [registro Snacks][picker-register].

## 7. LSP actual: buffer-local, capacidades y overrides de provider

La fuente actual de defaults es **`opts.servers["*"].keys` en `plugins/lsp/init.lua`**, no una lista editable mediante `.get()` en `plugins/lsp/keymaps.lua`. `.get()` sigue presente solo por compatibilidad y emite deprecation. Cada servidor puede aportar su propio `keys`; `opts_extend = { "servers.*.keys" }` permite extenderlos. [Defaults LSP][lsp-spec], [mecanismo/deprecation][lsp-manager], [docs actuales][lsp-docs]

El manager resuelve las entradas por modo usando lazy.nvim, normaliza `has = "definition"` a `textDocument/definition`, conserva los métodos que ya tienen `/`, y registra con `Snacks.keymap.set(..., { lsp = filter, enabled = ... })`. Snacks aplica el mapping a buffers con clientes que coincidan; reevalúa al attach y a la registration de capabilities. En una lista `has`, se registra un filtro por método: basta que coincida alguno, **no se implementa una condición AND de todos**. Los mappings LSP más nuevos que coinciden prevalecen para el mismo `(modo, lhs)`. [Manager][lsp-manager], [Snacks buffer-local y prioridad][snacks-keymap], [eventos LSP][snacks-lsp]

**«Global LSP keymaps» en la documentación significa comunes a todos los servidores, no mappings globales de Neovim.** Estos defaults solo se aplican a los buffers con cliente compatible. Diagnósticos y format manual del core son otra capa. [Docs][lsp-docs], [manager][lsp-manager], [core-code][core-code]

| Teclas | Modos | Default / condición declarada |
| --- | --- | --- |
| `<leader>cl` | `n` | LSP info con `Snacks.picker.lsp_config()` |
| `gd` | `n` | Definition; `has = "definition"`; el picker elegido sustituye el RHS |
| `gr` | `n` | References; `nowait = true`; picker sustituye RHS |
| `gI` | `n` | Implementation; picker sustituye RHS |
| `gy` | `n` | Type definition; picker sustituye RHS |
| `gD` | `n` | Declaration; un servidor/extra puede reemplazarlo |
| `K` | `n` | Hover |
| `gK` | `n` | Signature help; `has = "signatureHelp"` |
| `<C-k>` | `i` | Signature help; `has = "signatureHelp"` |
| `<leader>ca` | `n`, `x` | Code action; `has = "codeAction"` |
| `<leader>cc` | `n`, `x` | Ejecutar codelens; `has = "codeLens"` |
| `<leader>cC` | `n` | Refrescar/mostrar codelens; `has = "codeLens"` |
| `<leader>cR` | `n` | Rename file con Snacks; soporte de `workspace/didRenameFiles` o `workspace/willRenameFiles` |
| `<leader>cr` | `n` | Rename symbol; `has = "rename"` |
| `<leader>cA` | `n` | Source action; `has = "codeAction"` |
| `]]`, `[[` | `n` | Siguiente/anterior document highlight con Snacks words; requiere `documentHighlight` y words habilitado; respeta count |
| `<A-n>`, `<A-p>` | `n` | Siguiente/anterior referencia con segundo argumento `true` a `Snacks.words.jump`; mismas condiciones |
| `<leader>co` | `n` | Organize imports; `codeAction` y acción `source.organizeImports` anunciada por el servidor |
| `<leader>ss` | `n` | Symbols con Snacks picker; `has = "documentSymbol"`; añadido por provider |
| `<leader>sS` | `n` | Workspace symbols; `has = "workspace/symbols"` tal como aparece en el snapshot; añadido por provider |
| `gai`, `gao` | `n` | Incoming/outgoing calls con Snacks; filtros `callHierarchy/incomingCalls` / `callHierarchy/outgoingCalls`; añadidos por provider |

Fuentes de la tabla: [base LSP, líneas 78–114][lsp-keys] y [provider Snacks, líneas 146–155][picker-lsp]. No se ha añadido artificialmente `has` a los mappings que upstream no lo declara, como `gr`, `gI`, `gy`, `gD` o `K`. Los strings de methods de la tabla se transcriben del código; no son una recomendación para implementar un cliente LSP propio.

Ejemplo real compacto de una entrada LSP:

```lua
{ "<leader>ca", vim.lsp.buf.code_action,
  desc = "Code Action", mode = { "n", "x" }, has = "codeAction" }
```

Esta tabla tiene metadatos de LazyVim; `has` **no es una opción nativa de `vim.keymap.set`**. La adaptación a una configuración `vim.pack` requeriría resolver capabilities mediante el API LSP y decidir cuándo crear mappings buffer-local, no pasar esta tabla directamente. [Manager][lsp-manager]

## 8. Gitsigns, terminal y format: contexto junto a implementación

### Gitsigns: no usa `keys` para los hunks

`on_attach(buffer)` define un helper local que llama a `vim.keymap.set(..., { buffer = buffer, desc = ..., silent = true })`. Por tanto, estas acciones aparecen en buffers adjuntos a Gitsigns, no como defaults globales. [Implementación][gitsigns]

| Teclas | Modos | Acción |
| --- | --- | --- |
| `[h`, `]h` | `n` | Hunk anterior/siguiente; en diff usa `[c`/`]c` nativos |
| `[H`, `]H` | `n` | Primer/último hunk |
| `<leader>ghs` | `n`, `x` | Stage hunk |
| `<leader>ghr` | `n`, `x` | Reset hunk |
| `<leader>ghS` | `n` | Stage buffer |
| `<leader>ghu` | `n` | Undo stage hunk |
| `<leader>ghR` | `n` | Reset buffer |
| `<leader>ghp` | `n` | Preview hunk inline |
| `<leader>ghb` | `n` | Blame line completo |
| `<leader>ghB` | `n` | Blame buffer |
| `<leader>ghd` | `n` | Diff this |
| `<leader>ghD` | `n` | Diff this `~` |
| `ih` | `o`, `x` | Seleccionar hunk como text object |
| `<leader>uG` | `n` | Toggle Git signs, creado aparte durante la configuración del plugin |

La tabla distingue `gh*` de `g*`: `ghb` es blame de Gitsigns y `gb` del core usa Git log de línea en Snacks. No son sinónimos. [Gitsigns][gitsigns], [core Git][core-tail]

### Terminal

Los mappings globales `ft/fT/<C-/>` están en el core, pero la navegación del terminal se configura en `opts.terminal.win.keys` de Snacks. [Core][core-tail], [util spec][terminal-keys]

| Teclas | Contexto / modo | Acción |
| --- | --- | --- |
| `<C-h>`, `<C-j>`, `<C-k>`, `<C-l>` | Terminal Snacks, `t` | En split, programar `wincmd`; en float, devolver el Ctrl correspondiente al terminal (`expr`) |
| `<C-/>`, `<C-_>` | Terminal Snacks, `t` | Ocultar terminal; segundo alias excluido de la ayuda mediante su descripción |
| `<Esc><Esc>` | Backend Snacks, `t` | Salir a Normal si los escapes llegan dentro del intervalo de 200 ms |
| `q` | Ventana terminal Snacks, Normal | Ocultar |
| `gf` | Ventana terminal Snacks, Normal | Abrir archivo bajo cursor si se encuentra |

Las dos últimas filas y el doble Escape provienen del backend, no de un mapping general añadido por LazyVim. Snacks identifica terminales por `cmd`, `cwd`, `env` y count; `Snacks.terminal()` es toggle, mientras `Snacks.terminal.focus()` enfoca o esconde si ya tiene foco. Esto explica por qué el mapping actual de Ctrl no es simplemente una llamada idéntica a `ft`. [Backend][snacks-terminal]

### Format

| Teclas | Capa | Modos | Acción |
| --- | --- | --- | --- |
| `<leader>cf` | Core | `n`, `x` | Format manual con `force = true`, aunque autoformat esté desactivado |
| `<leader>cF` | Conform | `n`, `x` | Format de lenguajes inyectados, `formatters = { "injected" }` |
| `<leader>uf` | Core/helper | `n` | Autoformat global |
| `<leader>uF` | Core/helper | `n` | Autoformat del buffer |

LazyVim registra formatters con prioridad: Conform es primary con prioridad 100; LSP también se registra como formatter. Conform usa `lsp_format = "fallback"` por defecto, y LazyVim centraliza el autoformat en `BufWritePre`. Por tanto, `cf` no es simplemente un alias universal de `vim.lsp.buf.format`, y `cF` no significa «format más fuerte»: tiene otra finalidad. [Core][core-code], [Conform][formatting], [format orchestration][format-util], [LSP registration][lsp-spec]

## 9. Otros plugins predeterminados: mappings relevantes

Esta sección recoge los principales mappings explícitos y contextualiza los que se generan mediante configuración interna; no pretende enumerar cada combinación nativa de cada plugin o preset de completion.

| Plugin / fuente | Teclas y modos | Qué añade o reemplaza |
| --- | --- | --- |
| [Bufferline][bufferline] | `n`: `bp`, `bP`, `br`, `bl`, `bj` bajo `<leader>`; `<S-h>/<S-l>`, `[b/]b`, `[B/]B` | Pin, cerrar no pinned, cerrar derecha/izquierda, seleccionar; ciclo y reordenación. Reemplaza parte de la navegación del core. |
| [Trouble][trouble] | `n`: `<leader>xx/xX`, `cs/cS`, `xL/xQ`, `[q/]q` | Diagnostics global/buffer, symbols/LSP, listas. Los saltos usan Trouble si está abierto; si no, quickfix. |
| [Flash][flash] | `s/S`: `n,o,x`; `r`: `o`; `R`: `o,x`; `<C-s>`: `c`; `<C-space>`: `n,o,x` | Jump, Treesitter, remote, Treesitter search, toggle Flash search e incremental selection simulada. En esa selección `<C-space>` avanza y `<BS>` retrocede. |
| [grug-far][grug] | `<leader>sr`: `n,x` | Search and replace; deriva `filesFilter` de la extensión del archivo actual. |
| [TODO comments][todo], [provider Snacks][picker-todo] | `n`: `[t/]t`, `<leader>xt/xT`, `<leader>st/sT` | Saltos; Trouble con todos/filtrados; picker con todos o `TODO,FIX,FIXME`. Snacks redefine el RHS que inicialmente usa `TodoTelescope`. |
| [Noice][noice] | `n`: `<leader>snl/snh/sna/snd/snt`; `<S-Enter>`: `c`; `<C-f>/<C-b>`: `n,i,s` | Último mensaje/history/all/dismiss/picker y redirigir cmdline. Scroll LSP contextual con fallback que devuelve Ctrl si Noice no consume la acción. `sn` es etiqueta `+noice`, no una acción de búsqueda. |
| [Persistence][persistence] | `n`: `<leader>qs/qS/ql/qd` | Restaurar sesión, seleccionar, restaurar última, dejar de guardar sesión actual. |
| [which-key][which-key] | `n`: `<leader>?`, `<C-w><space>` | Ver mappings locales del buffer; Window Hydra. |
| [Snacks util][util] | `n`: `<leader>.`, `<leader>S`, `<leader>dps` | Toggle scratch, seleccionar scratch, scratch del profiler. |
| [Snacks UI][snacks-ui] | `n`: `<leader>n`, `<leader>un` | Historial de notificaciones (picker si habilitado, notifier si no) y dismiss all. |
| [Mason][mason] | `n`: `<leader>cm` | Abrir Mason. |
| [mini.pairs helper][mini-helper] | `n`: `<leader>up` | Toggle pairs. Las inserciones de pares se configuran en el plugin, no en una gran lista `keys`. |
| [Treesitter textobjects][ts-moves] | `n,x,o`: `[f/]f`, `[F/]F`, `[c/]c`, `[C/]C`, `[a/]a`, `[A/]A` | Anterior/siguiente inicio/final de function, class y parameter; buffer-local cuando hay query. `c/C` conserva movimiento nativo en diff. |
| [mini.ai config][mini-ai] | Text objects en `o,x`, definidos por el plugin | Custom objects: `o` block/conditional/loop, `f` function, `c` class, `t` tag, `d` digits, `e` case-aware word, `g` buffer, `u/U` calls. El helper de which-key agrega ayuda, no implementa esos text objects. |
| [blink.cmp provider][blink] | `opts.keymap.preset = "enter"`, `<C-y>` select-and-accept; `<Tab>` con snippet/AI/fallback | Completion predeterminado seleccionado; mapping interno del plugin, no `keys` global de lazy.nvim. El preset completo depende de la versión de Blink. |

Las secuencias abreviadas de la tabla (`bp`, `cs`, etc.) mantienen el `<leader>` indicado; **`[b` y `]b` no llevan leader**. La tabla confirma que `keys` no es la única fuente: hay `on_attach`, `FileType`, helpers, presets y mappings internos de UI. Fuentes enlazadas por fila.

## 10. Which-key: descubrimiento declarativo, no ownership universal

LazyVim configura `preset = "helix"`, extiende `opts.spec` y declara grupos para Normal y Visual. Las acciones ordinarias ya llevan `desc` en `vim.keymap.set` o en `keys`; which-key obtiene esas descripciones automáticamente. No necesita otra lista duplicada de cada callback. [Config LazyVim][which-key], [docs which-key][wk-docs]

Ejemplo real recortado de la declaración de grupos:

```lua
spec = {
  {
    mode = { "n", "x" },
    { "<leader>c", group = "code" },
    { "<leader>f", group = "file/find" },
    { "<leader>g", group = "git" },
    { "<leader>gh", group = "hunks" },
    { "[", group = "prev" },
    { "]", group = "next" },
  },
}
```

`group` etiqueta una rama; `desc` etiqueta una acción o mejora la ayuda de una combinación existente. `which-key.add` **sí puede crear mappings cuando se le da un RHS**, pero los grupos de este ejemplo no contienen uno. `proxy = "<c-w>"` en `<leader>w` y `expand.buf()/expand.win()` son casos especiales de presentación/expansión dinámica, no evidencia de que todo el core se registre en which-key. [Config con proxy/expand][which-key], [contrato de spec][wk-docs]

`opts.defaults` / `wk.register` pertenecen al esquema antiguo; LazyVim conserva compatibilidad, pero advierte que se use `opts.spec`. La API actual de which-key v3 es `add`. Evitar copiar tutoriales antiguos como referencia de estructura actual. [Warning LazyVim][which-key], [cambio v3][wk-docs]

## 11. Overrides: modificar en la capa que los posee

Estos ejemplos describen **LazyVim/lazy.nvim**, no código para introducir directamente en esta configuración `vim.pack`.

| Caso | Canal documentado |
| --- | --- |
| Mapping global del core | `lua/config/keymaps.lua`, `vim.keymap.del` / `vim.keymap.set`; defaults cargan antes |
| Mapping en `keys` de un plugin | Spec del mismo plugin: mismo `lhs` y modo para reemplazar, `rhs = false` para quitar |
| Todos los mappings `keys` de un plugin | `keys = function() return {} end`; una tabla vacía por sí sola se extiende con los defaults |
| LSP común | `opts.servers["*"].keys` |
| LSP específico | `opts.servers.<server>.keys` |
| Mapping interno de picker o terminal | Opciones del componente (`win.input.keys`, `terminal.win.keys`, etc.) |
| Gitsigns contextual | Su `on_attach` / configuración de buffer |

Fuentes: [keymaps][custom-keymaps], [plugin merge/disable][custom-plugins], [LSP][lsp-docs], [picker][picker-internal], [terminal][terminal-keys], [Gitsigns][gitsigns].

Ejemplo del mecanismo oficial para desactivar `s` de Flash, conservando sus modos:

```lua
{
  "folke/flash.nvim",
  keys = {
    { "s", mode = { "n", "x", "o" }, false },
  },
}
```

El modo forma parte de la identidad: quitar solo `n` no quita `x` ni `o`. La resolución conserva la última definición por identidad y elimina las entradas con `false`/`vim.NIL`. Una spec puede redefinir la misma tecla, sin necesidad de otro helper imperativo. [Ejemplo oficial][custom-plugins], [resolve][lazy-keys]

## 12. Extras opcionales: ejemplos de ampliación, no defaults universales

| Extra | Mappings representativos | Estructura / advertencia |
| --- | --- | --- |
| [DAP core][dap] | `<leader>db/dB` breakpoint/condition, `dc` continue, `dC` run to cursor, `di/do/dO` step into/out/over, `dr` REPL, `dt` terminate, `du` UI; `de` eval en `n,x` | Specs de DAP y DAP UI; el prefijo `d` ya existe en which-key, pero estas acciones requieren el extra. |
| [Test core][test] | `<leader>tt/tT` file/all, `tr` nearest, `tl` last, `ts` summary, `to/tO` output/panel, `tS` stop, `tw` watch; `td` debug si hay DAP | Añade su categoría `+test` y acciones de Neotest. |
| [mini.surround][surround] | `gsa`, `gsd`, `gsr`, `gsf/gsF`, `gsh`, `gsn` | Deriva `keys` de `opts.mappings` del plugin; tener grupo `gs` no instala estas acciones. |
| [mini.files][mini-files] | `<leader>fm/fM` | Directorio del archivo actual / cwd; **no** root/cwd como `fe/fE`. |
| [TypeScript vtsls][vtsls] | `gD` source definition, `gR` file references, `<leader>cM` missing imports, `cD` fix diagnostics, `cV` TS workspace version | Mappings en `servers.vtsls.keys`; `gD` cambia la semántica del default solo en ese contexto. No aplican a cualquier backend TypeScript. |
| [Telescope][telescope] / [FzfLua][fzf] | Familia `f*`, `s*`, navegación LSP | Providers alternativos elegibles; uno seleccionado reemplaza acciones, no implica activar simultáneamente tres pickers. |

Los extras pueden aportar overrides de otros plugins además de instalar uno nuevo. No se han inventariado exhaustivamente los extras de AI, todos los lenguajes ni cada keymap interno de sus UIs: para esa amplitud, el [catálogo oficial][catalog] los identifica con «Part of ...», y el directorio de extras de este commit es la fuente reproducible.

## 13. Principios trasladables a `vim.pack`, sin implementar todavía

Estas son **inferencias de diseño** del código anterior, no una propuesta de cambiar el package manager ni de instalar LazyVim:

1. **Una gramática estable por acción, no por marca de plugin.** `f` files, `s` search, `c` code, `g` Git, `b` buffers, `w` windows, `x` lists. Cambiar el backend no debería obligar a reaprender las acciones que siguen siendo equivalentes. El adaptador picker de LazyVim ilustra la separación. [pick][pick], [grupos][which-key]
2. **Mappings nativos globales separados de los dependientes de plugin.** Encaja con la estructura local ya requerida: `.config/nvim/lua/config/keymaps.lua` para comportamiento general y `.config/nvim/lua/plugins/<name>.lua` para setup, mappings y autocmds de cada plugin o concern. No necesita replicar las specs lazy.
3. **Contexto explícito.** Buffer-local para LSP/Gitsigns; modos exactos para selección, operator y terminal; `root`/cwd en las acciones que lo necesitan. No llenar buffers sin LSP con falsas acciones disponibles. [Gitsigns][gitsigns], [LSP][lsp-manager], [root][root]
4. **Descripciones al lado del mapping; grupos en la ayuda visual.** Se puede conservar este principio con cualquier herramienta de descubrimiento de mappings: metadata junto a la acción y etiquetas de categorías aparte. Which-key no es requisito conceptual del diseño. [which-key][wk-docs]
5. **Aliases solo cuando aportan valor.** Acceso rápido como `<leader><space>` y ubicación sistemática como `<leader>ff` pueden coexistir si comparten implementación. Si un alias invoca otro mapping, su necesidad de `remap` debe ser consciente. [picker][picker-keys], [explorer][explorer]
6. **Parejas legibles, pero sin regla falsa de mayúsculas.** Definir qué significa el scope de cada pareja; root/cwd, global/buffer, hunk/buffer y first/last son dimensiones distintas. [parejas core][core-tail], [Gitsigns][gitsigns], [format][format-util]
7. **Ownership y overrides deliberados.** Mantener un dueño claro por `(modo, lhs, contexto)`, no copiar `safe_keymap_set` como supuesto validador. Con `vim.pack` no existe por defecto el registry `lazy.core.handler` ni su protocolo de `keys`. [safe][safe], [lazy keys][lazy-keys]
8. **Abstraer el contexto o la acción compleja, no cada llamada simple.** `diagnostic_goto`, el helper de Gitsigns, root detection y el adaptador picker eliminan repetición real; mappings de `:enew`, `:qa` o ventanas siguen siendo directos. [Core][core], [root][root], [Gitsigns][gitsigns]

Lo que **no** se puede trasladar literalmente: tablas `keys` de lazy.nvim esperando lazy-load automático, `has` como opción nativa de keymap, globals `LazyVim`/`Snacks` sin sus dependencias, eventos `VeryLazy`/`LazyFile` sin su infraestructura y prioridades/merge rules específicas de specs lazy. Se puede reutilizar el diseño sin reutilizar ese runtime. [Bootstrap][bootstrap], [lazy loading][lazy-loading], [manager LSP][lsp-manager], [evento LazyFile][plugin-util]

## 14. Comparación preliminar con estos dotfiles

Se inspeccionó el working tree actual, incluidos los archivos y cambios preexistentes. Esta sección no propone activar mappings nuevos todavía.

- **La separación por responsabilidad ya existe.** El entry point carga options, keymaps y plugins; el registry instala mediante `vim.pack` y requiere módulos por concern. Los mappings dependientes de plugins viven junto a su configuración. Es compatible con el principio de ownership de LazyVim, sin replicar su package manager. [Entry point](../init.lua), [registry](../lua/plugins/init.lua), [convenciones locales](../CLAUDE.md).
- **Buffers ya sigue el vocabulario de LazyVim.** `H/L`, `[b/]b`, `bb`, `bd`, `bo`, `bi` y `bD` tienen equivalentes en el core estudiado; aquí la eliminación que conserva splits usa `mini.bufremove`. [Implementación local](../lua/plugins/buffers.lua), [core upstream][core].
- **`mini.clue` ya cubre el principio de descubrimiento.** Los mappings propios tienen `desc`, y los grupos se describen por separado. No hace falta sustituirlo por which-key para adoptar esa estructura: mini.clue obtiene las descripciones de los mappings existentes y recomienda definir aparte solo grupos y ayudas adicionales. [Configuración local](../lua/plugins/clue.lua), [contrato de mini.clue en el commit instalado](https://github.com/nvim-mini/mini.clue/blob/1c136d62729c8c3b0c2d91379bc37efac15d916e/lua/mini/clue.lua#L507-L533).
- **Los mappings contextuales también están separados.** `gd/gD` se añaden mediante `LspAttach`; el toggle de Markdown `mr` es buffer-local en `FileType`. El archivo LSP local se apoya además en defaults nativos de Neovim. [LSP local](../lua/plugins/lsp.lua), [Markdown local](../lua/plugins/render_markdown.lua).

### Diferencias de significado que requieren una decisión explícita

| Tecla | Comportamiento local actual | LazyVim con Snacks picker |
| --- | --- | --- |
| `<leader>fg` | Live grep en el scope habitual | Git files; grep habitual es `<leader>sg` |
| `<leader>fF` | Files en el proyecto completo, incluidos ignorados | Files en cwd; no implica ignorados |
| `<leader>fG` | Grep en el proyecto completo, incluidos ignorados | No aparece como default de este provider; grep en cwd es `<leader>sG` |
| `<leader>fr` | Resume último picker | Recent; resume es `<leader>sR` |
| `<leader>fk` | Buscar keymaps | La acción usa `<leader>sk` |

Fuentes: [picker local](../lua/plugins/pick.lua), [mini.extra local](../lua/plugins/mini_extra.lua), [picker upstream][picker-keys]. El scope local habitual puede ser cwd o `PeopleExperience` en los repositorios configurados; el scope de proyecto usa Git root con fallback a cwd. No equivale a la detección de root por buffer de LazyVim. [Scopes locales](../lua/plugins/pick.lua), [root upstream][root].

### Defaults heredados y orden de carga

- **No basta inventariar las llamadas propias a `vim.keymap.set`.** `mini.basics.setup()` aporta movimientos, clipboard, guardado y toggles con `\`, entre otros. Por ejemplo, `gy` copia al clipboard en Normal/Visual; adoptar literalmente el `gy` LSP de LazyVim cambiaría su acción en Normal dentro de buffers con LSP. [Setup local](../lua/plugins/basics.lua), [defaults del commit instalado de mini.basics](https://github.com/nvim-mini/mini.basics/blob/63e3ea1a296c09a033176e6aee7202ed37e17495/lua/mini/basics.lua#L522-L616), [LSP upstream][lsp-keys].
- **No trasladar los toggles simplemente cambiando `\` por `<leader>u`.** Los sufijos no coinciden siempre: mini.basics usa `c` para cursorline y `l` para list; LazyVim usa `uc` para conceal y `ul` para line numbers. [mini.basics](https://github.com/nvim-mini/mini.basics/blob/63e3ea1a296c09a033176e6aee7202ed37e17495/lua/mini/basics.lua#L586-L616), [toggles upstream][core-toggle].
- **El orden local no es el de LazyVim.** Aquí `config.keymaps` se carga antes de los plugins. Actualmente `<leader>` lo fija mini.basics a espacio si no estaba definido; `config.options` solo fija `<localleader>`. Si se amplía `config.keymaps` con mappings `<leader>`, conviene declarar `vim.g.mapleader` en options antes de registrarlos: su valor se expande al crear cada mapping. Hoy ese archivo solo define `jk`, por lo que este orden no provoca ese problema en la configuración inspeccionada. [Entry point](../init.lua), [options locales](../lua/config/options.lua), [keymaps locales](../lua/config/keymaps.lua), [leader de mini.basics](https://github.com/nvim-mini/mini.basics/blob/63e3ea1a296c09a033176e6aee7202ed37e17495/lua/mini/basics.lua#L419-L427), [regla nativa de mapleader](https://neovim.io/doc/user/map.html#mapleader).

**Conclusión local:** se puede conservar `vim.pack`, MiniPick, mini.clue, Oil y mini.bufremove, y mejorar la consistencia de prefijos, scopes, modos y descripciones. La adopción debería decidir qué comportamientos personales conservar, no reemplazar el stack ni copiar todos los mappings upstream sin adaptar sus dependencias.

## Fuentes primarias y enlaces permanentes

Todos los enlaces de código LazyVim siguientes corresponden al commit principal indicado arriba. Los enlaces web son páginas vivas oficiales consultadas en la misma fecha.

[version]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/config/init.lua#L1-L22
[bootstrap]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/plugins/init.lua#L1-L32
[options]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/config/options.lua#L1-L43
[init-options]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/config/init.lua#L311-L349
[setup]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/config/init.lua#L175-L208
[config-load]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/config/init.lua#L285-L306
[import-order]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/config/init.lua#L221-L246
[defaults]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/config/init.lua#L357-L453
[xtras]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/plugins/xtras.lua#L25-L81
[core]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/config/keymaps.lua
[core-edit]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/config/keymaps.lua#L3-L92
[core-code]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/config/keymaps.lua#L94-L140
[core-toggle]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/config/keymaps.lua#L144-L165
[core-tail]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/config/keymaps.lua#L167-L215
[safe]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/util/init.lua#L203-L226
[root]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/util/root.lua#L17-L198
[pick]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/util/pick.lua#L23-L77
[picker-register]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/plugins/extras/editor/snacks_picker.lua#L9-L26
[picker-internal]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/plugins/extras/editor/snacks_picker.lua#L31-L55
[picker-keys]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/plugins/extras/editor/snacks_picker.lua#L58-L112
[picker-trouble]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/plugins/extras/editor/snacks_picker.lua#L114-L138
[picker-lsp]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/plugins/extras/editor/snacks_picker.lua#L140-L159
[picker-todo]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/plugins/extras/editor/snacks_picker.lua#L160-L168
[picker-flash]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/plugins/extras/editor/snacks_picker.lua#L224-L265
[explorer]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/plugins/extras/editor/snacks_explorer.lua#L1-L24
[telescope]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/plugins/extras/editor/telescope.lua#L89-L160
[telescope-lsp]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/plugins/extras/editor/telescope.lua#L285-L301
[fzf]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/plugins/extras/editor/fzf.lua#L208-L304
[editor]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/plugins/editor.lua
[which-key]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/plugins/editor.lua#L56-L128
[gitsigns]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/plugins/editor.lua#L133-L203
[trouble]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/plugins/editor.lua#L205-L252
[flash]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/plugins/editor.lua#L30-L54
[grug]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/plugins/editor.lua#L3-L25
[todo]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/plugins/editor.lua#L254-L271
[bufferline]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/plugins/ui.lua#L4-L62
[noice]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/plugins/ui.lua#L194-L246
[snacks-ui]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/plugins/ui.lua#L272-L295
[util]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/plugins/util.lua#L1-L58
[terminal-keys]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/plugins/util.lua#L1-L31
[persistence]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/plugins/util.lua#L40-L54
[formatting]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/plugins/formatting.lua#L20-L98
[format-util]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/util/format.lua#L18-L194
[lsp-spec]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/plugins/lsp/init.lua#L4-L177
[lsp-keys]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/plugins/lsp/init.lua#L78-L114
[lsp-manager]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/plugins/lsp/keymaps.lua#L1-L67
[mason]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/plugins/lsp/init.lua#L280-L293
[mini-ai]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/plugins/coding.lua#L34-L71
[mini-helper]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/util/mini.lua#L21-L95
[ts-moves]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/plugins/treesitter.lua#L139-L205
[blink]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/plugins/extras/coding/blink.lua#L84-L139
[dap]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/plugins/extras/dap/core.lua#L35-L88
[test]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/plugins/extras/test/core.lua#L107-L129
[surround]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/plugins/extras/coding/mini-surround.lua
[mini-files]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/plugins/extras/editor/mini-files.lua
[vtsls]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/plugins/extras/lang/typescript/vtsls.lua#L60-L106
[plugin-util]: https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/util/plugin.lua#L84-L90
[lazy-keys]: https://github.com/folke/lazy.nvim/blob/306a05526ada86a7b30af95c5cc81ffba93fef97/lua/lazy/core/handler/keys.lua#L32-L199
[verylazy]: https://github.com/folke/lazy.nvim/blob/306a05526ada86a7b30af95c5cc81ffba93fef97/doc/lazy.nvim.txt#L1111-L1116
[lazy-loading]: https://lazy.folke.io/spec/lazy_loading
[snacks-keymap]: https://github.com/folke/snacks.nvim/blob/882c996cf28183f4d63640de0b4c02ec886d01f2/lua/snacks/keymap.lua#L59-L189
[snacks-lsp]: https://github.com/folke/snacks.nvim/blob/882c996cf28183f4d63640de0b4c02ec886d01f2/lua/snacks/util/lsp.lua#L53-L101
[snacks-toggle]: https://github.com/folke/snacks.nvim/blob/882c996cf28183f4d63640de0b4c02ec886d01f2/lua/snacks/toggle.lua#L20-L149
[snacks-terminal]: https://github.com/folke/snacks.nvim/blob/882c996cf28183f4d63640de0b4c02ec886d01f2/lua/snacks/terminal.lua#L32-L234
[picker-defaults]: https://github.com/folke/snacks.nvim/blob/882c996cf28183f4d63640de0b4c02ec886d01f2/lua/snacks/picker/config/defaults.lua#L219-L324
[picker-files]: https://github.com/folke/snacks.nvim/blob/882c996cf28183f4d63640de0b4c02ec886d01f2/lua/snacks/picker/config/sources.lua#L191-L209
[picker-buffers]: https://github.com/folke/snacks.nvim/blob/882c996cf28183f4d63640de0b4c02ec886d01f2/lua/snacks/picker/config/sources.lua#L13-L37
[wk-docs]: https://github.com/folke/which-key.nvim/blob/3aab2147e74890957785941f0c1ad87d0a44c15a/README.md#L249-L313
[catalog]: https://www.lazyvim.org/keymaps
[custom-keymaps]: https://www.lazyvim.org/configuration/keymaps
[custom-plugins]: https://www.lazyvim.org/configuration/plugins#%EF%B8%8F-adding--disabling-plugin-keymaps
[lsp-docs]: https://www.lazyvim.org/plugins/lsp#%EF%B8%8F-customizing-lsp-keymaps
