#!/usr/bin/env bash
# Run the full Research & Strategy pipeline — all 6 specialist agents in sequence.
# This script acts as the supervisor: activating each agent in dependency order,
# writing a timestamped run log, and printing progress to the console.
#
# Usage:
#   ./run_industry_report.sh <industry> [options]
#
# Arguments:
#   industry            Industry or market to research (required)
#                       Example: "restaurant technology"
#
# Options:
#   -c, --company       Name of the commissioning company
#                       Default: "Not provided"
#   -x, --context       Description of the company's business, products, and goals
#                       Default: "Not provided"
#   -r, --competitors   Seed competitors to always include (comma-separated, optional)
#                       Stage 1 will discover additional key competitors automatically.
#                       Example: "Toast,Square" — these plus discovered ones are all profiled
#   -n, --max-competitors  Maximum number of competitors to research (default: 5)
#                       Seeds are prioritized; discovered companies fill remaining slots.
#   -d, --depth         Research depth: "quick" or "deep" (default: quick)
#                         quick = top-line outputs, 10 turns per agent
#                         deep  = full standard outputs, 15 turns per agent
#   -f, --focus         Specific focus areas to emphasize across all agents
#   -s, --start-from    Resume from stage N (1–6). Skips all earlier stages.
#                         1 = Industry Market Researcher
#                         2 = Competitor Researcher  (runs all competitors in parallel)
#                         3 = Competitive Analyst
#                         4 = GTM Analyst
#                         5 = Innovation Guru
#                         6 = Consultant  (final synthesis)
#   -m, --model         Claude model to use (default: claude-haiku-4-5-20251001)
#                       Examples: claude-sonnet-4-6, claude-opus-4-7
#   -h, --help          Show this help message
#
# Turn limits by depth:
#   quick → 10 turns per agent, 15 for Consultant
#   deep  → 15 turns per agent, 25 for Consultant
#
# If an agent hits the turn limit but wrote partial output, the pipeline continues
# with a warning rather than halting. Only a stage that writes nothing halts the run.
#
# Pipeline stages and outputs:
#   Stage 1 → research-strategy/outputs/industry/     (market sizing, trends, dynamics)
#   Stage 2 → research-strategy/outputs/competitors/  (profiles, summary table, gaps)
#   Stage 3 → research-strategy/outputs/analysis/     (SWOT, positioning, key insights)
#   Stage 4 → research-strategy/outputs/gtm/          (ICP, messaging, GTM strategy)
#   Stage 5 → research-strategy/outputs/innovation/   (opportunities, disruption scenarios)
#   Stage 6 → research-strategy/outputs/synthesis/    (executive summary, action plan)
#
# Run log written to: runs/YYYY-MM-DD_<industry>/run_log.md
#
# Examples:
#   # Fast test run — Haiku, 3 competitors, quick depth:
#   ./run_industry_report.sh "restaurant technology" \
#     --company "VIP" \
#     --context "We sell POS and restaurant management software to restaurants." \
#     --competitors "Toast,Square" \
#     --max-competitors 3 \
#     --depth quick
#
#   # Full production run — Sonnet, 5 competitors, deep depth:
#   ./run_industry_report.sh "restaurant technology" \
#     --company "VIP" \
#     --context "We sell POS and restaurant management software to restaurants." \
#     --competitors "Toast,Square,SpotOn" \
#     --depth deep \
#     --model claude-sonnet-4-6
#
#   # Resume a partial run from Stage 4 (GTM Analyst):
#   ./run_industry_report.sh "restaurant technology" \
#     --company "VIP" --context "..." --start-from 4

set -uo pipefail

# ── Defaults ──────────────────────────────────────────────────────────────────
DEPTH="quick"
COMPANY="Not provided"
CONTEXT="Not provided — agents will research without client framing."
COMPETITORS=""
MAX_COMPETITORS=5
FOCUS=""
START_FROM=1
MODEL="claude-haiku-4-5-20251001"

# ── Argument parsing ──────────────────────────────────────────────────────────
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  awk 'NR>1 && /^[^#]/{exit} NR>1{sub(/^# ?/, ""); print}' "$0"
  exit 0
fi

if [[ $# -eq 0 ]]; then
  echo "Error: industry is required."
  echo "Usage: ./run_industry_report.sh <industry> [options]"
  echo "Run with --help for full usage."
  exit 1
fi

INDUSTRY="$1"
shift

while [[ $# -gt 0 ]]; do
  case "$1" in
    -c|--company)         COMPANY="$2";         shift 2 ;;
    -x|--context)         CONTEXT="$2";         shift 2 ;;
    -r|--competitors)     COMPETITORS="$2";     shift 2 ;;
    -n|--max-competitors) MAX_COMPETITORS="$2"; shift 2 ;;
    -d|--depth)           DEPTH="$2";           shift 2 ;;
    -f|--focus)           FOCUS="$2";           shift 2 ;;
    -s|--start-from)      START_FROM="$2";      shift 2 ;;
    -m|--model)           MODEL="$2";           shift 2 ;;
    -h|--help)
      awk 'NR>1 && /^[^#]/{exit} NR>1{sub(/^# ?/, ""); print}' "$0"
      exit 0
      ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# ── Validate ──────────────────────────────────────────────────────────────────
