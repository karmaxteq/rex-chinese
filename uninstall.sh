#!/bin/sh
set -eu
if [ -d "$HOME/Applications/Rex Beta 中文版.app" ]; then
  mv "$HOME/Applications/Rex Beta 中文版.app" "$HOME/.Trash/Rex Beta 中文版.app"
fi
echo '已移除补丁副本；原应用未修改。'
