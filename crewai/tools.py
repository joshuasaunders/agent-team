import os
from pathlib import Path
from crewai.tools import tool
from crewai_tools import SerperDevTool

# Absolute path to the shared outputs directory (same location Phase 1 wrote to)
OUTPUTS_DIR = Path(__file__).parent.parent / "research-strategy" / "outputs"


@tool("write_file")
def write_file(path: str, content: str) -> str:
    """Write content to a file. Creates parent directories if they do not exist.

    BOTH arguments are required in a single call. Do not call this tool without
    providing the full content — there is no separate step to add content later.

    Args:
        path: Absolute file path where the file should be written
              (e.g., 'C:/Development/agent-team/research-strategy/outputs/competitors/briteco_profile.md')
        content: The COMPLETE text content of the file. Must not be empty.
                 Include the entire markdown/text body here in this single call.

    Returns:
        Confirmation message with character count written.
    """
    if not content:
        return "ERROR: content is empty. You must pass the full file content as the 'content' argument."
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)
    return f"Successfully wrote {len(content)} characters to {path}"


@tool("read_file")
def read_file(path: str) -> str:
    """Read and return the full contents of a file.

    Args:
        path: Absolute file path to read.

    Returns:
        The full text content of the file.
    """
    with open(path, "r", encoding="utf-8") as f:
        return f.read()


def make_tools():
    """Return the three tools used across the research team."""
    search = SerperDevTool()
    return search, write_file, read_file
