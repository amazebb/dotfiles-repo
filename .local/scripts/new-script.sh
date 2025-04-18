#!/opt/homebrew/bin/bash
# A script to generate a new shell script template with specified positional inputs and optional arguments

# Function to validate argument names (no longer restricted to single chars, but can't be 'h' or 'v')
validate_arg_name() {
  local arg_name="$1"
  if [[ "$arg_name" == "h" || "$arg_name" == "v" ]]; then
    echo "Error: Argument name '$arg_name' is reserved for help (-h) or version (-v)."
    exit 1
  fi
}

# Prompt for the script name
read -r -p "Enter the name of the script to create (e.g., myscript.sh): " script_name
if [[ -z "$script_name" ]]; then
  echo "Error: Script name cannot be empty."
  exit 1
fi

# Ensure the script name ends with .sh
if [[ ! "$script_name" =~ \.sh$ ]]; then
  script_name="$script_name.sh"
fi

# Check if file already exists
if [[ -f "$script_name" ]]; then
  echo "Error: File '$script_name' already exists."
  exit 1
fi

# Prompt for script description
read -r -p "Enter a one-line explanation of what the script does: " script_desc
if [[ -z "$script_desc" ]]; then
  echo "Error: Script description cannot be empty."
  exit 1
fi

# Prompt for required positional inputs
echo "Enter required positional inputs (one at a time)"
required_args=()
required_desc=()
while true; do
  read -r -p "Required input name (or Enter to finish): " arg
  if [[ -z "$arg" ]]; then
    break
  fi
  validate_arg_name "$arg"
  read -r -p "Description for $arg: " desc
  if [[ -z "$desc" ]]; then
    echo "Error: Description cannot be empty."
    exit 1
  fi
  required_args+=("$arg")
  required_desc+=("$desc")
done

# Prompt for optional arguments
echo "Enter optional arguments (single letters, one at a time). Press Enter without input to finish."
optional_args=()
optional_internal=()
optional_desc=()
optional_defaults=()
while true; do
  read -r -p "Optional argument letter (or Enter to finish): " arg
  if [[ -z "$arg" ]]; then
    break
  fi
  validate_arg_name "$arg"
  read -r -p "Internal variable name for -$arg (Enter to use '$arg'): " internal
  if [[ -z "$internal" ]]; then
    internal="$arg"
  fi
  read -r -p "Description for -$arg: " desc
  if [[ -z "$desc" ]]; then
    echo "Error: Description cannot be empty."
    exit 1
  fi
  read -r -p "Default value for -$arg (or Enter for none): " default
  optional_args+=("$arg")
  optional_internal+=("${internal^^}")
  optional_desc+=("$desc")
  optional_defaults+=("$default")
done

# Extract basename for help message
script_basename=$(basename "$script_name" .sh)

# Start generating the script
cat >"$script_name" <<EOF
#!/bin/bash

# $script_name: $script_desc

# Version
VERSION="1.0.0"

# Help function
usage() {
    echo "Usage: $script_basename"
EOF

# Add required positional inputs to usage
if [[ ${#required_args[@]} -gt 0 ]]; then
  echo "    echo \"Required inputs:\"" >>"$script_name"
  for i in "${!required_args[@]}"; do
    arg="${required_args[$i]}"
    desc="${required_desc[$i]}"
    echo "    echo \"  ${arg}    ${desc}\"" >>"$script_name"
  done
fi

# Add optional arguments to usage
if [[ ${#optional_args[@]} -gt 0 ]]; then
  echo "    echo \"[OPTIONAL]\"" >>"$script_name"
  for i in "${!optional_args[@]}"; do
    arg="${optional_args[$i]}"
    desc="${optional_desc[$i]}"
    default="${optional_defaults[$i]}"
    if [[ -n "$default" ]]; then
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
if [[ "$1" == "-v" ]]; then
    version
fi

EOF

# Initialize optional arguments with defaults
for i in "${!optional_args[@]}"; do
  internal="${optional_internal[$i]}"
  default="${optional_defaults[$i]}"
  if [[ -n "$default" ]]; then
    echo "${internal}=\"${default}\"" >>"$script_name"
  else
    echo "${internal}=" >>"$script_name"
  fi
done

# Construct the getopts string for optional arguments
getopts_string="hv"
for arg in "${optional_args[@]}"; do
  getopts_string="${getopts_string}${arg}:"
done

# Add the getopts parsing loop for optional arguments
cat >>"$script_name" <<EOF
# Parse optional arguments with getopts
while getopts "$getopts_string" opt; do
    case "\$opt" in
        h) usage ;;
        v) version ;;
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
