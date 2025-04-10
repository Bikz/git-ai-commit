#!/bin/bash
# Simple installer for g. (git-ai-commit)

# --- Configuration ---
GITHUB_USER="Bikz"
REPO_NAME="git-ai-commit"
SCRIPT_NAME="g."
DEFAULT_MODEL="qwen2.5-coder:1.5b" # Default model to check for
BRANCH="main"
INSTALL_DIR="$HOME/.local/bin"
# --- End Configuration ---

SCRIPT_URL="https://raw.githubusercontent.com/${GITHUB_USER}/${REPO_NAME}/${BRANCH}/${SCRIPT_NAME}"
SCRIPT_PATH="${INSTALL_DIR}/${SCRIPT_NAME}"

# --- Helper Functions ---
echo_green() {
  echo -e "\033[0;32m$1\033[0m"
}
echo_red() {
  echo -e "\033[0;31m$1\033[0m" >&2 # Error color
}
echo_yellow() {
  echo -e "\033[0;33m$1\033[0m" # Warning/Info color
}
echo_info() {
  echo -e "\033[0;37m$1\033[0m" # White color
}

# --- ASCII Art Function ---
# Prints the logo with specific colors using the new 'g.' art
print_logo() {
    local color1="\033[0;32m" # Green for g.
    local color2="\033[0;33m" # Yellow for text
    local nc="\033[0m"       # No Color

    echo -e "${color1} __ _      ${nc}"
    echo -e "${color1} / _\` |     ${nc}"
    echo -e "${color1}| (_| |    ${nc}  ${color2}git-ai-commit${nc}"  
    echo -e "${color1} \\__, | (_)${nc}  ${color2}---------------${nc}"
    echo -e "${color1}  __/ |    ${nc}  ${color2}Repo: https://github.com/${GITHUB_USER}/${REPO_NAME}${nc}"
    echo -e "${color1} |___/     ${nc}"
    echo "" # Add a blank line after logo
}
# --- End ASCII Art Function ---


check_requirements() {
  local REQUIREMENTS_MET=true
  local OLLAMA_FOUND=false
  local OS_TYPE
  OS_TYPE=$(uname -s)

  # Check for Git
  if ! command -v git &> /dev/null; then
    REQUIREMENTS_MET=false
    guide_git_install
  fi

  # Check for jq
  if ! command -v jq &> /dev/null; then
    REQUIREMENTS_MET=false
    guide_jq_install
  fi

  # Check for Ollama installation
  if ! command -v ollama &> /dev/null; then
    REQUIREMENTS_MET=false
    guide_ollama_install
  else
    OLLAMA_FOUND=true
  fi

  # Only check for model if ollama command exists
  if [ "$OLLAMA_FOUND" = true ]; then
    echo_info "Checking for default model '${DEFAULT_MODEL}'..."
    if ! ollama list | grep -q "^${DEFAULT_MODEL}"; then
      if ! guide_model_install; then
        REQUIREMENTS_MET=false
      fi
    else
        echo_green "Default model '${DEFAULT_MODEL}' found."
    fi
  fi

  if [ "$REQUIREMENTS_MET" = true ]; then
    return 0 # All met
  else
    return 1 # At least one missing
  fi
}

guide_git_install() {
  echo_info "====================================================="
  echo_yellow "ACTION REQUIRED: Git is not installed or not in PATH"
  echo_yellow "Git is required to use ${SCRIPT_NAME}."
  local OS_TYPE
  OS_TYPE=$(uname -s)
  echo_yellow "Please install Git for your system:"
  echo ""
  if [[ "$OS_TYPE" == "Darwin" ]]; then
    echo_info "  On macOS (using Homebrew): brew install git"
    echo_info "  Or download from: https://git-scm.com/download/mac"
  elif [[ "$OS_TYPE" == "Linux" ]]; then
      echo_info "  On Debian/Ubuntu: sudo apt update && sudo apt install git"
      echo_info "  On Fedora: sudo dnf install git"
      echo_info "  Or check: https://git-scm.com/download/linux"
  else
      echo_info "  Download from: https://git-scm.com/download"
  fi
  echo ""
  echo_yellow "Then re-run this installer script:"
  echo_info "  curl -s https://raw.githubusercontent.com/${GITHUB_USER}/${REPO_NAME}/main/install.sh | bash"
  echo_info "====================================================="
  return 1
}

guide_jq_install() {
  echo_info "====================================================="
  echo_yellow "ACTION REQUIRED: jq is not installed or not in PATH"
  echo_yellow "'jq' is required by ${SCRIPT_NAME} for processing AI responses."
  local OS_TYPE
  OS_TYPE=$(uname -s)
  echo_yellow "Please install jq for your system:"
  echo ""
  if [[ "$OS_TYPE" == "Darwin" ]]; then
      echo_info "  On macOS (using Homebrew): brew install jq"
  elif [[ "$OS_TYPE" == "Linux" ]]; then
      echo_info "  On Debian/Ubuntu: sudo apt update && sudo apt install jq"
      echo_info "  On Fedora: sudo dnf install jq"
  else
      echo_info "  Check download options at: https://jqlang.github.io/jq/download/"
  fi
  echo ""
  echo_yellow "Then re-run this installer script:"
  echo_info "  curl -s https://raw.githubusercontent.com/${GITHUB_USER}/${REPO_NAME}/main/install.sh | bash"
  echo_info "====================================================="
  return 1
}