if [[ "$DEPTH" != "quick" && "$DEPTH" != "deep" ]]; then
  echo "Error: --depth must be 'quick' or 'deep'."
  exit 1
fi

if ! [[ "$START_FROM" =~ ^[1-6]$ ]]; then
  echo "Error: --start-from must be a number from 1 to 6."
  exit 1
fi

if ! [[ "$MAX_COMPETITORS" =~ ^[0-9]+$ ]] || [[ "$MAX_COMPETITORS" -lt 1 ]]; then
  echo "Error: --max-competitors must be a positive integer."
  exit 1
fi

# ── Paths ─────────────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RS_DIR="$SCRIPT_DIR/research-strategy"
OUT_DIR="$RS_DIR/outputs"

INDUSTRY_SLUG="$(echo "$INDUSTRY" | tr '[:upper:]' '[:lower:]' | tr ' ' '_' | tr -cd '[:alnum:]_')"
RUN_DATE="$(date '+%Y-%m-%d')"
RUN_DIR="$SCRIPT_DIR/runs/${RUN_DATE}_${INDUSTRY_SLUG}"
RUN_LOG="$RUN_DIR/run_log.md"

AGENT_02="$RS_DIR/02_industry_market_researcher.md"
AGENT_03="$RS_DIR/03_competitor_researcher.md"
AGENT_04="$RS_DIR/04_competitive_analyst.md"
AGENT_05="$RS_DIR/05_gtm_analyst.md"
AGENT_06="$RS_DIR/06_innovation_guru.md"
AGENT_07="$RS_DIR/07_consultant.md"

if [[ "$DEPTH" == "quick" ]]; then
  MAX_TURNS=15
  STAGE1_TURNS=25
  CONSULTANT_TURNS=20
else
  MAX_TURNS=20
  STAGE1_TURNS=35
  CONSULTANT_TURNS=30
fi

INTER_STAGE_SLEEP=45  # seconds to pause between stages to avoid rate limits

# ── Focus line helper ─────────────────────────────────────────────────────────
if [[ -n "$FOCUS" ]]; then
  FOCUS_LINE="Focus areas: $FOCUS"
else
  FOCUS_LINE="Focus areas: None specified — cover all standard sections equally."
fi

# ── Pre-flight checks ─────────────────────────────────────────────────────────
echo ""
echo "Checking prerequisites..."

if ! command -v claude &>/dev/null; then
  echo "Error: 'claude' CLI not found. Install with: npm install -g @anthropic-ai/claude-code"
  exit 1
fi

if [[ -z "${ANTHROPIC_API_KEY:-}" ]]; then
  echo "Error: ANTHROPIC_API_KEY environment variable is not set."
  exit 1
fi

for f in "$AGENT_02" "$AGENT_03" "$AGENT_04" "$AGENT_05" "$AGENT_06" "$AGENT_07"; do
  if [[ ! -f "$f" ]]; then
    echo "Error: Agent spec not found: $f"
    exit 1
  fi
done

# ── Archive any existing outputs, then wipe for a clean run ──────────────────
# Skipped when resuming mid-pipeline (--start-from > 1) since existing outputs
# are intentional inputs for the remaining stages.
if [[ "$START_FROM" -eq 1 ]]; then
  ARCHIVE_DIR="$SCRIPT_DIR/runs/${RUN_DATE}_${INDUSTRY_SLUG}_pre-run-archive"

  # Only archive if there are existing files to save
  EXISTING_FILES="$(find "$OUT_DIR" -type f 2>/dev/null | wc -l | tr -d ' ')"
  if [[ "$EXISTING_FILES" -gt 0 ]]; then
    echo ""
    echo "Archiving $EXISTING_FILES existing output files before wiping..."
    mkdir -p "$ARCHIVE_DIR"
    cp -r "$OUT_DIR"/. "$ARCHIVE_DIR/"
    echo "  Archived to: $ARCHIVE_DIR"
  fi

  # Wipe and recreate output directories
  rm -rf "$OUT_DIR"
fi

mkdir -p \
  "$OUT_DIR/industry" \
  "$OUT_DIR/competitors" \
  "$OUT_DIR/analysis" \
  "$OUT_DIR/gtm" \
  "$OUT_DIR/innovation" \
  "$OUT_DIR/synthesis" \
  "$RUN_DIR"

# ── Run log: initialize ───────────────────────────────────────────────────────
RUN_START="$(date '+%Y-%m-%d %H:%M:%S')"

