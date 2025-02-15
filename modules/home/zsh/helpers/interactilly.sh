#!/usr/bin/env bash

COMMAND_NAME=""
COMMAND=""

RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
YELLOW="$(tput setaf 3)"
MAGENTA="$(tput setaf 5)"
CYAN="$(tput setaf 6)"
BOLD="$(tput bold)"
NORMAL="$(tput sgr0)"

if [ -z "$INTERACTIVELY_NO_HEADER" ]; then
  HEADER='
  '"${CYAN}${BOLD}Esc${NORMAL}   - ${MAGENTA}end session and print query${NORMAL}"'
  '"${CYAN}${BOLD}Enter${NORMAL} - ${MAGENTA}save current query${NORMAL}"'
  '"${CYAN}${BOLD}Tab${NORMAL}   - ${MAGENTA}load selected query${NORMAL}"'

  '
fi

# -- Functions: --

interactively_usage() {
  echo "${BOLD}Interactively try out expressions in commands.${NORMAL}"
  echo
  echo "  ${GREEN}interactively ${CYAN}--name ${MAGENTA}awk${NORMAL} ${YELLOW}'cat foo.txt | awk {}'${NORMAL}"
  echo
  echo "    ${CYAN}-h --help${NORMAL}"
  echo "        this help text"
  echo
  echo "    ${CYAN}--name ${MAGENTA}[command-name]${NORMAL} | ${CYAN}-n ${MAGENTA}[command-name]${NORMAL}"
  echo "        used to differentiate the history of different commands"
  echo
  echo "The command name is not required. If not provided, the first word in"
  echo "the command is used. In the example above, that is ${GREEN}cat${NORMAL}."
  echo
  echo "${BOLD}Examples${NORMAL}:"
  echo
  echo "  ${GREEN}interactively${NORMAL} ${YELLOW}'grep {} file.txt'${NORMAL}"
  echo "  ${GREEN}interactively${NORMAL} ${YELLOW}'sed -e {} file.txt'${NORMAL}"
  echo "  ${GREEN}interactively${NORMAL} ${YELLOW}'jq -C {} file.json'${NORMAL}"
  echo "  ${GREEN}interactively${NORMAL} ${CYAN}--name ${MAGENTA}jq ${YELLOW}'kubectl .... -o json | jq -C {}'${NORMAL}"
  echo
  echo "${BOLD}Advanced${NORMAL}:"
  echo
  echo "Depending on which placeholder you use, you can choose how this program will work in preview."
  echo
  echo "- ${YELLOW}'{q}'${NORMAL} use query for preview"
  echo "- ${YELLOW}'{..}'${NORMAL} use selection for preview"
  echo "- ${YELLOW}'{}'${NORMAL} use query only when first line is selected, otherwise use selection"
}

# exit with an error message
error_exit() {
  echo "[${RED}${BOLD}ERROR${NORMAL}] $1"
  echo
  exit 1
}

# exit with an error message
usage_exit() {
  echo "[${RED}${BOLD}ERROR${NORMAL}] $1"
  echo
  interactively_usage
  exit 1
}

# read content from the command-line args
configure_session() {
  while [ "$1" != "" ]; do
    case $1 in
      -h | --help)
        interactively_usage
        exit 0
        ;;
      -n | --name)
        shift
        COMMAND_NAME="$1"
        ;;
      --name=* | -n=*)
        COMMAND_NAME="${1#*=}"
        ;;
      -n*)
        COMMAND_NAME="${1:2}"
        ;;
      *)
        # shellcheck disable=2001
        COMMAND="$(echo "$1" | sed 's/{}/{q}/g')"
        # shellcheck disable=2001
        COMMAND_WITH_SELECTION="$(echo "$1" | sed 's/{}/{..}/g')"
        ;;
    esac
    shift
  done

  if [ -z "$COMMAND_NAME" ]; then
    # shellcheck disable=2086
    COMMAND_NAME="$(echo "$COMMAND" | awk '{ print $1 }')"
  fi

  if [ -n "$FZF_HISTORY_DIR" ] && [ -d "$FZF_HISTORY_DIR" ]; then
    HISTORY_DIR="$FZF_HISTORY_DIR"
    mkdir -p "$HISTORY_DIR"
  else
    HISTORY_DIR="$(cd "$TMPDIR" && pwd)"
  fi
  HISTORY_FILE="$HISTORY_DIR/interactively_$COMMAND_NAME"
  touch "$HISTORY_FILE"
}

validate_system() {
  if ! type fzf >/dev/null 2>&1; then
    # shellcheck disable=2016
    error_exit '`fzf` not found; it is required for `git fuzzy` to work.'
  fi

  FZF_VERSION="$(fzf --version)"
  MIN_FZF_VERSION="0.27.0"
  if [ "$FZF_VERSION" = "$(echo -e "$FZF_VERSION\n$MIN_FZF_VERSION" | sort -V | head -n1)" ]; then
    # shellcheck disable=2016
    error_exit '`fzf` is too old and may not work properly; please install 0.27.0 or newer'
  fi
}

validate_configs() {
  if [ -z "$COMMAND" ]; then
    usage_exit "you didn't provide a command to run"
  fi

  if [ -z "$COMMAND_NAME" ]; then
    usage_exit "command name was not provided or couldn't be calculated"
  fi

  if [ ! -r "$HISTORY_FILE" ] || [ ! -w "$HISTORY_FILE" ] || [ ! -f "$HISTORY_FILE" ]; then
    usage_exit "history file issues: $HISTORY_FILE"
  fi
}

validate_system
configure_session "$@"
validate_configs

if [ -f "$HISTORY_FILE" ] && [ -r "$HISTORY_FILE" ]; then
  (echo ; tac "$HISTORY_FILE") | \
    fzf --phony \
        --history "$HISTORY_FILE" \
        --header "$HEADER" \
        --no-height \
        --preview "[ -z {..} ] && ($COMMAND ; true) || $COMMAND_WITH_SELECTION" \
        --bind "enter:execute-silent(echo {q} >> $HISTORY_FILE)+reload(echo ; tac $HISTORY_FILE)+first" \
        --bind 'tab:replace-query+first' \
        --bind 'esc:print-query'
else
  # shellcheck disable=2016
  error_exit 'please set `$FZF_HISTORY_DIR` or `$TMPDIR`'
fi