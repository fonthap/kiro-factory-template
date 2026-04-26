#!/bin/bash
# Kiro Factory Template — Setup Script
set -e

echo "🏭 Kiro Factory Template Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

read -p "Project name: " PROJECT_NAME
read -p "GitHub username (for template URLs): " GITHUB_USER

DATE=$(date +%Y-%m-%d)

echo ""
echo "📋 Project: $PROJECT_NAME"
echo "   GitHub:  $GITHUB_USER"
echo ""
read -p "Proceed? (y/n): " CONFIRM
[ "$CONFIRM" != "y" ] && echo "Aborted." && exit 1

echo ""
echo "🔧 Replacing placeholders..."

find . -type f \( -name "*.md" -o -name "*.json" \) | while read -r file; do
  sed -i '' \
    -e "s|{{PROJECT_NAME}}|$PROJECT_NAME|g" \
    -e "s|{{GITHUB_USER}}|$GITHUB_USER|g" \
    -e "s|{{DATE}}|$DATE|g" \
    -e "s|{{HOME}}|$HOME|g" \
    "$file" 2>/dev/null || true
done

echo "✅ Placeholders replaced"

if [ -d "$HOME/.kiro/agents" ]; then
  echo ""
  echo "⚠️  ~/.kiro/ already exists."
  read -p "Overwrite agent configs? (y/n): " OVERWRITE
  if [ "$OVERWRITE" = "y" ]; then
    cp -r .kiro/agents/ "$HOME/.kiro/agents/"
    cp -r .kiro/prompts/ "$HOME/.kiro/prompts/"
    cp -r .kiro/evals/ "$HOME/.kiro/evals/"
    cp -r .kiro/steering/ "$HOME/.kiro/steering/"
    cp -r .kiro/settings/ "$HOME/.kiro/settings/"
    mkdir -p "$HOME/.kiro/docs" && cp -r .kiro/docs/ "$HOME/.kiro/docs/"
    for hook in .kiro/hooks/*.sh; do
      cp "$hook" "$HOME/.kiro/hooks/$(basename "$hook")"
      chmod +x "$HOME/.kiro/hooks/$(basename "$hook")"
    done
    echo "✅ ~/.kiro/ updated"
  fi
else
  mkdir -p "$HOME/.kiro"
  cp -r .kiro/* "$HOME/.kiro/"
  chmod +x "$HOME/.kiro/hooks/"*.sh
  echo "✅ Installed to ~/.kiro/"
fi

if [ -d "$HOME/wiki/wiki" ]; then
  echo ""
  echo "⚠️  ~/wiki/ already exists."
  read -p "Overwrite wiki? (y/n): " OVERWRITE_WIKI
  if [ "$OVERWRITE_WIKI" = "y" ]; then
    cp -r wiki/* "$HOME/wiki/"
    echo "✅ ~/wiki/ updated"
  fi
else
  mkdir -p "$HOME/wiki"
  cp -r wiki/* "$HOME/wiki/"
  echo "✅ Installed to ~/wiki/"
fi

echo ""
echo "🌐 Installing Playwright..."
npx playwright install chromium 2>/dev/null && echo "✅ Playwright installed" || echo "⚠️  Run 'npx playwright install chromium' manually"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 Done!"
echo ""
echo "Next steps:"
echo "  1. Edit ~/wiki/wiki/project.md — add your tech stack and conventions"
echo "  2. Run: kiro-cli chat"
echo "  3. Try: \"build a login page with email/password\""
echo ""
