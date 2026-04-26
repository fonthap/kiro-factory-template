#!/bin/bash
# Kiro Factory — Cost Summary v3
# Model-aware pricing + latency tracking
# Usage: factory-cost.sh [YYYY-MM-DD | YYYY-MM | Nd | N]
#   (no arg)    → today
#   YYYY-MM-DD  → single day
#   YYYY-MM     → whole month
#   7d or 7     → last N days

LOG_DIR="$HOME/.kiro/logs/factory"
ARG="${1:-$(date +%Y-%m-%d)}"

# Resolve arg → LABEL + list of .jsonl files
if [[ "$ARG" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
  LABEL="$ARG"
  FILES=("$LOG_DIR/$ARG.jsonl")
elif [[ "$ARG" =~ ^[0-9]{4}-[0-9]{2}$ ]]; then
  LABEL="Month $ARG"
  FILES=("$LOG_DIR"/${ARG}-*.jsonl)
elif [[ "$ARG" =~ ^([0-9]+)d?$ ]]; then
  N="${BASH_REMATCH[1]}"
  LABEL="Last ${N} days"
  FILES=()
  for i in $(seq 0 $((N-1))); do
    D=$(date -v-${i}d +%Y-%m-%d 2>/dev/null || date -d "$i days ago" +%Y-%m-%d)
    FILES+=("$LOG_DIR/$D.jsonl")
  done
else
  echo "Usage: factory-cost.sh [YYYY-MM-DD | YYYY-MM | Nd]"
  exit 1
fi

# Filter to existing files
FOUND=()
for f in "${FILES[@]}"; do [ -f "$f" ] && FOUND+=("$f"); done

if [ ${#FOUND[@]} -eq 0 ]; then
  echo "No logs for $LABEL"
  exit 0
fi

# Fetch live USD→THB rate (fallback 35)
THB_RATE=$(curl -s --max-time 3 "https://open.er-api.com/v6/latest/USD" | grep -o '"THB":[0-9.]*' | cut -d: -f2)
THB_RATE="${THB_RATE:-35}"

echo "📊 Kiro Factory Cost Report — $LABEL (${#FOUND[@]} day(s))"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Per-model pricing table (USD per 1M tokens)
# model_in_rate / model_out_rate resolved in awk below

echo ""
echo "Per Agent (model-aware pricing):"
echo "────────────────────────────────"
awk -F'"' -v thb="$THB_RATE" '
function rate(model, type) {
  # USD per 1M tokens
  if (model ~ /opus/) return (type=="in") ? 15 : 75
  if (model ~ /sonnet/) return (type=="in") ? 3 : 15
  if (model ~ /haiku/) return (type=="in") ? 0.80 : 4
  return (type=="in") ? 3 : 15  # default sonnet
}
{
  agent="unknown"; model="unknown"; in_tok=0; out_tok=0
  for(i=1;i<=NF;i++){
    if($i=="agent") agent=$(i+2)
    if($i=="model") model=$(i+2)
    if($i=="input_tokens") { gsub(/[^0-9]/,"",$(i+1)); in_tok=$(i+1)+0 }
    if($i=="output_tokens") { gsub(/[^0-9]/,"",$(i+1)); out_tok=$(i+1)+0 }
  }
  if(agent=="none") agent="kiro-factory"
  if(in_tok>0 || out_tok>0){
    cost = (in_tok * rate(model,"in") + out_tok * rate(model,"out")) / 1000000
    agents[agent]++
    in_total[agent]+=in_tok; out_total[agent]+=out_tok
    cost_total[agent]+=cost; models[agent]=model
    grand_in+=in_tok; grand_out+=out_tok; grand_cost+=cost
  }
}
END {
  printf "  %-18s %-14s %7s %7s %8s %8s\n", "Agent", "Model", "In", "Out", "USD", "THB"
  printf "  %-18s %-14s %7s %7s %8s %8s\n", "─────", "─────", "───", "───", "───", "───"
  # Sort by cost descending: collect into indexed arrays
  n=0
  for(a in agents){ n++; sa[n]=a }
  for(i=1;i<=n;i++) for(j=i+1;j<=n;j++) if(cost_total[sa[i]]<cost_total[sa[j]]){ t=sa[i];sa[i]=sa[j];sa[j]=t }
  for(i=1;i<=n;i++){
    a=sa[i]; m=models[a]; sub(/claude-/,"",m)
    printf "  %-18s %-14s %7d %7d $%-7.3f ฿%.0f\n", a, m, in_total[a], out_total[a], cost_total[a], cost_total[a]*thb
  }
  printf "  %-18s %-14s %7s %7s %8s %8s\n", "─────", "", "───", "───", "───", "───"
  printf "  %-18s %-14s %7d %7d $%-7.3f ฿%.0f\n", "TOTAL", "", grand_in, grand_out, grand_cost, grand_cost*thb
  printf "\n  Rate: 1 USD = %.2f THB\n", thb
}' "${FOUND[@]}"

# Latency (pre-tool → subagent-done per stage)
echo ""
echo "Latency:"
echo "────────"
awk -F'"' '
{
  evt=""; stage=""; ms=0
  for(i=1;i<=NF;i++){
    if($i=="event") evt=$(i+2)
    if($i=="stage") stage=$(i+2)
    if($i=="epoch_ms") { gsub(/[^0-9]/,"",$(i+1)); ms=$(i+1)+0 }
  }
  if(stage!="none" && ms>0){
    if(evt=="pre-tool") start[stage]=ms
    if(evt=="subagent-done" && start[stage]>0){
      dur=(ms - start[stage])/1000
      printf "  %-28s %6.1fs\n", stage, dur
      total+=dur; n++
    }
  }
}
END { if(n>0) printf "  %-28s %6.1fs avg\n", "─── overall", total/n }
' "${FOUND[@]}"

# Event counts
echo ""
echo "Events:"
echo "───────"
grep -ohE '"event":"[^"]*"' "${FOUND[@]}" | sort | uniq -c | sort -rn | while read count event; do
  event=$(echo "$event" | sed 's/"event":"//;s/"//')
  printf "  %-20s %d\n" "$event" "$count"
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
