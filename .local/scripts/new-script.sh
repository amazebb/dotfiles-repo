#!/opt/homebrew/bin/bash
# Generate shell script with inputs, options.

# Function to validate argument names (no longer restricted to single chars, but can't be 'h')
validate_arg_name() {
  local arg_name="$1"
  if [[ $arg_name == "h" ]]; then
    echo "Error: Argument name '$arg_name' is reserved for help (-h)."
    exit 1
  fi
}

# Function to check for duplicate arguments
check_duplicate() {
  local arg="$1" type="$2" array=("${@:3}")
  for existing in "${array[@]}"; do
    if [[ $existing == "$arg" ]]; then
      echo "Error: $type argument '$arg' already used."
      exit 1
    fi
  done
}

# Default values
shell="bash"
script_name=""
script_desc=""
required_args=()
required_desc=()
optional_args=()
optional_internal=()
optional_desc=()
optional_defaults=()

# Usage function
usage() {
  echo "Usage: $(basename "$0") [-s shell] -n script_name -d description [-r required_arg|desc] [-o opt_arg|internal|desc|default]"
  echo "  -s: Shell to use (default: bash)"
  echo "  -n: Script name (e.g., myscript.sh)"
  echo "  -d: One-line script description"
  echo "  -r: Required positional input (format: name|desc)"
  echo "  -o: Optional argument (format: letter|internal|desc|default)"
  echo "  -h: Show help"
  exit 0
}

# Parse command-line options
while getopts ":s:n:d:r:o:h" opt; do
  case "$opt" in
    h) usage ;;
    s) shell="$OPTARG" ;;
    n) script_name="$OPTARG" ;;
    d) script_desc="$OPTARG" ;;
    r)
      IFS='|' read -r arg desc <<<"$OPTARG"
      validate_arg_name "$arg"
      check_duplicate "$arg" "Required" "${required_args[@]}"
      required_args+=("$arg")
      required_desc+=("$desc")
      ;;
    o)
      IFS='|' read -r arg internal desc default <<<"$OPTARG"
      validate_arg_name "$arg"
      check_duplicate "$arg" "Optional" "${optional_args[@]}"
      optional_args+=("$arg")
      internal_upper=$(echo "${internal:-$arg}" | tr '[:lower:]' '[:upper:]')
      optional_internal+=("$internal_upper")
      optional_desc+=("$desc")
      optional_defaults+=("$default")
      ;;
    ?)
      echo "Error: Invalid option -$OPTARG"
      usage
      ;;
  esac
done

# Validate script name and description
validate_script_info() {
  if [[ -z $script_name ]]; then
    echo "Error: Script name (-n) is required."
    exit 1
  fi
  if [[ ! $script_name =~ \.sh$ ]]; then
    script_name="$script_name.sh"
  fi
  if [[ -f $script_name ]]; then
    echo "Error: File '$script_name' already exists."
    exit 1
  fi
  if [[ -z $script_desc ]]; then
    echo "Error: Script description (-d) is required."
    exit 1
  fi
}

