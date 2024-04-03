import '100-bling.just'
# Include some of your custom scripts here!

# Install JetBrains Toolbox | https://www.jetbrains.com/toolbox-app/
jetbrains-toolbox:
    #!/usr/bin/env bash
    pushd "$(mktemp -d)"
    echo "Get latest JetBrains Toolbox version"
    # Get the json with latest releases
    curl -sSfL -o releases.json "https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release"
    # Extract information
    BUILD_VERSION=$(jq -r '.TBA[0].build' ./releases.json)
    DOWNLOAD_LINK=$(jq -r '.TBA[0].downloads.linux.link' ./releases.json)
    CHECKSUM_LINK=$(jq -r '.TBA[0].downloads.linux.checksumLink' ./releases.json)
    echo "Installing JetBrains Toolbox ${BUILD_VERSION}"
    curl -sSfL -O "${DOWNLOAD_LINK}"
    curl -sSfL "${CHECKSUM_LINK}" | sha256sum -c
    tar zxf jetbrains-toolbox-"${BUILD_VERSION}".tar.gz
    echo "Launching JetBrains Toolbox"
    ./jetbrains-toolbox-"${BUILD_VERSION}"/jetbrains-toolbox

# Set up dotfiles
dotfiles:
    /usr/bin/git clone --bare https://codeberg.org/theDoctor/dotfiles.git $HOME/.cfg
    /usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME config --local status.showUntrackedFiles no
    /usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME checkout -f

# Add user to docker group
docker:
    sudo usermod -aG docker $USER
    sudo systemctl enable --now docker

podman:
    systemctl --user enable --now podman.socket

# Install Nix without confirmation needed
install-nix:
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm

# Set zsh as default shell for current user
zsh:
    #!/usr/bin/env bash
    if [[ -f /home/linuxbrew/.linuxbrew/bin/zsh ]]; then
        sudo chsh -s /home/linuxbrew/.linuxbrew/bin/zsh $USER
    else
        sudo chsh -s /usr/bin/zsh $USER
    fi

# Install Catppuccin themes for Gnome-terminal
terminal-theme:
    curl -L https://raw.githubusercontent.com/catppuccin/gnome-terminal/v0.2.0/install.py | python3 -

# Install brew and packages
brew:
    #!/usr/bin/env bash
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && grep -v '^#' /usr/share/brew-packages.txt | xargs brew install

# Setup for personal dev work
dev-setup:
    just --unstable brew
    just --unstable terminal-theme
    just --unstable docker
    just --unstable podman
    just --unstable dotfiles
    just --unstable zsh
    echo "Setup done. Please restart the machine."

# Install devenv
devenv:
    #!/usr/bin/env bash
    if ! grep -q $USER /etc/nix/nix.conf; then
      echo "trusted-users = root $USER" | sudo tee -a /etc/nix/nix.conf && sudo pkill nix-daemon
    fi
    nix profile install nixpkgs#cachix
    cachix use devenv
    nix profile install --accept-flake-config tarball+https://install.devenv.sh/latest

# Pull distrobox images to get updates
distrobox-update:
    podman pull ghcr.io/dockde/arch-distrobox:latest quay.io/toolbx-images/ubuntu-toolbox:latest registry.fedoraproject.org/fedora-toolbox:latest

# Assemble distroboxes from ini file
distrobox-assemble:
    distrobox assemble create --replace --file /usr/share/ublue-os/distrobox/distrobox.ini

# Update and assemble distroboxes from ini
distrobox-create:
    #!/usr/bin/env bash
    if [ -e /run/.containerenv ] || [ -e /.dockerenv ]; then
      printf "This might kill the current shell session! \nPlease run this from a host shell! \n";
    else
      just --unstable distrobox-update
      just --unstable distrobox-assemble
    fi

# Update devbox image
devbox-update:
    podman pull ghcr.io/dockde/arch-distrobox:latest

# (Re)create personal distrobox for dev work
devbox-create:
    #!/usr/bin/env bash
    if [ -e /run/.containerenv ] || [ -e /.dockerenv ]; then
      printf "This might kill the current shell session! \nPlease run this from a host shell! \n";
    else
      podman pull ghcr.io/dockde/arch-distrobox:latest
      /usr/bin/distrobox rm -f arch 2> /dev/null || true
      distrobox create arch -i ghcr.io/dockde/arch-distrobox:latest --volume /usr/share/ublue-os/justfile:/usr/share/ublue-os/justfile --volume /usr/share/ublue-os/just:/usr/share/ublue-os/just --volume /etc/nix/:/etc/nix/
    fi
