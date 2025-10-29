# Brew stuff
brew ACTION="prompt":
    #!/usr/bin/env bash
    source /usr/lib/ujust/ujust.sh

    install-all-packages () {
        BREWFILE_PATH="/etc/brew/cli.Brewfile"
        export HOMEBREW_BUNDLE_NO_LOCKFILE_WRITE_WARNING=1
        brew bundle install --file "${BREWFILE_PATH}"
    }

    remove-all-packages () {
        brew remove --force $(brew list --formula) --ignore-dependencies
    }

    OPTION={{ ACTION }}
    if [ "${OPTION}" == "prompt" ]; then
        OPTION=$(ugum choose "install-all-packages" "remove-all-packages")
    fi

    if [ "${OPTION}" == "install-all-packages" ]; then
        install-all-packages
    elif [ "${OPTION}" == "remove-all-packages" ]; then
        remove-all-packages
    else
        echo "No changes applied."
        exit 0
    fi
