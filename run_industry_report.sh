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
#   -r, --competitors   Comma-separated list of competitors to profile
#                       Example: "Toast,Square,SpotOn,Lightspeed"
#   -d, --depth         Research depth: "quick" or "deep" (default: deep)
#                         quick = top-line outputs, fewer turns per agent
#                         deep  = full standard outputs, more turns per agent
#   -f, --focus         Specific focus areas to emphasize across all agents
#   -s, --start-from    Resume from stage N (1–6). Skips all earlier stages.
#                         1 = Industry Market Researcher
#                         2 = Competitor Researcher  (one run per competitor)
#                         3 = Competitive Analyst
#                         4 = GTM Analyst
#                         5 = Innovation Guru
#                         6 = Consultant  (final synthesis)
#   -h, --help          Show this help message
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
#   ./run_industry_report.sh "restaurant technology" \
#     --company "VIP" \
#     --context "We sell POS and restaurant management software to restaurants." \
#     --competitors "Toast,Square,SpotOn" \
#     --depth deep
#
#   # Resume a partial run from Stage 4 (GTM Analyst):
#   ./run_industry_report.sh "restaurant technology" \
#     --company "VIP" \
#     --context "We sell POS and restaurant management software to restaurants." \
#     --competitors "Toast,Square,SpotOn" \
#     --start-from 4

set -uo pipefail

# ── Defaults ──────────────────────────────────────────────────────────────────
DEPTH="deep"
COMPANY="Not provided"
CONTEXT="Not provided — agents will research without client framing."
COMPETITORS=""
FOCUS=""
START_FROM=1

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
    -c|--company)      COMPANY="$2";     shift 2 ;;
    -x|--context)      CONTEXT="$2";     shift 2 ;;
    -r|--competitors)  COMPETITORS="$2"; shift 2 ;;
    -d|--depth)        DEPTH="$2";       shift 2 ;;
    -f|--focus)        FOCUS="$2";       shift 2 ;;
    -s|--start-from)   START_FROM="$2";  shift 2 ;;
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

# Consultant gets extra turns because it reads the entire output corpus.
if [[ "$DEPTH" == "quick" ]]; then
  MAX_TURNS=15
  CONSULTANT_TURNS=20
else
  MAX_TURNS=25
  CONSULTANT_TURNS=35
fi

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

# ── Create output and run directories ────────────────────────────────────────
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
**Depth:** $DEPTH
**Competitors:** ${COMPETITORS:-none}
**Focus:** ${FOCUS:-none}
**Start from stage:** $START_FROM

---

## Stage Results

EOF

# ── Helpers ───────────────────────────────────────────────────────────────────
sep()  { echo "=========================================="; }
hdr()  { echo ""; sep; echo " $1"; sep; }

log_result() {
  local stage="$1" name="$2" status="$3" t_start="$4" t_end="$5"
  cat >> "$RUN_LOG" <<EOF
### Stage $stage: $name
- Status: **$status**
- Started: $t_start
- Ended: $t_end

EOF
}

# ── State ─────────────────────────────────────────────────────────────────────
PIPELINE_FAILED=0

# ── Stage runner ──────────────────────────────────────────────────────────────
# Skips the stage if its number is below START_FROM.
# Sets PIPELINE_FAILED=1 and prints a resume hint on failure.
run_stage() {
  local stage_num="$1"
  local stage_name="$2"
  local agent_file="$3"
  local task="$4"
  local turns="${5:-$MAX_TURNS}"

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
       --allowedTools "Read,Write,WebSearch,Bash" \
       --max-turns "$turns" \
       --dangerously-skip-permissions; then

    t_end="$(date '+%Y-%m-%d %H:%M:%S')"
    log_result "$stage_num" "$stage_name" "SUCCESS" "$t_start" "$t_end"
    echo ""
    echo "  Stage $stage_num complete: $stage_name"
    return 0
  else
    local exit_code=$?
    t_end="$(date '+%Y-%m-%d %H:%M:%S')"
    log_result "$stage_num" "$stage_name" "FAILED (exit $exit_code)" "$t_start" "$t_end"
    echo ""
    echo "  Error: Stage $stage_num failed (exit $exit_code)."
    echo "  To resume from here:"
    echo "    $0 \"$INDUSTRY\" \\"
    echo "      --company \"$COMPANY\" \\"
    echo "      --context \"$CONTEXT\" \\"
    if [[ -n "$COMPETITORS" ]]; then
      echo "      --competitors \"$COMPETITORS\" \\"
    fi
    echo "      --depth $DEPTH --start-from $stage_num"
    PIPELINE_FAILED=1
    return "$exit_code"
  fi
}

halt_if_failed() {
  if [[ "$PIPELINE_FAILED" -eq 1 ]]; then
    echo ""
    echo "Pipeline halted. Fix the issue and re-run with --start-from to resume."
    exit 1
  fi
}

# ── Opening banner ────────────────────────────────────────────────────────────
hdr "Research & Strategy — Full Pipeline Run"
echo " Industry:    $INDUSTRY"
echo " Company:     $COMPANY"
echo " Depth:       $DEPTH"
echo " Competitors: ${COMPETITORS:-none}"
if [[ -n "$FOCUS" ]]; then
  echo " Focus:       $FOCUS"
fi
if [[ "$START_FROM" -gt 1 ]]; then
  echo " Resuming:    Stage $START_FROM"
fi
echo " Run log:     $RUN_LOG"
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