cat > "$RUN_LOG" <<EOF
# Run Log: $INDUSTRY

**Date:** $RUN_DATE
**Started:** $RUN_START
**Company:** $COMPANY
**Model:** $MODEL
**Depth:** $DEPTH  (max turns: $MAX_TURNS, consultant: $CONSULTANT_TURNS)
**Max competitors:** $MAX_COMPETITORS
**Seed competitors:** ${COMPETITORS:-none}
**Focus:** ${FOCUS:-none}
**Start from stage:** $START_FROM

---

## Stage Results

EOF

# ── Helpers ───────────────────────────────────────────────────────────────────
sep() { echo "=========================================="; }
hdr() { echo ""; sep; echo " $1"; sep; }

log_result() {
  local stage="$1" name="$2" status="$3" t_start="$4" t_end="$5"
  cat >> "$RUN_LOG" <<EOF
### Stage $stage: $name
- Status: **$status**
- Started: $t_start
- Ended: $t_end

EOF
}

# ── Pipeline state ────────────────────────────────────────────────────────────
PIPELINE_FAILED=0   # set when a stage writes nothing — halts the pipeline
PIPELINE_WARNED=0   # set when a stage hit turn limit but wrote partial output — pipeline continues

# ── Stage runner ──────────────────────────────────────────────────────────────
# Args:
#   $1  stage_num
#   $2  stage_name
#   $3  agent_file
#   $4  task prompt
#   $5  max turns (optional, defaults to MAX_TURNS)
#   $6  primary output file to check on failure (optional)
#       If set and the file exists after a failed run, treats as partial rather than failed.
run_stage() {
  local stage_num="$1"
  local stage_name="$2"
  local agent_file="$3"
  local task="$4"
  local turns="${5:-$MAX_TURNS}"
  local primary_output="${6:-}"

  if [[ "$stage_num" -lt "$START_FROM" ]]; then
    echo "  [skip] Stage $stage_num — $stage_name"
    return 0
  fi

  hdr "Stage $stage_num of 6: $stage_name"
  echo ""

  local t_start t_end
  t_start="$(date '+%Y-%m-%d %H:%M:%S')"

  if claude -p "$task" \
       --system-prompt-file "$agent_file" \
       --model "$MODEL" \
       --allowedTools "Read,Write,WebSearch,Bash" \
       --max-turns "$turns" \
       --dangerously-skip-permissions; then

    t_end="$(date '+%Y-%m-%d %H:%M:%S')"
    log_result "$stage_num" "$stage_name" "SUCCESS" "$t_start" "$t_end"
    echo ""
    echo "  Stage $stage_num complete: $stage_name"

  else
    local exit_code=$?
    t_end="$(date '+%Y-%m-%d %H:%M:%S')"

    if [[ -n "$primary_output" && -f "$primary_output" ]]; then
      # Partial output written (likely hit turn limit) — warn and continue
      log_result "$stage_num" "$stage_name" \
        "PARTIAL — hit turn limit, output may be incomplete" "$t_start" "$t_end"
      echo ""
      echo "  Warning: Stage $stage_num hit the turn limit but wrote partial output."
      echo "  Continuing with available data. Review: $primary_output"
      PIPELINE_WARNED=1
    else
      # Nothing written — real failure, halt
      log_result "$stage_num" "$stage_name" \
        "FAILED — no output written (exit $exit_code)" "$t_start" "$t_end"
      echo ""
      echo "  Error: Stage $stage_num failed — no output was written."
      echo "  To resume from here:"
      echo "    $0 \"$INDUSTRY\" \\"
      echo "      --company \"$COMPANY\" \\"
      echo "      --context \"$CONTEXT\" \\"
      if [[ -n "$COMPETITORS" ]]; then
        echo "      --competitors \"$COMPETITORS\" \\"
      fi
      echo "      --model $MODEL --depth $DEPTH --start-from $stage_num"
      PIPELINE_FAILED=1
    fi
  fi
}

halt_if_failed() {
  if [[ "$PIPELINE_FAILED" -eq 1 ]]; then
    echo ""
    echo "Pipeline halted — a stage wrote no output. Fix the issue and re-run with --start-from."
    exit 1
  fi
  echo ""
  echo "  Pausing ${INTER_STAGE_SLEEP}s before next stage to avoid rate limits..."
  sleep "$INTER_STAGE_SLEEP"
}

halt_if_failed_no_sleep() {
  if [[ "$PIPELINE_FAILED" -eq 1 ]]; then
    echo ""
    echo "Pipeline halted — a stage wrote no output. Fix the issue and re-run with --start-from."
    exit 1
  fi
}

