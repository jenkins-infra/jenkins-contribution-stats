# This Dockerfile is used as a minimum image for the Jenkins Top Submitters GitHub Action.

# We start from the golang:1.25.2-trixie base image.
FROM golang:1.25.2-trixie

# We declare an ARG for the GitHub token, which will be used for authentication.
ARG GITHUB_TOKEN
# We set an environment variable with the GitHub token.
ENV GITHUB_TOKEN=$GITHUB_TOKEN

# We declare ARGs for the user ID and group ID.
ARG USER_ID
ARG GROUP_ID

# We update the package lists for upgrades for packages that need upgrading, as well as new packages that have just come to the repositories.
# We install datamash, git, jq, sudo, and GitHub CLI.
# We also check if wget is installed, if not, we install it.
# We create a directory for the GitHub CLI keyring and download the keyring.
# We add the GitHub CLI repository to the sources list.
# We update the package lists again and install the GitHub CLI.
RUN apt update && apt install -y datamash git jq python3 python3-venv sudo && \
        (type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) \
        && sudo mkdir -p -m 755 /etc/apt/keyrings \
        && wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
        && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
        && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
        && sudo apt update \
        && sudo apt install gh -y

# Create a virtual environment
RUN python3 -m venv /opt/venv

# Activate the virtual environment
ENV PATH="/opt/venv/bin:$PATH"

# We create a new user called linuxbrew with home directory and zsh as default shell.
# We add the user to the sudo group.
# We create a directory for linuxbrew and change its owner to linuxbrew.
RUN useradd -m -s /bin/zsh linuxbrew && \
    usermod -aG sudo linuxbrew &&  \
    mkdir -p /home/linuxbrew/.linuxbrew && \
    chown -R linuxbrew: /home/linuxbrew/.linuxbrew

# We switch to the linuxbrew user.
USER linuxbrew

# We run the Homebrew installation script.
RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

# We switch back to the root user.
USER root

# We create a symbolic link from the date command to /bin/gdate.
# We make the Homebrew directory world-readable so any user can execute the binaries.
RUN ln -s $(which date) /bin/gdate && \
        chmod -R a+rX /home/linuxbrew/.linuxbrew

# We add the linuxbrew bin directory to the PATH environment variable.
ENV PATH="/home/linuxbrew/.linuxbrew/bin:${PATH}"

# We configure git to add a safe directory.
RUN git config --global --add safe.directory /home/linuxbrew/.linuxbrew/Homebrew

# We switch back to the linuxbrew user.
USER linuxbrew

# We update Homebrew and run the doctor command to check for potential problems.
RUN brew update && \
    brew doctor

# We tap a custom Homebrew repository.
# We install the jenkins-contribution-extractor and jenkins-contribution-aggregator packages from the custom repository.
RUN brew tap jenkins-infra/tap && \
    brew install jenkins-contribution-extractor && \
    brew install  jenkins-contribution-aggregator

# We switch back to the root user.
USER root

# Apply world-readable permissions again after brew install to ensure installed binaries are accessible
RUN chmod -R a+rX /home/linuxbrew/.linuxbrew

# Create the /home/runner directory that will be used by the runtime user
# The actual user will be specified via -u flag when running the container
RUN mkdir -p /home/runner && chmod 777 /home/runner
