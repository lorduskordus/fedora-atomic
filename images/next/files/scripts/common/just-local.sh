#!/usr/bin/env bash

# Creates an environment for 'ljust' (local just)

set -euo pipefail

echo "Creating an environment for 'ljust' (local just)"

# Create a "binary" script
LJUST_BIN="/usr/bin/ljust"
cat << 'EOF' > "${LJUST_BIN}"
#!/usr/bin/bash

/usr/bin/just --justfile ${HOME}/.local/share/bluebuild/justfile "${@}"
EOF
chmod +x "${LJUST_BIN}"

# Create a main controlling justfile
BLUEBUILD_DIR="/etc/skel/.local/share/bluebuild"
mkdir -p "${BLUEBUILD_DIR}"
cat << 'EOF' > "${BLUEBUILD_DIR}/justfile"
set allow-duplicate-recipes := true
set ignore-comments := true

_default:
    #!/usr/bin/bash
    /usr/bin/just --list --list-heading $'Available commands:\n' --list-prefix $' - '

# Imports
import "just/system.just"
EOF

# Create an example .just file in just directory
LJUSTFILES_DIR="${BLUEBUILD_DIR}/just"
mkdir -p "${LJUSTFILES_DIR}"
cat << 'EOF' > "${LJUSTFILES_DIR}/system.just"
# Run to see what's up
initial-command:
    #!/usr/bin/env bash
    echo "Add, remove or edit commands in '${HOME}/.local/share/bluebuild'"
EOF