# ── Opening banner ────────────────────────────────────────────────────────────
hdr "Research & Strategy — Full Pipeline Run"
echo " Industry:         $INDUSTRY"
echo " Company:          $COMPANY"
echo " Model:            $MODEL"
echo " Depth:            $DEPTH  (Stage 1: ${STAGE1_TURNS}, agents: ${MAX_TURNS}, Consultant: ${CONSULTANT_TURNS} turns)"
echo " Max competitors:  $MAX_COMPETITORS"
echo " Seed competitors: ${COMPETITORS:-none}"
if [[ -n "$FOCUS" ]]; then
  echo " Focus:            $FOCUS"
fi
if [[ "$START_FROM" -gt 1 ]]; then
  echo " Resuming:         Stage $START_FROM"
fi
echo " Run log:          $RUN_LOG"
sep


# ═══════════════════════════════════════════════════════════════════════════════
# STAGE 1 — Industry Market Researcher
# ═══════════════════════════════════════════════════════════════════════════════

run_stage 1 "Industry Market Researcher" "$AGENT_02" \
"Conduct a full market research report on the ${INDUSTRY} industry.

Commissioning company: ${COMPANY}
Company context: ${CONTEXT}
Research depth: ${DEPTH}
${FOCUS_LINE}

TURN BUDGET: You have approximately ${STAGE1_TURNS} turns. Manage them as follows:
- Turn 1: Write skeleton output files immediately (market_research_report.md,
  market_data_table.csv, research_confidence_notes.md) with section headers and
  one-line placeholders. Do NOT write key_competitors.txt yet — it must contain
  real names, not placeholders.
- Turns 2 through $((STAGE1_TURNS - 3)): Research and fill in each section with real content.
- Final 3 turns: Save your finalized report files. A thinner but complete report
  is better than a detailed but incomplete one. Do not start new research in your
  final 3 turns. You can write multiple files in a single turn by making multiple
  Write tool calls in one response — do this to use your writing turns efficiently.

Write your outputs to:
- ${OUT_DIR}/industry/market_research_report.md
- ${OUT_DIR}/industry/market_data_table.csv
- ${OUT_DIR}/industry/research_confidence_notes.md

Make sure your market research report includes a clearly labelled section listing
the major market players and competitors you identified — this will be used in a
subsequent step to populate the competitor research stage.

Follow your standard workflow exactly as specified in your agent instructions." \
"$STAGE1_TURNS" \
"${OUT_DIR}/industry/market_research_report.md"

halt_if_failed_no_sleep


# ═══════════════════════════════════════════════════════════════════════════════
# STAGE 1.5 — Competitor Extraction  (reads market research report, writes key_competitors.txt)
# Decoupled from Stage 1 so turn exhaustion there never blocks competitor discovery.
# ═══════════════════════════════════════════════════════════════════════════════

if [[ "$START_FROM" -le 1 ]]; then
  hdr "Stage 1.5: Competitor Extraction"
  echo ""

  MARKET_REPORT="${OUT_DIR}/industry/market_research_report.md"
  COMPETITORS_FILE="${OUT_DIR}/industry/key_competitors.txt"

  if [[ ! -f "$MARKET_REPORT" ]]; then
    echo "  Warning: market_research_report.md not found — skipping extraction."
    echo "  Stage 2 will use --competitors seeds only."
  else
    t_start_ext="$(date '+%Y-%m-%d %H:%M:%S')"

    if claude -p \
"Read the market research report at ${MARKET_REPORT} and identify the most
relevant competitors in the ${INDUSTRY} industry.

Selection criteria — include ONLY companies where:
1. ${INDUSTRY} is their PRIMARY line of business (or one of very few core lines)
2. The majority of their revenue comes from this industry
3. They are meaningfully sized within the focused market segment

Explicitly EXCLUDE:
- Large generalist companies or conglomerates that offer ${INDUSTRY} products as a minor or incidental part of a much larger business
- Companies where ${INDUSTRY} represents a small fraction of their overall revenue

The goal is a list of the most significant focused, specialist competitors —
the companies that a dedicated ${INDUSTRY} business would consider its direct peers.
Rank them by size/market share within the focused segment, largest first.

Write the top 6–10 names to ${COMPETITORS_FILE}.
Format: one company name per line, no bullets, no numbers, no punctuation — plain names only.
Example:
  BriteCo
  Jewelers Mutual
  Lavalier

