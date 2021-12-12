#!/bin/bash

CURDIR=$(realpath $(dirname $0))
COMPLETION_INSTALL_PATH=/usr/share/bash-completion/completions/lysithea

echo "[+] installing bash-completion..."
sudo cp ./lysithea.completion.bash /usr/share/bash-completion/completions/lysithea || exit
sudo chmod 644 "$COMPLETION_INSTALL_PATH"
sudo chown root:root "$COMPLETION_INSTALL_PATH"

echo "[+] installing deps..."
read -p " want to install recommended deps? > " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
  INSTALL_RECOMMENDED=1
fi
sudo apt install $(cat ./build/pkglist.required) -y
if [ -n "$INSTALL_RECOMMENDED" ]; then
  sudo apt install $(cat ./build/pkglist.recommend) -y
fi

echo "[+] Installation suceeds!"

echo "[!] Edit your .bashrc to modify \$PATH:"
echo ""
echo "PATH=$CURDIR:\$PATH"
