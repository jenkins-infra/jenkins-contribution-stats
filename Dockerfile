# This Dockerfile is used to build an image for a Go application.

# We start from the golang:1.22.3-bookworm base image.
FROM golang:1.22.3-bookworm

# We declare an ARG for the GitHub token, which will be used for authentication.
ARG GITHUB_TOKEN
# We set an environment variable with the GitHub token.
ENV GITHUB_TOKEN=$GITHUB_TOKEN

# We update the package lists for upgrades for packages that need upgrading, as well as new packages that have just come to the repositories.
# We install datamash, git, sudo, and GitHub CLI.
# We also check if wget is installed, if not, we install it.
# We create a directory for the GitHub CLI keyring and download the keyring.
# We add the GitHub CLI repository to the sources list.
# We update the package lists again and install the GitHub CLI.
RUN apt update && apt install -y datamash git jq sudo && \
        (type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) \
        && sudo mkdir -p -m 755 /etc/apt/keyrings \
        && wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
        && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
        && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
        && sudo apt update \
        && sudo apt install gh -y

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

# We change the owner of the linuxbrew directory to the container user.
RUN chown -R $CONTAINER_USER: /home/linuxbrew/.linuxbrew

# We add the linuxbrew bin directory to the PATH environment variable.
ENV PATH="/home/linuxbrew/.linuxbrew/bin:${PATH}"

# We configure git to add a safe directory.
RUN git config --global --add safe.directory /home/linuxbrew/.linuxbrew/Homebrew

# We switch back to the linuxbrew user.
USER linuxbrew

# We update Homebrew and run the doctor command to check for potential problems.
RUN brew update && \
    brew doctor

# We switch back to the root user.
USER root

# We create a symbolic link from the date command to /bin/gdate.
# We tap a custom Homebrew repository.
# We install the jenkins-stats and jenkins-top-submitters packages from the custom repository.
RUN ln -s $(which date) /bin/gdate && \
    brew tap jmMeessen/tap && \
    brew install jenkins-stats && \
    brew install jenkins-top-submitters

# Copy the generateHonoredContribDataFile.sh script into the Docker image
COPY *.sh /

# Make the script executable
RUN chmod +x /*.sh