Do not include the commissioning company (${COMPANY}) in the list.
Do not add commentary or explanations — the file must contain only company names." \
      --model "$MODEL" \
      --allowedTools "Read,Write" \
      --max-turns 5 \
      --dangerously-skip-permissions; then

      t_end_ext="$(date '+%Y-%m-%d %H:%M:%S')"
      log_result "1.5" "Competitor Extraction" "SUCCESS" "$t_start_ext" "$t_end_ext"
    else
      t_end_ext="$(date '+%Y-%m-%d %H:%M:%S')"
      log_result "1.5" "Competitor Extraction" "PARTIAL/FAILED" "$t_start_ext" "$t_end_ext"
      echo "  Warning: extraction hit turn limit — cleaning whatever was written."
    fi

    # ── Clean key_competitors.txt regardless of exit code ─────────────────────
    # Removes lines that are clearly not plain company names:
    # numbered items, lines with parentheses/colons/commas, headers, long lines.
    if [[ -f "$COMPETITORS_FILE" ]]; then
      CLEANED="$(
        grep -v '^\s*$' "$COMPETITORS_FILE" |        # drop empty lines
        grep -v '^\s*[0-9]' |                        # drop numbered items (1. 2.)
        grep -v '[():]' |                            # drop lines with parens or colons
        grep -v ',' |                                # drop lines with commas
        awk 'NF >= 1 && NF <= 5' |                   # keep only 1–5 word lines
        awk '{ gsub(/^[[:space:]]+|[[:space:]]+$/, ""); print }' |  # trim whitespace
        head -10
      )"
      if [[ -n "$CLEANED" ]]; then
        echo "$CLEANED" > "$COMPETITORS_FILE"
        COMP_COUNT="$(echo "$CLEANED" | wc -l | tr -d ' ')"
        echo "  Extracted $COMP_COUNT competitors → $COMPETITORS_FILE"
        echo "$CLEANED" | sed 's/^/    /'
      else
        echo "  Warning: no clean company names found — Stage 2 will use --competitors seeds only."
        rm -f "$COMPETITORS_FILE"
      fi
    else
      echo "  Warning: key_competitors.txt not written — Stage 2 will use --competitors seeds only."
    fi
  fi

  echo ""
  echo "  Pausing ${INTER_STAGE_SLEEP}s before Stage 2..."
  sleep "$INTER_STAGE_SLEEP"
fi


# ═══════════════════════════════════════════════════════════════════════════════
# STAGE 2 — Competitor Researcher  (all competitors run in parallel)
# Each agent gets its own log file; a summary is printed when all jobs finish.
# ═══════════════════════════════════════════════════════════════════════════════

if [[ "$START_FROM" -gt 2 ]]; then
  echo ""
  echo "  [skip] Stage 2 — Competitor Researcher"
  log_result 2 "Competitor Researcher" "SKIPPED (start-from $START_FROM)" "—" "—"

else
  # ── Build merged competitor list: seed --competitors + Stage 1 discoveries ──
  declare -A SEEN_COMPS
  COMPETITOR_LIST=()

  # Seeds first — they're guaranteed slots
  if [[ -n "$COMPETITORS" ]]; then
    IFS=',' read -ra SEED_LIST <<< "$COMPETITORS"
    for SEED_RAW in "${SEED_LIST[@]}"; do
      SEED="$(echo "$SEED_RAW" | tr -d '[:space:]')"
      SEED_KEY="$(echo "$SEED" | tr '[:upper:]' '[:lower:]' | tr -cd '[:alnum:]')"
      if [[ -n "$SEED" && -z "${SEEN_COMPS[$SEED_KEY]:-}" ]]; then
        COMPETITOR_LIST+=("$SEED")
        SEEN_COMPS["$SEED_KEY"]=1
      fi
    done
  fi

  # Fill remaining slots with Stage 1 discoveries
  DISCOVERED_FILE="${OUT_DIR}/industry/key_competitors.txt"
  if [[ -f "$DISCOVERED_FILE" ]]; then
    DISC_COUNT="$(wc -l < "$DISCOVERED_FILE" | tr -d ' ')"
    while IFS= read -r LINE || [[ -n "$LINE" ]]; do
      if [[ "${#COMPETITOR_LIST[@]}" -ge "$MAX_COMPETITORS" ]]; then break; fi
      DISC="$(echo "$LINE" | sed 's/^[[:space:]]*[-*•]*//' | tr -d '[:space:]')"
      DISC_KEY="$(echo "$DISC" | tr '[:upper:]' '[:lower:]' | tr -cd '[:alnum:]')"
      if [[ -n "$DISC" && -z "${SEEN_COMPS[$DISC_KEY]:-}" ]]; then
        COMPETITOR_LIST+=("$DISC")
        SEEN_COMPS["$DISC_KEY"]=1
      fi
    done < "$DISCOVERED_FILE"
    echo "  Stage 1 discovered $DISC_COUNT competitors; merged with seeds."
  else
    echo "  Note: key_competitors.txt not found — using --competitors seeds only."
  fi

  unset SEEN_COMPS

  # Apply cap (seeds may already exceed it)
  if [[ "${#COMPETITOR_LIST[@]}" -gt "$MAX_COMPETITORS" ]]; then
    echo "  Capping to $MAX_COMPETITORS competitors."
    COMPETITOR_LIST=("${COMPETITOR_LIST[@]:0:$MAX_COMPETITORS}")
  fi

  if [[ "${#COMPETITOR_LIST[@]}" -eq 0 ]]; then
    echo ""
    echo "  [skip] Stage 2 — no competitors found (pass --competitors or check Stage 1 output)"
    log_result 2 "Competitor Researcher" "SKIPPED (no competitors found)" "—" "—"
    unset COMPETITOR_LIST
  else

  COMP_TOTAL="${#COMPETITOR_LIST[@]}"

  hdr "Stage 2 of 6: Competitor Researcher  ($COMP_TOTAL in parallel)"
  echo "  Competitors: ${COMPETITOR_LIST[*]}"
  echo "  Logs: $RUN_DIR/stage2_<competitor>.log"
  echo ""

  STAGE2_START="$(date '+%Y-%m-%d %H:%M:%S')"

  # ── Launch all competitor jobs in the background ───────────────────────────
  declare -A COMP_PIDS    # slug → PID
  declare -A COMP_NAMES   # slug → display name
  declare -A COMP_LOGS    # slug → log file path

  for COMP_RAW in "${COMPETITOR_LIST[@]}"; do
    COMP="$(echo "$COMP_RAW" | tr -d '[:space:]')"
    COMP_SLUG="$(echo "$COMP" | tr '[:upper:]' '[:lower:]' | tr ' ' '_' | tr -cd '[:alnum:]_')"
    COMP_LOG="$RUN_DIR/stage2_${COMP_SLUG}.log"

    COMP_NAMES["$COMP_SLUG"]="$COMP"
    COMP_LOGS["$COMP_SLUG"]="$COMP_LOG"

    claude -p \
