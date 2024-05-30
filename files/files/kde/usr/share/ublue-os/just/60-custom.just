_default:
    #!/usr/bin/bash
    source /usr/lib/ujust/libformatting.sh
    /usr/bin/myjust --list --list-heading $'Available commands:\n' --list-prefix $' - '

# Imports
import "/usr/share/ublue-os/just-custom/justfile-base-common"
import "/usr/share/ublue-os/just-custom/justfile-base-kde"