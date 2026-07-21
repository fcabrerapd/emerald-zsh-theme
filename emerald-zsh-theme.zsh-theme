# emerald-zsh personal theme
#
#------------------------------------------------------------------------------------------------------------------------------
#
# Un tema limpio, elegante y minimalista para Zsh.
# Diseñado para mantener la legibilidad y la estética de tu terminal.
#
# Creado por: @fcabrerapd
#
# Tomando la inspiracion de:
#   - Bearded Theme (Arc Emerald / Black & Emerald) - Para la paleta de colores
#   - VS Code Dark+ - Para la distribución de contrastes
#   - agnoster & robbyrussell - Para la estructura base del prompt de Oh My Zsh
#
#   Plugins recomendados / incluidos en la configuración:
#   - git: Aliases nativos y lectura del estado del repositorio.
#   - zsh-autosuggestions: Sugerencias de comandos según el historial.
#   - zsh-syntax-highlighting: Resaltado de sintaxis en tiempo real.
#
#-------------------------------------------------------------------------------------------------------------------------------

#Paleta de colores

C_EMERALD="%F{42}"     # Esmeralda principal (#00e6a6)
C_MINT="%F{85}"        # Menta brillante (#73fbfd)
C_CYAN="%F{44}"        # Turquesa/Cian (#00cec9)
C_YELLOW="%F{221}"     # Dorado (#ffeaa7)
C_PINK="%F{204}"       # Coral/Rosa (#ff7675)
C_TEXT="%F{253}"       # Blanco suave (#d8dee9)
C_MUTED="%F{238}"      # Gris slate tenue (#3b4252)
C_ERROR="%F{203}"      # Rojo Bearded (#ff5252)
C_RESET="%f"

# Funciones auxiliares del Prompt

prompt_char() {
    git branch >/dev/null 2>/dev/null && echo "❯❯" && return 
    echo '❯'
}

prompt_host() {
    if [[ -n "$SSH_CONNECTION" ]]; then
        echo " ${C_MUTED}at${C_RESET} ${C_CYAN}%m${C_RESET}"
    fi
}

prompt_virtualenv() {
    if [ -n "$VIRTUAL_ENV" ]; then
        if [ -f "$VIRTUAL_ENV/__name__" ]; then 
            local name=$(cat "$VIRTUAL_ENV/__name__")
        elif [ "$(basename "$VIRTUAL_ENV")" = "__" ]; then 
            local name=$(basename $(dirname "$VIRTUAL_ENV"))
        else
            local name=$(basename "$VIRTUAL_ENV")
        fi
        echo "${C_YELLOW}$name${C_RESET}"
    fi
}

prompt_nodenv() {
    if [[ -n "$NODENV_VERSION" ]]; then
        echo "${C_YELLOW}$NODENV_VERSION${C_RESET}"
    elif (( $+commands[nodenv] )); then
        local nodenv_version_name="$(nodenv version-name)"
        local nodenv_global="$(nodenv global)"
        if [[ "${nodenv_version_name}" != "${nodenv_global}" ]]; then
            echo "${C_YELLOW}$nodenv_version_name${C_RESET}"
        fi
    fi
}

prompt_envs() {
    local -a envs=()

    local venv=$(prompt_virtualenv)
    local nenv=$(prompt_nodenv)

    [[ -n "$venv" ]] && envs+=("$venv")
    [[ -n "$nenv" ]] && envs+=("$nenv")

    if [[ ${#envs[@]} -gt 0 ]]; then
        echo " ${C_MUTED}using${C_RESET} ${(j., .)envs}"
    fi
}

prompt_git() {
    local ref
    is_dirty() {
        test -n "$(git status --porcelain --ignore-submodules 2>/dev/null)"
    }

    ref="$vcs_info_msg_0_"
    if [[ -n "$ref" ]]; then
        local git_str="${C_MUTED}on${C_RESET} ${C_PINK}${ref}${C_RESET}"
        
        if is_dirty; then
            # Punto dorado si hay cambios pendientes
            git_str="${git_str} ${C_YELLOW}●${C_RESET}"
        else
            # Punto verde esmeralda si el repositorio está al día
            git_str="${git_str} ${C_EMERALD}●${C_RESET}"
        fi
        
        echo " $git_str"
    fi
}

# Manejador para comandos no encontrados
command_not_found_handler() {
    print -P "${C_ERROR}zsh: comando no encontrado: $1 ✘${C_RESET}"
    return 127
}

# Renderizado principal
prompt_emerald_precmd() {
    vcs_info

    echo ""

    PROMPT="${C_MUTED}╭─${C_RESET}${C_MINT}%n${C_RESET}$(prompt_host) ${C_MUTED}in${C_RESET} %B${C_EMERALD}%2~%b${C_RESET}$(prompt_git)$(prompt_envs)
${C_MUTED}╰─${C_RESET}${C_EMERALD}$(prompt_char)${C_RESET} "

    RPROMPT=""
}

# Configuración inicial de Zsh
prompt_emerald_setup() {
    setopt prompt_subst
    
    autoload -Uz add-zsh-hook
    autoload -Uz vcs_info

    add-zsh-hook precmd prompt_emerald_precmd

    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:*' check-for-changes false
    zstyle ':vcs_info:git*' formats '%b'
    zstyle ':vcs_info:git*' actionformats '%b (%a)'
}

prompt_emerald_setup "$@"