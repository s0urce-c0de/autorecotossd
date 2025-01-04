FROM archlinux:base-devel

ENV HOME /home/runner
RUN mkdir -p $HOME

RUN pacman -Syu --needed --noconfirm git jq github-cli unzip
RUN useradd --create-home runner && (printf "runner ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/runner.rules)

USER runner
WORKDIR $HOME
RUN git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -sri --needed --noconfirm && rm -rf $HOME/.cache $HOME/yay

RUN git clone $GIT_REPO autorecotossd
WORKDIR $HOME/autorecotossd

RUN yay -S --noconfirm vboot-utils >/dev/null
RUN yay -Scc

./fetch_iter.sh