"Research ${COMP} as a competitor in the ${INDUSTRY} market.

Commissioning company: ${COMPANY}
Company context: ${CONTEXT}
Research depth: ${DEPTH}
${FOCUS_LINE}

TURN BUDGET: You have approximately ${MAX_TURNS} turns. Manage them as follows:
- Turn 1: Write a skeleton profile immediately — section headers and one-line placeholders only. This ensures a file exists even if turns run out.
- Turns 2 through $((MAX_TURNS - 2)): Research and fill in each section with real content.
- Final 2 turns: Save your finalized output files. A thinner but complete profile is better than a detailed but incomplete one. Do not start new research in your final 2 turns.
  You can write multiple files in a single turn by making multiple Write tool calls in one response — do this to use your writing turns efficiently.

Write your outputs to:
- ${OUT_DIR}/competitors/${COMP_SLUG}_profile.md
- ${OUT_DIR}/competitors/competitor_summary_table.csv  (add this competitor; create or update)
- ${OUT_DIR}/competitors/research_gaps.md              (add this competitor; create or update)

Follow your standard workflow exactly as specified in your agent instructions." \
      --system-prompt-file "$AGENT_03" \
      --model "$MODEL" \
      --allowedTools "Read,Write,WebSearch,Bash" \
      --max-turns "$MAX_TURNS" \
      --dangerously-skip-permissions \
      > "$COMP_LOG" 2>&1 &

    COMP_PIDS["$COMP_SLUG"]=$!
    echo "  Launched: $COMP  (PID ${COMP_PIDS[$COMP_SLUG]})"
  done

  echo ""
  echo "  Waiting for all $COMP_TOTAL jobs to finish..."

  # ── Wait and collect results ───────────────────────────────────────────────
  STAGE2_ANY_FAILED=0

  for COMP_SLUG in "${!COMP_PIDS[@]}"; do
    COMP="${COMP_NAMES[$COMP_SLUG]}"
    COMP_LOG="${COMP_LOGS[$COMP_SLUG]}"
    COMP_PROFILE="${OUT_DIR}/competitors/${COMP_SLUG}_profile.md"

    if wait "${COMP_PIDS[$COMP_SLUG]}"; then
      log_result "2" "Competitor Researcher — $COMP" \
        "SUCCESS" "$STAGE2_START" "$(date '+%Y-%m-%d %H:%M:%S')"
      echo "  OK:      $COMP"
    elif [[ -f "$COMP_PROFILE" ]]; then
      # Hit turn limit but wrote a partial profile — warn and continue
      log_result "2" "Competitor Researcher — $COMP" \
        "PARTIAL — hit turn limit, profile may be incomplete" "$STAGE2_START" "$(date '+%Y-%m-%d %H:%M:%S')"
      echo "  PARTIAL: $COMP  (incomplete profile written — continuing)"
      PIPELINE_WARNED=1
    else
      # No output at all — real failure
      log_result "2" "Competitor Researcher — $COMP" \
        "FAILED — no output written  (see $COMP_LOG)" "$STAGE2_START" "$(date '+%Y-%m-%d %H:%M:%S')"
      echo "  FAIL:    $COMP  → $COMP_LOG"
      STAGE2_ANY_FAILED=1
    fi
  done

  echo ""
  if [[ "$STAGE2_ANY_FAILED" -eq 1 ]]; then
    echo "  Warning: one or more competitor profiles were not written. Check logs above."
  elif [[ "$PIPELINE_WARNED" -eq 1 ]]; then
    echo "  Stage 2 complete with warnings: some profiles may be partial."
  else
    echo "  Stage 2 complete: all $COMP_TOTAL competitor profiles written."
  fi

  unset COMP_PIDS COMP_NAMES COMP_LOGS
  unset COMPETITOR_LIST

  fi  # end: competitors found
