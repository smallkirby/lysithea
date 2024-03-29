# lysithea completion
# https://github.com/smallkirby/lysithea


_lysithea()
{
  local cur prev words cword
  _init_completion || return

  local COMMANDS=(
		"local"
		"remote"
		"help"
		"version"
		"init"
		"extract"
		"build"
		"compress"
		"error"
		"exploit"
		"logs"
		"log"
		"fetch"
		"drothea"
		"config"
		"memo"
		"clean"
  )

  local GENERIC_OPTIONS='

-h   --help   help
-v   --verbose
-f   --force
--nolog
--plain

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
      log)
        COMPREPLY=( $( compgen -W '--all --no-pager'"$GENERIC_OPTIONS" -- "$cur" ) )
        return 0;
      ;;
      remote)
        COMPREPLY=( $( compgen -W '-p   --port -H   --host --nobuild'"$GENERIC_OPTIONS" -- "$cur" ) )
        return 0;
      ;;
      clean)
        COMPREPLY=( $( compgen -W '-a   --all'"$GENERIC_OPTIONS" -- "$cur" ) )
        return 0;
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
