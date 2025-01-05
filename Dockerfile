# ENV GIT_REPO=$GIT_REPO

FROM archlinux:base-devel
ARG GIT_REPO="https://github.com/s0urce-c0de/autorecotossd"

RUN pacman -Syu --needed --noconfirm git jq github-cli unzip
RUN useradd --create-home runner && (printf "runner ALL=(ALL:ALL) NOPASSWD:ALL\n" >> /etc/sudoers)

USER runner
ENV HOME /home/runner
WORKDIR $HOME
RUN git clone https://aur.archlinux.org/yay.git yay
WORKDIR $HOME/yay
RUN makepkg -sri --needed --noconfirm
WORKDIR $HOME
RUN rm -rf $HOME/.cache $HOME/yay

RUN git clone $GIT_REPO autorecotossd
WORKDIR $HOME/autorecotossd

RUN yay -S --noconfirm vboot-utils >/dev/null
RUN yay -Scc

