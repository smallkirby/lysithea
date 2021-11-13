# lysithea completion
# https://github.com/smallkirby/lysithea


_lysithea()
{
  local cur prev words cword
  _init_completion || return

  local COMMANDS=(
    "version"
    "help"

    "init"
    "extract"
    "build"
    "compress"
    "error"
    "exploit"
    "local"
    "remote"
  )

  local GENERIC_OPTIONS='
    -h --help
    -v --verbose
    -f --force
  '

  # check if command is already specified
  local command i
  for (( i=0; i< ${#words[@]}-1; i++ )); do
    if [[ ${COMMANDS[@]} =~ ${words[i]} ]]; then
      command=${words[i]}
      break
    fi
  done

  # show command-specific option
  if [[ "$cur" == -* ]]; then
    case $command in
      remote)
        COMPREPLY=( $( compgen -W '-p --port
          --nobuild
          -h --host'"$GENERIC_OPTIONS" -- "$cur" ) )
        return 0
      ;;
      *)
        if [ -n "$command" ]; then
          COMPREPLY=( $( compgen -W "$GENERIC_OPTIONS" -- "$cur" ) )
          return 0
        fi
      ;;
    esac
  fi

  # show commands available if command is not set
  if [ "$command" = "" ]; then
    COMPREPLY=( $( compgen -W '${COMMANDS[@]}' -- "$cur" ) )
  fi

  return 0
} &&
complete -F _lysithea -o bashdefault -o default lysithea
