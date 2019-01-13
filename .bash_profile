echo "Logged in as $USER at $(hostname)"

# Path for brew
test -d /usr/local/bin && export PATH="/usr/local/bin:/usr/local/sbin:~/bin:$PATH"

source $HOME/dotfiles/settings.sh