Write your outputs to:
- ${OUT_DIR}/industry/market_research_report.md
- ${OUT_DIR}/industry/market_data_table.csv
- ${OUT_DIR}/industry/research_confidence_notes.md

Follow your standard workflow exactly as specified in your agent instructions."

halt_if_failed


# ═══════════════════════════════════════════════════════════════════════════════
# STAGE 2 — Competitor Researcher  (all competitors run in parallel)
# Each agent gets its own log file; a summary is printed when all jobs finish.
# ═══════════════════════════════════════════════════════════════════════════════

if [[ "$START_FROM" -gt 2 ]]; then
  echo ""
  echo "  [skip] Stage 2 — Competitor Researcher"
  log_result 2 "Competitor Researcher" "SKIPPED (start-from $START_FROM)" "—" "—"

elif [[ -z "$COMPETITORS" ]]; then
  echo ""
  echo "  [skip] Stage 2 — Competitor Researcher (no --competitors provided)"
  log_result 2 "Competitor Researcher" "SKIPPED (no competitors provided)" "—" "—"

else
  IFS=',' read -ra COMPETITOR_LIST <<< "$COMPETITORS"
  COMP_TOTAL="${#COMPETITOR_LIST[@]}"

  hdr "Stage 2 of 6: Competitor Researcher  ($COMP_TOTAL in parallel)"
  echo "  Logs: $RUN_DIR/stage2_<competitor>.log"
  echo ""

  STAGE2_START="$(date '+%Y-%m-%d %H:%M:%S')"

  # ── Launch all competitor jobs in the background ───────────────────────────
  declare -A COMP_PIDS    # slug → PID
  declare -A COMP_NAMES   # slug → display name
  declare -A COMP_LOGS    # slug → log file path

  COMP_IDX=0
  for COMP_RAW in "${COMPETITOR_LIST[@]}"; do
    COMP="$(echo "$COMP_RAW" | tr -d '[:space:]')"
    COMP_SLUG="$(echo "$COMP" | tr '[:upper:]' '[:lower:]' | tr ' ' '_' | tr -cd '[:alnum:]_')"
    COMP_IDX=$(( COMP_IDX + 1 ))
    COMP_LOG="$RUN_DIR/stage2_${COMP_SLUG}.log"

    COMP_NAMES["$COMP_SLUG"]="$COMP"
    COMP_LOGS["$COMP_SLUG"]="$COMP_LOG"

    claude -p \
"Research ${COMP} as a competitor in the ${INDUSTRY} market.

Commissioning company: ${COMPANY}
Company context: ${CONTEXT}
Research depth: ${DEPTH}
${FOCUS_LINE}

Write your outputs to:
- ${OUT_DIR}/competitors/${COMP_SLUG}_profile.md
- ${OUT_DIR}/competitors/competitor_summary_table.csv  (add this competitor; create or update)
- ${OUT_DIR}/competitors/research_gaps.md              (add this competitor; create or update)

Follow your standard workflow exactly as specified in your agent instructions." \
      --system-prompt-file "$AGENT_03" \
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

    if wait "${COMP_PIDS[$COMP_SLUG]}"; then
      log_result "2" "Competitor Researcher — $COMP" \
        "SUCCESS" "$STAGE2_START" "$(date '+%Y-%m-%d %H:%M:%S')"
      echo "  OK:   $COMP"
    else
      log_result "2" "Competitor Researcher — $COMP" \
        "FAILED  (see $COMP_LOG)" "$STAGE2_START" "$(date '+%Y-%m-%d %H:%M:%S')"
      echo "  FAIL: $COMP  → $COMP_LOG"
      STAGE2_ANY_FAILED=1
    fi
  done

  echo ""
  if [[ "$STAGE2_ANY_FAILED" -eq 1 ]]; then
    echo "  Warning: one or more competitor jobs failed. Check logs above before continuing."
  else
    echo "  Stage 2 complete: all $COMP_TOTAL competitor profiles written."
  fi

  unset COMP_PIDS COMP_NAMES COMP_LOGS
fi


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

Write your outputs to:
- ${OUT_DIR}/analysis/competitive_analysis_report.md
- ${OUT_DIR}/analysis/key_insights.md
- ${OUT_DIR}/analysis/positioning_map_data.csv
- ${OUT_DIR}/analysis/swot_[company_name].md  (one file per competitor profiled)

Follow your standard workflow exactly as specified in your agent instructions."

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

Write your outputs to:
- ${OUT_DIR}/gtm/gtm_strategy_report.md
- ${OUT_DIR}/gtm/icp_profiles.md
- ${OUT_DIR}/gtm/messaging_framework.md
- ${OUT_DIR}/gtm/gtm_recommendations_summary.md

Follow your standard workflow exactly as specified in your agent instructions."

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

Write your outputs to:
- ${OUT_DIR}/innovation/innovation_opportunities.md
- ${OUT_DIR}/innovation/disruption_scenarios.md
- ${OUT_DIR}/innovation/opportunity_priority_matrix.md

Follow your standard workflow exactly as specified in your agent instructions."

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

Read ALL files from these directories before writing anything:
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
"$CONSULTANT_TURNS"


# ═══════════════════════════════════════════════════════════════════════════════
# Final summary
# ═══════════════════════════════════════════════════════════════════════════════
RUN_END="$(date '+%Y-%m-%d %H:%M:%S')"

cat >> "$RUN_LOG" <<EOF
---

## Run Complete

**Ended:** $RUN_END

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
  echo "Warning: One or more stages failed. Check the run log for details."
  exit 1
fi
