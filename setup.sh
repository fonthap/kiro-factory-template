#!/bin/bash
# Kiro Factory Template — Setup Script
# Installs as PROJECT-LOCAL (not global) — safe to use alongside other factories
set -e

echo "🏭 Kiro Factory Template Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "This installs the factory INTO YOUR PROJECT DIRECTORY (not globally)."
echo "Your global ~/.kiro/ setup will NOT be touched."
echo ""

read -p "Project name: " PROJECT_NAME
read -p "GitHub username: " GITHUB_USER
read -p "Target directory (default: current dir): " TARGET_DIR
TARGET_DIR="${TARGET_DIR:-.}"

DATE=$(date +%Y-%m-%d)

echo ""
echo "📋 Project: $PROJECT_NAME"
echo "   Target:  $(cd "$TARGET_DIR" && pwd)"
echo ""
read -p "Proceed? (y/n): " CONFIRM
[ "$CONFIRM" != "y" ] && echo "Aborted." && exit 1

echo ""
echo "🔧 Copying template..."

# Copy .kiro/ and wiki/ into target project
mkdir -p "$TARGET_DIR/.kiro" "$TARGET_DIR/wiki"
cp -r .kiro/agents "$TARGET_DIR/.kiro/"
cp -r .kiro/prompts "$TARGET_DIR/.kiro/"
cp -r .kiro/evals "$TARGET_DIR/.kiro/"
cp -r .kiro/steering "$TARGET_DIR/.kiro/"
cp -r .kiro/docs "$TARGET_DIR/.kiro/"
cp -r .kiro/skills "$TARGET_DIR/.kiro/"
cp -r wiki/* "$TARGET_DIR/wiki/"

# Hooks and settings go global (they're shared infra)
if [ ! -d "$HOME/.kiro/hooks" ]; then
  mkdir -p "$HOME/.kiro/hooks" "$HOME/.kiro/settings"
  cp -r .kiro/hooks/* "$HOME/.kiro/hooks/"
  cp -r .kiro/settings/* "$HOME/.kiro/settings/"
  chmod +x "$HOME/.kiro/hooks/"*.sh
  echo "✅ Hooks & settings installed to ~/.kiro/ (first time only)"
fi

echo "🔧 Replacing placeholders..."

# Replace placeholders in target
find "$TARGET_DIR/.kiro" "$TARGET_DIR/wiki" -type f \( -name "*.md" -o -name "*.json" \) | while read -r file; do
  if sed --version >/dev/null 2>&1; then
    sed -i \
      -e "s|{{PROJECT_NAME}}|$PROJECT_NAME|g" \
      -e "s|{{GITHUB_USER}}|$GITHUB_USER|g" \
      -e "s|{{DATE}}|$DATE|g" \
      -e "s|{{HOME}}|$HOME|g" \
      "$file" 2>/dev/null || true
  else
    sed -i '' \
      -e "s|{{PROJECT_NAME}}|$PROJECT_NAME|g" \
      -e "s|{{GITHUB_USER}}|$GITHUB_USER|g" \
      -e "s|{{DATE}}|$DATE|g" \
      -e "s|{{HOME}}|$HOME|g" \
      "$file" 2>/dev/null || true
  fi
done

echo "✅ Done"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 Factory installed to: $(cd "$TARGET_DIR" && pwd)"
echo ""
echo "Usage:"
echo "  cd $(cd "$TARGET_DIR" && pwd)"
echo "  kiro-cli chat --agent kiro-factory"
echo ""
echo "Your global ~/.kiro/ is untouched."
echo "Local .kiro/agents/ takes priority when you cd into this project."
echo ""
