import '100-bling.just'
# Include some of your custom scripts here!

# Set up dotfiles
dotfiles:
    /usr/bin/git clone --bare https://codeberg.org/theDoctor/dotfiles.git $HOME/.cfg
    /usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME config --local status.showUntrackedFiles no
    /usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME checkout -f

# Add user to docker group
containers:
    sudo usermod -aG docker $USER
    sudo systemctl enable --now docker
    systemctl --user enable --now podman.socket

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
    just --unstable containers
    just --unstable dotfiles
    just --unstable zsh
    just --unstable rustup
    echo "Setup done. Please restart the machine."

# Set up rustup
rustup:
    #!/usr/bin/env bash
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