fi    # end: stage not skipped


# ═══════════════════════════════════════════════════════════════════════════════
# STAGE 3 — Competitive Analyst
# ═══════════════════════════════════════════════════════════════════════════════

run_stage 3 "Competitive Analyst" "$AGENT_04" \
"Conduct a competitive analysis for ${COMPANY} in the ${INDUSTRY} market.

Commissioning company: ${COMPANY}
Company context: ${CONTEXT}
Research depth: ${DEPTH}
${FOCUS_LINE}

Your input files are in:
- Industry research:   ${OUT_DIR}/industry/
- Competitor profiles: ${OUT_DIR}/competitors/

Read all available files in both directories before beginning your analysis.

TURN BUDGET: You have approximately ${MAX_TURNS} turns. Manage them as follows:
- Turn 1: Write skeleton output files immediately — section headers and one-line placeholders only.
- Turns 2 through $((MAX_TURNS - 3)): Read inputs and fill in each section with real analysis.
- Final 3 turns: Save your finalized output files. A thinner but complete analysis is better
  than a detailed but incomplete one. Do not start new reading in your final 3 turns.
  You can write multiple files in a single turn by making multiple Write tool calls in one
  response — do this to use your writing turns efficiently. You have several files to write
  (including one SWOT file per competitor) so batching is important here.

Write your outputs to:
- ${OUT_DIR}/analysis/competitive_analysis_report.md
- ${OUT_DIR}/analysis/key_insights.md
- ${OUT_DIR}/analysis/positioning_map_data.csv
- ${OUT_DIR}/analysis/swot_[company_name].md  (one file per competitor profiled)

Follow your standard workflow exactly as specified in your agent instructions." \
"$MAX_TURNS" \
"${OUT_DIR}/analysis/competitive_analysis_report.md"

halt_if_failed


# ═══════════════════════════════════════════════════════════════════════════════
# STAGE 4 — GTM Analyst
# ═══════════════════════════════════════════════════════════════════════════════

run_stage 4 "GTM Analyst" "$AGENT_05" \
"Develop a go-to-market strategy for ${COMPANY} in the ${INDUSTRY} market.

Commissioning company: ${COMPANY}
Company context: ${CONTEXT}
Research depth: ${DEPTH}
${FOCUS_LINE}

Your input files are in:
- Industry research:    ${OUT_DIR}/industry/
- Competitor profiles:  ${OUT_DIR}/competitors/
- Competitive analysis: ${OUT_DIR}/analysis/

Read all available files in those directories. Pay special attention to key_insights.md.

TURN BUDGET: You have approximately ${MAX_TURNS} turns. Manage them as follows:
- Turn 1: Write skeleton output files immediately — section headers and one-line placeholders only.
- Turns 2 through $((MAX_TURNS - 3)): Read inputs and fill in each section with real strategy.
- Final 3 turns: Save your finalized output files. A thinner but complete strategy is better
  than a detailed but incomplete one. Do not start new reading in your final 3 turns.
  You can write multiple files in a single turn by making multiple Write tool calls in one
  response — do this to use your writing turns efficiently.

Write your outputs to:
- ${OUT_DIR}/gtm/gtm_strategy_report.md
- ${OUT_DIR}/gtm/icp_profiles.md
- ${OUT_DIR}/gtm/messaging_framework.md
- ${OUT_DIR}/gtm/gtm_recommendations_summary.md

Follow your standard workflow exactly as specified in your agent instructions." \
"$MAX_TURNS" \
"${OUT_DIR}/gtm/gtm_strategy_report.md"

halt_if_failed


# ═══════════════════════════════════════════════════════════════════════════════
# STAGE 5 — Innovation Guru
# ═══════════════════════════════════════════════════════════════════════════════

run_stage 5 "Innovation Guru" "$AGENT_06" \
"Identify innovation opportunities and disruption scenarios for ${COMPANY} in the ${INDUSTRY} market.

Commissioning company: ${COMPANY}
Company context: ${CONTEXT}
Research depth: ${DEPTH}
${FOCUS_LINE}

Your input files are in:
- Industry research:    ${OUT_DIR}/industry/
- Competitor profiles:  ${OUT_DIR}/competitors/
- Competitive analysis: ${OUT_DIR}/analysis/

Read all available files in those directories. Pay special attention to key_insights.md.

