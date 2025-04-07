#!/bin/bash
# A script to generate a new shell script template with specified options

# Function to validate single-character argument names
validate_single_char() {
  local arg_name="$1"
  if [[ ! "$arg_name" =~ ^[a-zA-Z]$ ]]; then
    echo "Error: Argument name '$arg_name' must be a single letter."
    exit 1
  fi
  if [[ "$arg_name" == "h" || "$arg_name" == "v" ]]; then
    echo "Error: Argument name '$arg_name' is reserved for help (-h) or version (-v)."
    exit 1
  fi
}

# Prompt for the script name
read -p "Enter the name of the script to create (e.g., myscript.sh): " script_name
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
read -p "Enter a one-line explanation of what the script does: " script_desc
if [[ -z "$script_desc" ]]; then
  echo "Error: Script description cannot be empty."
  exit 1
fi

# Prompt for required arguments
echo "Enter required arguments (single letters, one at a time). Press Enter without input to finish."
required_args=()
required_desc=()
while true; do
  read -p "Required argument letter (or Enter to finish): " arg
  if [[ -z "$arg" ]]; then
    break
  fi
  validate_single_char "$arg"
  read -p "Description for -$arg: " desc
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
optional_desc=()
optional_defaults=()
while true; do
  read -p "Optional argument letter (or Enter to finish): " arg
  if [[ -z "$arg" ]]; then
    break
  fi
  validate_single_char "$arg"
  read -p "Description for -$arg: " desc
  if [[ -z "$desc" ]]; then
    echo "Error: Description cannot be empty."
    exit 1
  fi
  read -p "Default value for -$arg (or Enter for none): " default
  optional_args+=("$arg")
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
    echo "Usage: $script_basename [options]"
    echo "Options:"
    echo "  -h    Display this help message"
    echo "  -v    Display version information"
EOF

# Add required arguments to usage
for i in "${!required_args[@]}"; do
  arg="${required_args[$i]}"
  desc="${required_desc[$i]}"
  echo "    echo \"  -${arg}    ${desc}\"" >>"$script_name"
done

# Add optional arguments to usage
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

# Finish usage function and add version
cat >>"$script_name" <<'EOF'
    exit 0
}

# Version function
version() {
    echo "$VERSION"
    exit 0
}

# Check if no arguments are provided
if [[ $# -eq 0 ]]; then
    usage
fi

EOF

# Initialize optional arguments with defaults
for i in "${!optional_args[@]}"; do
  arg="${optional_args[$i]}"
  default="${optional_defaults[$i]}"
  if [[ -n "$default" ]]; then
    echo "${arg}=\"${default}\"" >>"$script_name"
  else
    echo "${arg}=" >>"$script_name"
  fi
done

# Construct the getopts string
getopts_string="hv"
for arg in "${required_args[@]}"; do
  getopts_string="${getopts_string}${arg}:"
done
for arg in "${optional_args[@]}"; do
  getopts_string="${getopts_string}${arg}:"
done

# Add the getopts parsing loop
cat >>"$script_name" <<EOF

# Parse options with getopts
while getopts "$getopts_string" opt; do
    case "\$opt" in
        h) usage ;;
        v) version ;;
EOF

# Add cases for required arguments
for arg in "${required_args[@]}"; do
  cat >>"$script_name" <<EOF
        ${arg}) ${arg}="\$OPTARG" ;;
EOF
done

# Add cases for optional arguments
for arg in "${optional_args[@]}"; do
  cat >>"$script_name" <<EOF
        ${arg}) ${arg}="\$OPTARG" ;;
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

# Add checks for required arguments
for arg in "${required_args[@]}"; do
  cat >>"$script_name" <<EOF
if [[ -z "\$${arg}" ]]; then
    echo "Error: Required argument -${arg} missing"
    usage
fi
EOF
done

# Add a placeholder for the main script logic
cat >>"$script_name" <<'EOF'

# Main script logic here
echo "Script running with the following arguments:"
EOF

# Echo required arguments
for arg in "${required_args[@]}"; do
  echo "echo \"-${arg}: \$${arg}\"" >>"$script_name"
done

# Echo optional arguments
for arg in "${optional_args[@]}"; do
  echo "echo \"-${arg}: \$${arg}\"" >>"$script_name"
done

# Finalize the script
cat >>"$script_name" <<'EOF'

# Add your script logic below
EOF

# Make the script executable
chmod +x "$script_name"

echo "Script '$script_name' has been created successfully."
