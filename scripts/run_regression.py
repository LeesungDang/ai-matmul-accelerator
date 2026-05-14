#!/usr/bin/env python3
"""
Simple regression runner for the ai-matmul-accelerator project.

This script is intentionally straightforward so it is easy to read and modify
for students learning RTL verification and ASIC flow automation.
"""

from __future__ import annotations

import datetime as dt
import pathlib
import re
import subprocess
import sys
from dataclasses import dataclass, field


REPO_ROOT = pathlib.Path(__file__).resolve().parent.parent
REPORT_PATH = REPO_ROOT / "docs" / "regression_report.md"


@dataclass
class CommandResult:
    name: str
    command: list[str]
    status: str
    returncode: int
    stdout: str
    stderr: str


@dataclass
class SynthesisMetrics:
    script_name: str
    status: str
    top_module: str = "N/A"
    wires: str = "N/A"
    wire_bits: str = "N/A"
    cells: str = "N/A"
    major_cells: dict[str, int] = field(default_factory=dict)


def run_command(name: str, command: list[str]) -> CommandResult:
    try:
        completed = subprocess.run(
            command,
            cwd=REPO_ROOT,
            capture_output=True,
            text=True,
        )
        return CommandResult(
            name=name,
            command=command,
            status="PASS" if completed.returncode == 0 else "FAIL",
            returncode=completed.returncode,
            stdout=completed.stdout,
            stderr=completed.stderr,
        )
    except FileNotFoundError as exc:
        return CommandResult(
            name=name,
            command=command,
            status="FAIL",
            returncode=127,
            stdout="",
            stderr=str(exc),
        )


def parse_top_from_script(script_path: pathlib.Path) -> str:
    try:
        for line in script_path.read_text().splitlines():
            line = line.strip()
            match = re.match(r"hierarchy\s+-top\s+(\S+)", line)
            if match:
                return match.group(1)
    except OSError:
        pass
    return "N/A"


def parse_yosys_metrics(script_path: pathlib.Path, output: str, status: str) -> SynthesisMetrics:
    metrics = SynthesisMetrics(
        script_name=script_path.name,
        status=status,
        top_module=parse_top_from_script(script_path),
    )

    if status != "PASS":
        return metrics

    blocks: list[tuple[str, str]] = re.findall(
        r"===\s+(\S+)\s+===\s*(.*?)(?=\n===\s+\S+\s+===|\Z)",
        output,
        flags=re.S,
    )

    selected_name = metrics.top_module
    selected_body = ""
    for block_name, block_body in blocks:
        if block_name == metrics.top_module and has_cell_stats(block_body):
            selected_name = block_name
            selected_body = block_body
            break

    if not selected_body:
        for block_name, block_body in reversed(blocks):
            if has_cell_stats(block_body):
                selected_name = block_name
                selected_body = block_body
                break

    if not selected_body:
        return metrics

    metrics.top_module = selected_name
    metrics.wires = extract_stat(selected_body, "Number of wires")
    metrics.wire_bits = extract_stat(selected_body, "Number of wire bits")
    metrics.cells = extract_stat(selected_body, "Number of cells")
    metrics.major_cells = extract_major_cells(selected_body)
    return metrics


def has_cell_stats(block: str) -> bool:
    return "Number of cells:" in block or bool(re.search(r"^\s*\d+\s+cells$", block, flags=re.M))


def extract_stat(block: str, label: str) -> str:
    compact_labels = {
        "Number of wires": "wires",
        "Number of wire bits": "wire bits",
        "Number of cells": "cells",
    }
    compact_label = compact_labels.get(label, "")

    match = re.search(rf"{re.escape(label)}:\s+(\d+)", block)
    if match:
        return match.group(1)

    if compact_label:
        match = re.search(rf"^\s*(\d+)\s+{re.escape(compact_label)}$", block, flags=re.M)

    return match.group(1) if match else "N/A"


def extract_major_cells(block: str) -> dict[str, int]:
    cell_counts: dict[str, int] = {}

    in_cells_section = False
    for raw_line in block.splitlines():
        line = raw_line.rstrip()
        if not in_cells_section:
            if re.search(r"Number of cells:\s+\d+", line) or re.search(r"^\s*\d+\s+cells$", line):
                in_cells_section = True
            continue

        match = re.match(r"\s+(\d+)\s+(\S+)$", line)
        if not match:
            if line.strip():
                break
            continue

        cell_count = int(match.group(1))
        cell_name = match.group(2)
        cell_counts[cell_name] = cell_count

    return dict(sorted(cell_counts.items(), key=lambda item: item[1], reverse=True)[:6])


def markdown_escape(text: str) -> str:
    return text.replace("|", "\\|")


