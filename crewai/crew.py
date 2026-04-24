from pathlib import Path
from crewai import Task, Crew, Process

from tools import make_tools
from agents import make_specialists, make_supervisor

# Absolute path so agents always know where to write outputs
OUTPUTS_DIR = Path(__file__).parent.parent / "research-strategy" / "outputs"


def make_research_crew() -> Crew:
    """
    Assemble the Research & Strategy crew with a hierarchical process.

    The supervisor (manager_agent) receives the request and decides:
      - Which specialists to activate
      - In what order
      - Whether all 6 are needed or just 1 or 2

    This is the key difference from Phase 1 (bash script), where the orchestration
    was hardcoded. Here the supervisor LLM makes those routing decisions dynamically.
    """
    search, write, read = make_tools()
    specialists = make_specialists(search, write, read)
    supervisor = make_supervisor()

    # A single entry-point task. The supervisor reads this, decides which specialists
    # to delegate to, and assembles the final result. The request may require all six
    # agents or just one — the supervisor determines that.
    research_task = Task(
        description=(
            "Handle this research request:\n\n"
            "{request}\n\n"
            "---\n"
            "Company context (who is commissioning this research):\n"
            "{company_context}\n\n"
            "---\n"
            "Instructions:\n"
            "1. Read the request carefully and determine which specialists are actually needed.\n"
            "   A request like 'profile one competitor' needs only the Competitor Researcher.\n"
            "   A full market analysis needs the complete team in sequence.\n"
            "2. Activate only the agents the request requires — do not run all six by default.\n"
            "3. Sequence correctly: researchers before analysts, analysts before Consultant.\n"
            "4. All file outputs must be written to subdirectories under:\n"
            f"   {OUTPUTS_DIR}\n"
            "   Use the same subdirectory structure as Phase 1:\n"
            "   - industry/  for market research outputs\n"
            "   - competitors/  for competitor profiles\n"
            "   - analysis/  for competitive analysis\n"
            "   - gtm/  for go-to-market strategy\n"
            "   - innovation/  for innovation opportunities\n"
            "   - synthesis/  for the Consultant's final synthesis\n"
            "5. After all agents complete, provide a brief summary of what was produced.\n\n"
            "IMPORTANT — write_file tool usage:\n"
            "The write_file tool requires BOTH arguments in a single call:\n"
            "  - path: absolute file path (e.g., "
            f"'{OUTPUTS_DIR.as_posix()}/competitors/briteco_profile.md')\n"
            "  - content: the complete text of the file — must not be empty\n"
            "Pass the full content in one call. There is no second step to add content later."
        ),
        expected_output=(
            "A summary of which agents were activated, what each produced, and where the "
            "output files were written. The actual research deliverables are in the output "
            "files — this summary is the routing log."
        ),
    )

    return Crew(
        agents=specialists,
        tasks=[research_task],
        process=Process.hierarchical,
        manager_agent=supervisor,
        verbose=True,
    )
