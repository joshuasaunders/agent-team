#!/usr/bin/env bash
# Run the Competitor Researcher agent headlessly against a specified company.
#
# Usage:
#   ./run_competitor_research.sh <company_name> [options]
#
# Arguments:
#   company_name        Name of the company to research (required)
#
# Options:
#   -c, --context       Brief description of YOUR company (the commissioning company).
#                       Helps the agent frame findings in relevant context.
#                       Default: "Not provided — agent will research without client framing."
#
#   -d, --depth         Research depth: "quick" or "deep" (default: deep)
#                         quick = top-line profile, 2-3 paragraphs per section
#                         deep  = full standard profile with all 10 sections
#
#   -f, --focus         Specific focus areas to emphasize, in quotes.
#                       Example: "pricing models and enterprise customer reviews"
#
#   -h, --help          Show this help message
#
# Examples:
#   ./run_competitor_research.sh "Toast"
#   ./run_competitor_research.sh "Toast" --context "We are a restaurant tech company selling inventory management software to mid-market restaurants."
#   ./run_competitor_research.sh "Toast" --depth quick --focus "pricing and SMB customer reviews"

set -euo pipefail

# ── Defaults ──────────────────────────────────────────────────────────────────
DEPTH="deep"
CONTEXT="Not provided — agent will research without client framing."
FOCUS=""

# ── Argument parsing ──────────────────────────────────────────────────────────
if [[ $# -eq 0 ]]; then
  echo "Error: company_name is required."
  echo "Usage: ./run_competitor_research.sh <company_name> [options]"
  echo "Run with --help for full usage."
  exit 1
fi

COMPANY="$1"
shift

while [[ $# -gt 0 ]]; do
  case "$1" in
    -c|--context) CONTEXT="$2"; shift 2 ;;
    -d|--depth)   DEPTH="$2";   shift 2 ;;
    -f|--focus)   FOCUS="$2";   shift 2 ;;
    -h|--help)
      head -40 "$0" | grep "^#" | sed 's/^# \?//'
      exit 0
      ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# ── Validate depth ────────────────────────────────────────────────────────────
if [[ "$DEPTH" != "quick" && "$DEPTH" != "deep" ]]; then
  echo "Error: --depth must be 'quick' or 'deep'."
  exit 1
fi

# ── Paths (relative to project root) ─────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_FILE="$SCRIPT_DIR/research-strategy/03_competitor_researcher.md"
OUTPUT_DIR="$SCRIPT_DIR/research-strategy/outputs/competitors"
COMPANY_SLUG="$(echo "$COMPANY" | tr '[:upper:]' '[:lower:]' | tr ' ' '_' | tr -cd '[:alnum:]_')"

# ── Pre-flight checks ─────────────────────────────────────────────────────────
if [[ ! -f "$AGENT_FILE" ]]; then
  echo "Error: Agent spec not found at $AGENT_FILE"
  exit 1
fi

if ! command -v claude &>/dev/null; then
  echo "Error: 'claude' CLI not found. Install with: npm install -g @anthropic-ai/claude-code"
  exit 1
fi

if [[ -z "${ANTHROPIC_API_KEY:-}" ]]; then
  echo "Error: ANTHROPIC_API_KEY environment variable is not set."
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

# ── Build task prompt ─────────────────────────────────────────────────────────
FOCUS_LINE=""
if [[ -n "$FOCUS" ]]; then
  FOCUS_LINE="Specific focus areas: $FOCUS"
else
  FOCUS_LINE="Specific focus areas: None — cover all standard profile sections equally."
fi

TASK="Research ${COMPANY} as a competitor.

Company context (commissioning company): ${CONTEXT}

Research depth: ${DEPTH}
${FOCUS_LINE}

Write your outputs to:
- ${OUTPUT_DIR}/${COMPANY_SLUG}_profile.md
- ${OUTPUT_DIR}/competitor_summary_table.csv (add or update this file)
- ${OUTPUT_DIR}/research_gaps.md (add or update this file)

Follow your standard workflow exactly as specified in your agent instructions."

# ── Run ───────────────────────────────────────────────────────────────────────
echo ""
echo "=========================================="
echo " Competitor Researcher — Headless Run"
echo "=========================================="
echo " Company:  $COMPANY"
echo " Depth:    $DEPTH"
echo " Context:  $CONTEXT"
if [[ -n "$FOCUS" ]]; then
  echo " Focus:    $FOCUS"
fi
echo " Output:   $OUTPUT_DIR/"
echo "=========================================="
echo ""

claude -p "$TASK" \
  --system-prompt-file "$AGENT_FILE" \
  --allowedTools "Read,Write,WebSearch,Bash" \
  --max-turns 20 \
  --dangerously-skip-permissions

echo ""
echo "=========================================="
echo " Run complete. Outputs written to:"
echo " $OUTPUT_DIR/"
echo "=========================================="