def build_report(
    generated_at: dt.datetime,
    command_results: list[CommandResult],
    synthesis_results: list[SynthesisMetrics],
) -> str:
    make_all_result = next(result for result in command_results if result.name == "make all")

    lines: list[str] = []
    lines.append("# Regression Report")
    lines.append("")
    lines.append(f"Generated: {generated_at.isoformat()}")
    lines.append("")
    lines.append("## Test Summary")
    lines.append("")
    lines.append("| Step | Command | Status | Notes |")
    lines.append("|---|---|---|---|")
    for result in command_results:
        notes = ""
        if result.name == "make all":
            notes = "Runs all core RTL tests, Python golden models, and randomized MMIO verification."
        elif result.name == "make clean":
            notes = "Removes generated simulation artifacts and test vectors."
        elif result.name.startswith("yosys"):
            notes = "Synthesis run driven by an existing Yosys script."
        lines.append(
            f"| {markdown_escape(result.name)} | `{' '.join(result.command)}` | {result.status} | {markdown_escape(notes)} |"
        )

    lines.append("")
    lines.append("## Verification Status")
    lines.append("")
    lines.append(
        f"`make all` status: **{make_all_result.status}**. This target includes the MMIO randomized verification flow via `make matmul4mmiorandom`."
    )
    lines.append("")

    lines.append("## Synthesis Summary")
    lines.append("")
    lines.append("| Script | Status | Top Module | Wires | Wire Bits | Cells | Major Cell Counts |")
    lines.append("|---|---|---|---|---|---|---|")
    for metrics in synthesis_results:
        if metrics.major_cells:
            major_cells = ", ".join(f"{name}={count}" for name, count in metrics.major_cells.items())
        else:
            major_cells = "N/A"
        lines.append(
            f"| `{metrics.script_name}` | {metrics.status} | `{metrics.top_module}` | {metrics.wires} | {metrics.wire_bits} | {metrics.cells} | {markdown_escape(major_cells)} |"
        )

    lines.append("")
    lines.append("## Interpretation")
    lines.append("")
    lines.append(
        "This regression checks that the main verification flow still passes end-to-end and that the available Yosys synthesis scripts still run."
    )

    passing_synth = [metrics for metrics in synthesis_results if metrics.status == "PASS"]
    if make_all_result.status == "PASS" and len(passing_synth) == len(synthesis_results):
        lines.append(
            "All requested verification and synthesis steps completed successfully, so the repo is in a good state for further RTL or flow changes."
        )
    else:
        lines.append(
            "At least one verification or synthesis step failed, so the failing command should be reviewed before treating the current repo state as a clean baseline."
        )

    if passing_synth:
        lines.append(
            "The cell counts provide a quick hardware cost snapshot: larger combinational designs usually show much higher wire and cell counts than the more sequential control-oriented version."
        )

    lines.append("")
    lines.append("## Notes")
    lines.append("")
    lines.append("- This report is auto-generated by `scripts/run_regression.py`.")
    lines.append("- The script uses only Python standard library modules.")
    return "\n".join(lines) + "\n"


def main() -> int:
    command_results: list[CommandResult] = []

    command_plan = [
        ("make clean", ["make", "clean"]),
        ("make all", ["make", "all"]),
    ]

    synthesis_scripts = [
        REPO_ROOT / "synth" / "matmul_4x4_flat.ys",
        REPO_ROOT / "synth" / "matmul_4x4_seq_flat.ys",
        REPO_ROOT / "synth" / "matmul_4x4_mmio.ys",
    ]

    for name, command in command_plan:
        print(f"[run_regression] Running: {' '.join(command)}")
        result = run_command(name, command)
        command_results.append(result)
        print(f"[run_regression] {name}: {result.status}")

    synthesis_results: list[SynthesisMetrics] = []
    for script_path in synthesis_scripts:
        if script_path.exists():
            command = ["yosys", "-s", str(script_path)]
            name = f"yosys {script_path.name}"
            print(f"[run_regression] Running: {' '.join(command)}")
            result = run_command(name, command)
            command_results.append(result)
            print(f"[run_regression] {name}: {result.status}")
            combined_output = result.stdout + "\n" + result.stderr
            synthesis_results.append(
                parse_yosys_metrics(script_path, combined_output, result.status)
            )
        else:
            synthesis_results.append(
                SynthesisMetrics(
                    script_name=script_path.name,
                    status="SKIP",
                )
            )

    report = build_report(dt.datetime.now().astimezone(), command_results, synthesis_results)
    REPORT_PATH.write_text(report)
    print(f"[run_regression] Wrote report to {REPORT_PATH}")

    failed_commands = [result for result in command_results if result.status == "FAIL"]
    if failed_commands:
        print("[run_regression] One or more commands failed:")
        for result in failed_commands:
            print(f"  - {result.name} (exit code {result.returncode})")
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())
