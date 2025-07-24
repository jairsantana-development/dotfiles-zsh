#!/bin/bash

set -e

echo "🚀 Iniciando instalação do ambiente zsh..."

# 1. Instalar dependências
echo "📦 Instalando dependências..."
if command -v apt &> /dev/null; then
    sudo apt update
    sudo apt install -y zsh git curl fzf
elif command -v dnf &> /dev/null; then
    sudo dnf install -y zsh git curl fzf
elif command -v pacman &> /dev/null; then
    sudo pacman -Sy --noconfirm zsh git curl fzf
else
    echo "❌ Gerenciador de pacotes não suportado. Instale zsh, git, curl e fzf manualmente."
    exit 1
fi

# 2. Backup do .zshrc atual
echo "📁 Fazendo backup do .zshrc existente (se houver)..."
[ -f ~/.zshrc ] && mv ~/.zshrc ~/.zshrc.backup.$(date +%s)

# 3. Instalar Oh My Zsh (se não existir)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "💡 Instalando Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# 4. Instalar zinit
ZINIT_DIR="$HOME/.local/share/zinit/zinit.git"
if [ ! -d "$ZINIT_DIR" ]; then
    echo "⚙️  Instalando zinit..."
    mkdir -p "$(dirname $ZINIT_DIR)"
    git clone https://github.com/zdharma-continuum/zinit "$ZINIT_DIR"
fi

# 5. Instalar tema spaceship (se não existir)
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/spaceship-prompt" ]; then
    echo "🎨 Instalando tema spaceship-prompt..."
    git clone https://github.com/spaceship-prompt/spaceship-prompt.git \
        "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/spaceship-prompt" --depth=1
    ln -sfn "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/spaceship-prompt/spaceship.zsh-theme" \
        "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/spaceship.zsh-theme"
fi

# 6. Link do .zshrc customizado
echo "🔗 Criando symlink do .zshrc..."
ln -sf "$(pwd)/.zshrc" "$HOME/.zshrc"

# 7. Trocar shell padrão para zsh
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "🌀 Mudando shell padrão para zsh..."
    chsh -s "$(which zsh)"
fi

# Clonar plugins customizados
echo "🔧 Instalando plugins customizados do Oh My Zsh..."

ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

# fzf-tab
if [ ! -d "$ZSH_CUSTOM/plugins/fzf-tab" ]; then
  git clone https://github.com/Aloxaf/fzf-tab "$ZSH_CUSTOM/plugins/fzf-tab"
fi

# zsh-autosuggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

# k (atalho para kubectl com completions e helpers)
if [ ! -d "$ZSH_CUSTOM/plugins/k" ]; then
  git clone https://github.com/superbrothers/zsh-kubectl-prompt "$ZSH_CUSTOM/plugins/k"
fi


echo "✅ Ambiente ZSH instalado com sucesso!"
echo "ℹ️ Reinicie o terminal ou rode 'zsh' para testar."
