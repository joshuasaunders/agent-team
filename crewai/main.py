"""
Research & Strategy Crew — Phase 2 (CrewAI)

Usage:
  python main.py "Your research request here"
  python main.py "Research BriteCo as a company"
  python main.py "Full market analysis of jewelry insurance" --company "Optional context about who is commissioning this"

The supervisor agent decides which specialists to activate based on the request.
A narrow request (one company) may only need the Competitor Researcher.
A broad request (full industry analysis) will activate the full team in sequence.
"""

import argparse
import os
import sys
from dotenv import load_dotenv

load_dotenv()


def check_env():
    missing = []
    if not os.environ.get("ANTHROPIC_API_KEY"):
        missing.append("ANTHROPIC_API_KEY")
    if not os.environ.get("SERPER_API_KEY"):
        missing.append("SERPER_API_KEY")
    if missing:
        print(f"ERROR: Missing required environment variables: {', '.join(missing)}")
        print("Copy .env.example to .env and fill in your API keys.")
        sys.exit(1)


def main():
    parser = argparse.ArgumentParser(
        description="Research & Strategy Crew — hierarchical multi-agent research",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    parser.add_argument(
        "request",
        help="The research request or strategic question to investigate",
    )
    parser.add_argument(
        "--company",
        default="",
        metavar="CONTEXT",
        help="Context about the company commissioning this research",
    )
    args = parser.parse_args()

    check_env()

    # Import here so env vars are loaded before crewai initializes
    from crew import make_research_crew

    print("\n" + "=" * 60)
    print("RESEARCH & STRATEGY CREW")
    print("=" * 60)
    print(f"Request: {args.request}")
    if args.company:
        print(f"Company: {args.company}")
    print("=" * 60 + "\n")

    crew = make_research_crew()
    result = crew.kickoff(inputs={
        "request": args.request,
        "company_context": args.company or "No specific company context provided.",
    })

    print("\n" + "=" * 60)
    print("CREW COMPLETE — ROUTING SUMMARY")
    print("=" * 60)
    print(result)


if __name__ == "__main__":
    main()
