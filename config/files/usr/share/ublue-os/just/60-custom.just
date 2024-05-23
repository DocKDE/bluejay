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


# Setup for personal dev work
dev-setup:
    #!/usr/bin/env bash
    ulimit -n 4096
    just --unstable install-brew && \
    grep -v '^#' /usr/share/brew-packages.txt | xargs /home/linuxbrew/.linuxbrew/bin/brew install
    just --unstable terminal-theme
    just --unstable docker
    just --unstable podman
    just --unstable dotfiles
    just --unstable zsh
    just --unstable rustup
    just --unstable zed
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

# Set up rustup
rustup:
    #!/usr/bin/env bash
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Set up Zed 
zed:
    #!/usr/bin/env bash
    mkdir -p /home/$USER/Code/zed
    git clone --recurse-submodules https://github.com/zed-industries/zed.git /home/$USER/Code/zed

    cat << EOF > /home/$USER/.local/share/applications/zed.desktop
    [Desktop Entry]
    Version=1.0
    Type=Application
    Name=Zed
    GenericName=Text Editor
    Comment=A high-performance, multiplayer code editor.
    StartupNotify=true
    Exec=/home/$USER/Code/zed/target/release/Zed
    Icon=/home/$USER/Code/zed/crates/zed/resources/app-icon-dev@2x.png

    Categories=TextEditor;Development;IDE;
    Keywords=zed;
    MimeType=text/plain;inode/directory;
    EOF