TURN BUDGET: You have approximately ${MAX_TURNS} turns. Manage them as follows:
- Turn 1: Write skeleton output files immediately — section headers and one-line placeholders only.
- Turns 2 through $((MAX_TURNS - 2)): Read inputs and fill in each section with real analysis.
- Final 2 turns: Save your finalized output files. A thinner but complete report is better than a detailed but incomplete one. Do not start new reading in your final 2 turns.
  You can write multiple files in a single turn by making multiple Write tool calls in one response — do this to use your writing turns efficiently.

Write your outputs to:
- ${OUT_DIR}/innovation/innovation_opportunities.md
- ${OUT_DIR}/innovation/disruption_scenarios.md
- ${OUT_DIR}/innovation/opportunity_priority_matrix.md

Follow your standard workflow exactly as specified in your agent instructions." \
"$MAX_TURNS" \
"${OUT_DIR}/innovation/innovation_opportunities.md"

halt_if_failed


# ═══════════════════════════════════════════════════════════════════════════════
# STAGE 6 — Consultant  (final synthesis — no web search, reads only)
# ═══════════════════════════════════════════════════════════════════════════════

run_stage 6 "Consultant — Final Synthesis" "$AGENT_07" \
"Synthesize a final strategic report for ${COMPANY} in the ${INDUSTRY} market.

All research and analysis is complete. Your role is synthesis only — do not conduct
new web research. Read all input files first, then write your four deliverables.

Commissioning company: ${COMPANY}
Company context: ${CONTEXT}
${FOCUS_LINE}

TURN BUDGET: You have approximately ${CONSULTANT_TURNS} turns. Manage them as follows:
- Turn 1: Write skeleton output files immediately — section headers and one-line placeholders only.
- Turns 2 through $((CONSULTANT_TURNS - 3)): Read all inputs and fill in each section with real synthesis.
- Final 3 turns: Save your finalized output files. A thinner but complete synthesis is better
  than a detailed but incomplete one. Do not start new reading in your final 3 turns.
  You can write multiple files in a single turn by making multiple Write tool calls in one
  response — do this to use your writing turns efficiently.

Read ALL files from these directories before writing section content:
- ${OUT_DIR}/industry/
- ${OUT_DIR}/competitors/
- ${OUT_DIR}/analysis/
- ${OUT_DIR}/gtm/
- ${OUT_DIR}/innovation/

Write your outputs to:
- ${OUT_DIR}/synthesis/strategic_synthesis_report.md
- ${OUT_DIR}/synthesis/executive_summary.md
- ${OUT_DIR}/synthesis/action_plan.md
- ${OUT_DIR}/synthesis/assumptions_and_risks.md

Follow your standard workflow exactly as specified in your agent instructions." \
"$CONSULTANT_TURNS" \
"${OUT_DIR}/synthesis/executive_summary.md"


# ═══════════════════════════════════════════════════════════════════════════════
# Final summary
# ═══════════════════════════════════════════════════════════════════════════════
RUN_END="$(date '+%Y-%m-%d %H:%M:%S')"

FINAL_STATUS="SUCCESS"
[[ "$PIPELINE_WARNED"  -eq 1 ]] && FINAL_STATUS="COMPLETED WITH WARNINGS"
[[ "$PIPELINE_FAILED"  -eq 1 ]] && FINAL_STATUS="FAILED"

cat >> "$RUN_LOG" <<EOF
---

## Run Complete

**Ended:** $RUN_END
**Final status:** $FINAL_STATUS

### Output locations
- \`research-strategy/outputs/industry/\`
- \`research-strategy/outputs/competitors/\`
- \`research-strategy/outputs/analysis/\`
- \`research-strategy/outputs/gtm/\`
- \`research-strategy/outputs/innovation/\`
- \`research-strategy/outputs/synthesis/\`

### Suggested next steps
- Read the executive summary: \`outputs/synthesis/executive_summary.md\`
- Review the action plan: \`outputs/synthesis/action_plan.md\`
- Note quality issues or gaps in this run log and refine agent specs before the next run
EOF

hdr "Run Complete"
echo " Industry: $INDUSTRY"
echo " Status:   $FINAL_STATUS"
echo " Ended:    $RUN_END"
echo ""
echo " Outputs:"
echo "   $OUT_DIR/industry/"
echo "   $OUT_DIR/competitors/"
echo "   $OUT_DIR/analysis/"
echo "   $OUT_DIR/gtm/"
echo "   $OUT_DIR/innovation/"
echo "   $OUT_DIR/synthesis/"
echo ""
echo " Run log:  $RUN_LOG"
sep
echo ""

if [[ "$PIPELINE_FAILED" -eq 1 ]]; then
  echo "One or more stages wrote no output. Check the run log for details."
  exit 1
elif [[ "$PIPELINE_WARNED" -eq 1 ]]; then
  echo "Pipeline completed with warnings — some stages hit the turn limit and may have partial output."
  echo "Review flagged files before relying on downstream results."
fi
