#!/bin/bash
# Kiro Factory Template — Setup Script
# Replaces {{PLACEHOLDERS}} and installs to ~/.kiro/ and ~/wiki/
set -e

echo "🏭 Kiro Factory Template Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Collect user info
read -p "Your name (nickname): " USER_NAME
read -p "Your full name: " USER_FULL_NAME
read -p "Email: " EMAIL
read -p "Location (e.g. Bangkok, Thailand): " LOCATION
read -p "Current position (e.g. Site Reliability Engineer): " CURRENT_POSITION
read -p "Company: " COMPANY
read -p "Start date (e.g. Mar 2026): " START_DATE
read -p "Focus area (e.g. SRE / Platform Engineering): " FOCUS_AREA
read -p "Target role (e.g. Senior SRE): " TARGET_ROLE
read -p "University: " UNIVERSITY
read -p "Degree (e.g. BE, Computer Engineering): " DEGREE
read -p "Graduation year: " GRAD_YEAR
read -p "Salary range (e.g. 40,000-60,000): " SALARY_RANGE
read -p "LinkedIn URL: " LINKEDIN_URL
read -p "GitHub URL: " GITHUB_URL

DATE=$(date +%Y-%m-%d)
HOME_PATH="$HOME"

echo ""
echo "📋 Summary:"
echo "  Name: $USER_NAME ($USER_FULL_NAME)"
echo "  Role: $CURRENT_POSITION @ $COMPANY"
echo "  Target: $TARGET_ROLE"
echo ""
read -p "Proceed? (y/n): " CONFIRM
[ "$CONFIRM" != "y" ] && echo "Aborted." && exit 1

echo ""
echo "🔧 Replacing placeholders..."

# Replace in all text files
find . -type f \( -name "*.md" -o -name "*.json" \) | while read -r file; do
  sed -i '' \
    -e "s|{{USER_NAME}}|$USER_NAME|g" \
    -e "s|{{USER_FULL_NAME}}|$USER_FULL_NAME|g" \
    -e "s|{{EMAIL}}|$EMAIL|g" \
    -e "s|{{LOCATION}}|$LOCATION|g" \
    -e "s|{{CURRENT_POSITION}}|$CURRENT_POSITION|g" \
    -e "s|{{COMPANY}}|$COMPANY|g" \
    -e "s|{{START_DATE}}|$START_DATE|g" \
    -e "s|{{FOCUS_AREA}}|$FOCUS_AREA|g" \
    -e "s|{{TARGET_ROLE}}|$TARGET_ROLE|g" \
    -e "s|{{USER_ROLE}}|$CURRENT_POSITION|g" \
    -e "s|{{UNIVERSITY}}|$UNIVERSITY|g" \
    -e "s|{{DEGREE}}|$DEGREE|g" \
    -e "s|{{GRAD_YEAR}}|$GRAD_YEAR|g" \
    -e "s|{{SALARY_RANGE}}|$SALARY_RANGE|g" \
    -e "s|{{LINKEDIN_URL}}|$LINKEDIN_URL|g" \
    -e "s|{{GITHUB_URL}}|$GITHUB_URL|g" \
    -e "s|{{DATE}}|$DATE|g" \
    -e "s|{{HOME}}|$HOME_PATH|g" \
    "$file" 2>/dev/null || true
done

echo "✅ Placeholders replaced"

# Check for existing installations
if [ -d "$HOME/.kiro/agents" ]; then
  echo ""
  echo "⚠️  ~/.kiro/ already exists."
  read -p "Overwrite agent configs? (y/n): " OVERWRITE_KIRO
  if [ "$OVERWRITE_KIRO" = "y" ]; then
    cp -r .kiro/agents/ "$HOME/.kiro/agents/"
    cp -r .kiro/prompts/ "$HOME/.kiro/prompts/"
    cp -r .kiro/evals/ "$HOME/.kiro/evals/"
    cp -r .kiro/steering/ "$HOME/.kiro/steering/"
    cp -r .kiro/settings/ "$HOME/.kiro/settings/"
    cp -r .kiro/docs/ "$HOME/.kiro/docs/"
    # Only copy hooks if they don't exist
    for hook in .kiro/hooks/*.sh; do
      dest="$HOME/.kiro/hooks/$(basename "$hook")"
      [ ! -f "$dest" ] && cp "$hook" "$dest" && chmod +x "$dest"
    done
    echo "✅ ~/.kiro/ updated"
  else
    echo "⏭️  Skipped ~/.kiro/"
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
  else
    echo "⏭️  Skipped ~/wiki/"
  fi
else
  mkdir -p "$HOME/wiki"
  cp -r wiki/* "$HOME/wiki/"
  echo "✅ Installed to ~/wiki/"
fi

# Install Playwright
echo ""
echo "🌐 Installing Playwright (for web browsing agent)..."
npx playwright install chromium 2>/dev/null && echo "✅ Playwright installed" || echo "⚠️  Playwright install failed — run 'npx playwright install chromium' manually"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Review ~/wiki/wiki/me.md and add your details"
echo "  2. Run: kiro-cli chat"
echo "  3. Try: \"research the top 3 monitoring tools for Kubernetes\""
echo ""