guide_ollama_install() {
   echo_info "====================================================="
  echo_yellow "ACTION REQUIRED: Ollama is not installed or not in PATH"
  local OS_TYPE
  OS_TYPE=$(uname -s)

  if [[ "$OS_TYPE" == "Darwin" ]]; then
    # macOS Instructions
    echo_info "Please download and install Ollama for macOS from:"
    echo ""
    echo_info "  https://ollama.com/download"
    echo ""
    echo_info "After installing:"
    echo_info "  1. Open the Ollama application"
    echo_info "  2. Pull the required model with:"
    echo_info "     ollama pull ${DEFAULT_MODEL}"
  elif [[ "$OS_TYPE" == "Linux" ]]; then
    # Linux Instructions
    echo_info "Please install Ollama for Linux with:"
    echo ""
    echo_info "  curl -fsSL https://ollama.com/install.sh | sh"
    echo ""
    echo_info "After installing:"
    echo_info "  1. Start Ollama: ollama serve &"
    echo_info "  2. Pull the required model:"
    echo_info "     ollama pull ${DEFAULT_MODEL}"
  else
    # Other OS - General Link
    echo_info "Please install Ollama from:"
    echo ""
    echo_info "  https://ollama.com/download"
    echo ""
    echo_info "After installing, pull the required model:"
    echo_info "  ollama pull ${DEFAULT_MODEL}"
  fi

  echo ""
  echo_info "Then re-run this installer:"
  echo_info "  curl -s https://raw.githubusercontent.com/${GITHUB_USER}/${REPO_NAME}/main/install.sh | bash"
  echo_info "====================================================="
  return 1 # Signal missing requirement
}

guide_model_install() {
  echo_info "====================================================="
  echo_yellow "ACTION REQUIRED: Default model '${DEFAULT_MODEL}' is not installed"
  
  echo_info "Please install the model with:"
  echo_info "  ollama pull ${DEFAULT_MODEL}"
  echo_info "Model size: ~1GB (This may take a few minutes)"
  
  echo ""
  echo_info "Then re-run this installer:"
  echo_info "  curl -s https://raw.githubusercontent.com/${GITHUB_USER}/${REPO_NAME}/main/install.sh | bash"
  echo_info "====================================================="
  return 1 # Signal missing requirement
}
# --- End Helper Functions ---

# --- Installation Start ---
echo ""
print_logo # Print the new logo
echo ""
echo_yellow " <<< Welcome to the installer! >>>"
echo_info "   Let's set up this handy Git utility for you."
echo ""

# --- Main Installation Process ---
mkdir -p "${INSTALL_DIR}" || {
  echo_red "Error: Failed to create installation directory ${INSTALL_DIR}"
  exit 1
}

# Check if INSTALL_DIR is in PATH and provide guidance if not
PATH_CONFIGURED=false
echo_info "Checking PATH configuration..."
case ":$PATH:" in
  *":${INSTALL_DIR}:"*)
    echo_green "'${INSTALL_DIR}' found in your PATH."
    PATH_CONFIGURED=true
    ;;
  *)
    echo_yellow "NOTE: To run '${SCRIPT_NAME}' directly, '${INSTALL_DIR}' needs to be in your PATH."
    echo_info "You might need to add the following line to your shell profile (e.g., ~/.bashrc, ~/.zshrc):"
    echo ""
    echo_info "  export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo ""
    echo_info "After adding it, restart your terminal or run 'source ~/.your_shell_profile_file'."
    PATH_CONFIGURED=false
    ;;
esac

# Download the script using curl (-L follows redirects)
echo_info "Downloading script from ${SCRIPT_URL}..."
if curl -fsSL "${SCRIPT_URL}" -o "${SCRIPT_PATH}"; then
  echo_green "Script downloaded successfully."
else
  echo_red "Error: Failed to download script from ${SCRIPT_URL}"
  echo_red "Please check the URL, repository permissions, and your internet connection."
  exit 1
fi

# Make the script executable
if ! chmod +x "${SCRIPT_PATH}"; then
    echo_red "Error: Failed to make script executable at ${SCRIPT_PATH}"
    rm -f "${SCRIPT_PATH}" > /dev/null 2>&1 # Clean up
    exit 1
fi
echo_green "'${SCRIPT_NAME}' is now executable."
echo ""

# --- Post-installation Checks ---
echo_info "Running post-installation checks..."
ALL_REQS_MET=true
# No divider here - guide functions will add their own
if ! check_requirements; then
  ALL_REQS_MET=false
else
  echo_green "All requirements met! You're good to go."
  echo_info "====================================================="
fi

# --- Final Message ---
# No divider here - we'll add it in each condition branch
if [ "$ALL_REQS_MET" = true ] && [ "$PATH_CONFIGURED" = true ]; then
  echo_info "====================================================="
  echo_green "      SUCCESS! Installation complete!"
  echo_green "      You're ready to use git-ai-commit!"
  echo_info "====================================================="
  echo ""
  echo_info " To use it, navigate to a Git repository with changes"
  echo_info " and simply run:"
  echo ""
  echo_yellow "   g."
  echo ""
  echo_info " This will stage all changes, generate an AI commit message,"
  echo_info " commit, and push."
  echo ""
  echo_info " To provide your own message, use:"
  echo_yellow "   g. \"Your awesome commit message\""
  echo ""
  echo_green " Happy committing!"

elif [ "$ALL_REQS_MET" = true ] && [ "$PATH_CONFIGURED" = false ]; then
    echo_info "====================================================="
    echo_yellow "      ALMOST THERE!"
    echo ""
    echo_info "Script installed and requirements met,"
    echo_yellow "but your PATH needs configuration (see above)."
    echo ""
    echo_info "Once PATH is updated, '${SCRIPT_NAME}' will be ready to use!"
    echo_info "====================================================="
else # Requirements not met
  # Only need one divider at the top and one at the bottom for the final message
  echo_info "====================================================="
  echo_red "      INSTALLATION INCOMPLETE"
  echo_info "====================================================="
  # The detailed instructions have already been shown above,
  # so we don't need to repeat them here
fi
echo ""
exit 0