# Interactive mode if no arguments provided
if [[ -z $script_name && -z $script_desc && ${#required_args[@]} -eq 0 && ${#optional_args[@]} -eq 0 ]]; then
  # Prompt for shell
  read -r -p "Enter the shell to use (default: bash): " shell
  shell=${shell:-bash}

  # Prompt for script name
  read -r -p "Enter the name of the script to create (e.g., myscript.sh): " script_name
  # Prompt for script description
  read -r -p "Enter a one-line explanation of what the script does: " script_desc
  validate_script_info

  # Prompt for required positional inputs
  echo "Enter required positional inputs (one at a time)"
  while true; do
    read -r -p "Required input name (or Enter to finish): " arg
    if [[ -z $arg ]]; then
      break
    fi
    validate_arg_name "$arg"
    check_duplicate "$arg" "Required" "${required_args[@]}"
    read -r -p "Description for $arg: " desc
    if [[ -z $desc ]]; then
      echo "Error: Description cannot be empty."
      exit 1
    fi
    required_args+=("$arg")
    required_desc+=("$desc")
  done

  # Prompt for optional arguments
  echo "Enter optional arguments (single letters, one at a time). Press Enter without input to finish."
  while true; do
    read -r -p "Optional argument letter (or Enter to finish): " arg
    if [[ -z $arg ]]; then
      break
    fi
    validate_arg_name "$arg"
    check_duplicate "$arg" "Optional" "${optional_args[@]}"
    read -r -p "Internal variable name for -$arg (Enter to use '$arg'): " internal
    if [[ -z $internal ]]; then
      internal="$arg"
    fi
    read -r -p "Description for -$arg: " desc
    if [[ -z $desc ]]; then
      echo "Error: Description cannot be empty."
      exit 1
    fi
    read -r -p "Default value for -$arg (or Enter for none): " default
    optional_args+=("$arg")
    optional_internal+=("${internal^^}")
    optional_desc+=("$desc")
    optional_defaults+=("$default")
  done
else
  validate_script_info
fi

# Extract basename for help message
script_basename=$(basename "$script_name" .sh)

# Start generating the script
cat >"$script_name" <<EOF
#!/usr/bin/env $shell

# $script_name: $script_desc

# Version
VERSION="1.0.0"

# Help function
usage() {
    echo "Usage: $script_basename"
    echo "Options:"
    echo "  -h           Show this help message"
    echo "  --version    Show version information"
EOF

# Add required positional inputs to usage
if [[ ${#required_args[@]} -gt 0 ]]; then
  echo '    echo "Required inputs:"' >>"$script_name"
  for i in "${!required_args[@]}"; do
    arg="${required_args[$i]}"
    desc="${required_desc[$i]}"
    echo "    echo \"  ${arg}    ${desc}\"" >>"$script_name"
  done
fi

# Add optional arguments to usage
if [[ ${#optional_args[@]} -gt 0 ]]; then
  echo '    echo "[OPTIONAL]"' >>"$script_name"
  for i in "${!optional_args[@]}"; do
    arg="${optional_args[$i]}"
    desc="${optional_desc[$i]}"
    default="${optional_defaults[$i]}"
    if [[ -n $default ]]; then
      echo "    echo \"  -${arg}    ${desc} (default: ${default})\"" >>"$script_name"
    else
      echo "    echo \"  -${arg}    ${desc}\"" >>"$script_name"
    fi
  done
fi

# Finish usage function and add version
cat >>"$script_name" <<'EOF'
    exit 0
}

# Version function
version() {
    echo "$VERSION"
    exit 0
}

# Check if help or version is requested
if [[ "$1" == "-h" ]]; then
    usage
fi
if [[ "$1" == "--version" ]]; then
    version
fi

EOF

# Initialize optional arguments with defaults
for i in "${!optional_args[@]}"; do
  internal="${optional_internal[$i]}"
  default="${optional_defaults[$i]}"
  if [[ -n $default ]]; then
    echo "${internal}=\"${default}\"" >>"$script_name"
  else
    echo "${internal}=" >>"$script_name"
  fi
done

# Construct the getopts string for optional arguments
getopts_string="h"
for arg in "${optional_args[@]}"; do
  getopts_string="${getopts_string}${arg}:"
done

# Add the getopts parsing loop for optional arguments
cat >>"$script_name" <<EOF
# Parse optional arguments with getopts
while getopts "$getopts_string" opt; do
    case "\$opt" in
        h) usage ;;
EOF

# Add cases for optional arguments
for i in "${!optional_args[@]}"; do
  arg="${optional_args[$i]}"
  internal="${optional_internal[$i]}"
  cat >>"$script_name" <<EOF
        ${arg}) ${internal}="\$OPTARG" ;;
EOF
done

# Finish the getopts loop
cat >>"$script_name" <<'EOF'
        ?) usage ;;
    esac
done

# Shift past the options
shift $((OPTIND-1))

EOF

# Add checks for required positional inputs
if [[ ${#required_args[@]} -gt 0 ]]; then
  cat >>"$script_name" <<EOF
# Check required positional inputs
if [[ \$# -lt ${#required_args[@]} ]]; then
    echo "Error: Missing required positional inputs"
    usage
fi

EOF
  for i in "${!required_args[@]}"; do
    arg="${required_args[$i]}"
    cat >>"$script_name" <<EOF
${arg^^}=\$$((i + 1))
EOF
  done
fi

# Add a placeholder for the main script logic
cat >>"$script_name" <<'EOF'

# Main script logic here
echo "Script running with the following inputs:"
EOF

# Echo required positional inputs
for arg in "${required_args[@]}"; do
  echo "echo \"${arg}: \$${arg^^}\"" >>"$script_name"
done

# Echo optional arguments
for i in "${!optional_args[@]}"; do
  arg="${optional_args[$i]}"
  internal="${optional_internal[$i]}"
  echo "echo \"-${arg}: \$${internal}\"" >>"$script_name"
done

# Finalize the script
cat >>"$script_name" <<'EOF'

# Add your script logic below
EOF

# Make the script executable
chmod +x "$script_name"

echo "Script '$script_name' has been created successfully."
