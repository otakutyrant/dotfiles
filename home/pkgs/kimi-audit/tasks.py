"""Reusable task selection and source snapshots; the supervisor owns execution."""
import argparse
import contextlib
import fcntl
import hashlib
import html
import io
import json
import os
import shutil
import signal
import stat
import subprocess
import sys
import time
import uuid
from datetime import datetime
from pathlib import Path

from host_api import Client, Hold, atomic_json
from supervisor import tick

TERMINAL = {"complete", "cancelled"}
EXCLUDED = {".git", ".hg", ".svn", "node_modules", ".venv", "venv", "__pycache__", ".direnv"}


def read_json(path, default=None):
    return json.loads(path.read_text()) if path.exists() else default


@contextlib.contextmanager
def task_lock(root):
    root.mkdir(parents=True, exist_ok=True, mode=0o700)
    with (root / "task.lock").open("a") as stream:
        try:
            fcntl.flock(stream, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            raise ValueError("An audit operation is running. Use pause or cancel before changing tasks.") from None
        yield


def selected(root):
    pointer = read_json(root / "active.json")
    if pointer is None:
        return None
    name = pointer["id"]
    if not isinstance(name, str) or len(name) != 12 or any(c not in "0123456789abcdef" for c in name):
        raise ValueError("Invalid active task ID")
    return root / "jobs" / name


def task_status(job):
    if job is None:
        return {"status": "idle"}
    metadata = read_json(job / "task.json", {})
    checkpoint = read_json(job / "status.json", {})
    return {**metadata, **checkpoint, "directory": str(job),
            "report": str(job / "REPORT.md") if (job / "REPORT.md").exists() else None}


def copy_regular(root_fd, relative, target):
    """Open every component relative to the root FD without following symlinks."""
    parts = Path(relative).parts
    if not parts or Path(relative).is_absolute() or any(p in (".", "..") for p in parts):
        raise ValueError("Unsafe project path")
    directory = os.dup(root_fd)
    try:
        for part in parts[:-1]:
            next_fd = os.open(part, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW, dir_fd=directory)
            os.close(directory)
            directory = next_fd
        fd = os.open(parts[-1], os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK, dir_fd=directory)
        with os.fdopen(fd, "rb") as source:
            before = os.fstat(source.fileno())
            if not stat.S_ISREG(before.st_mode):
                raise ValueError("not a regular file")
            if before.st_size > 10 * 1024 * 1024:
                raise ValueError("larger than 10 MiB")
            data = source.read(10 * 1024 * 1024 + 1)
            after = os.fstat(source.fileno())
            if len(data) > 10 * 1024 * 1024 or (before.st_size, before.st_mtime_ns) != (after.st_size, after.st_mtime_ns):
                raise ValueError("file changed while snapshotting")
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(data)
        return len(data), hashlib.sha256(data).hexdigest()
    finally:
        os.close(directory)


def snapshot(project, destination, git, all_files=False):
    if all_files:
        names = []
        for directory, dirs, files in os.walk(project, followlinks=False):
            dirs[:] = sorted(d for d in dirs if d not in EXCLUDED and not Path(directory, d).is_symlink())
            names.extend(str(Path(directory, f).relative_to(project)) for f in sorted(files))
        selection = "directory-files"
    else:
        result = subprocess.run([git, "--no-optional-locks", "-c", "core.fsmonitor=false",
                                 "-c", "core.hooksPath=/dev/null", "-C", str(project),
                                 "ls-files", "--cached", "-z"], capture_output=True)
        if result.returncode:
            raise ValueError("Not a Git working tree. For a plain directory, explicitly pass --all-files.")
        names = os.fsdecode(result.stdout).split("\0")[:-1]
        selection = "git-tracked-working-tree"
    if len(names) > 100000:
        raise ValueError("Snapshot exceeds 100,000 files; choose a smaller project directory")
    destination.mkdir()
    omitted, files, total = [], [], 0
    root_fd = os.open(project, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW)
    try:
        for name in sorted(set(names)):
            parts = Path(name).parts
            if any(p in EXCLUDED for p in parts) or Path(name).name.startswith(".env"):
                omitted.append({"path": name, "reason": "excluded metadata/cache/environment file"})
                continue
            try:
                size, digest = copy_regular(root_fd, name, destination / name)
            except (OSError, ValueError):
                omitted.append({"path": name, "reason": "symlink, missing, special, changing or oversized file"})
                continue
            total += size
            if total > 500 * 1024 * 1024:
                raise ValueError("Snapshot exceeds 500 MiB; choose a smaller project directory")
            files.append({"path": name, "sha256": digest})
    finally:
        os.close(root_fd)
    if not files:
        raise ValueError("No eligible source files. Git mode includes tracked files only.")
    digest = hashlib.sha256(json.dumps(files, sort_keys=True).encode()).hexdigest()
    return {"selection": selection, "files": files, "omitted": omitted, "sha256": digest, "bytes": total}


def create_task(runtime, root, project, all_files=False, instructions=None):
    current = selected(root)
    if current and task_status(current).get("status") not in TERMINAL:
        raise ValueError("An unfinished task already exists. Resume it or cancel it before starting another.")
    project = Path(project).expanduser().resolve(strict=True)
    if not project.is_dir() or project in (Path("/"), Path.home()) or project == root or root.is_relative_to(project) or project.is_relative_to(root):
        raise ValueError("Choose a project directory, not your home, filesystem root or audit state")
    name = uuid.uuid4().hex[:12]
    job = root / "jobs" / name
    job.mkdir(parents=True, mode=0o700)
    try:
        manifest = snapshot(project, job / "source", runtime["bins"]["git"], all_files)
        atomic_json(job / "manifest.json", manifest)
        prompt = Path(runtime["scripts"], "prompt.txt").read_text()
        prompt += "\nSnapshot metadata: " + json.dumps({
            "selection": manifest["selection"], "sha256": manifest["sha256"],
            "included_files": len(manifest["files"]), "omitted_files": len(manifest["omitted"]),
        }) + "\nSee /audit/manifest.json for paths, hashes and omitted files.\n"
        if instructions:
            prompt += "\nAdditional user audit focus:\n" + Path(instructions).expanduser().read_text()
        (job / "prompt.txt").write_text(prompt)
        atomic_json(job / "task.json", {"id": name, "project": str(project),
                    "created_at": time.time(), "snapshot_sha256": manifest["sha256"],
                    "included_files": len(manifest["files"]), "omitted_files": len(manifest["omitted"])})
        atomic_json(job / "status.json", {"status": "waiting", "reason": "submitted", "next_attempt": 0})
        atomic_json(root / "active.json", {"id": name})
        return task_status(job)
    except BaseException:
        shutil.rmtree(job)  # Only this newly created, unpublished task directory.
        raise


def notify_completion(runtime, job):
    """Called under the task lock; persist delivery state across timer ticks."""
    if read_json(job / "status.json", {}).get("status") != "complete":
        return
    report = job / "REPORT.md"
    if not report.is_file():
        return
    marker = job / "notification.json"
    delivery = read_json(marker, {})
    if delivery.get("status") in ("sending", "sent", "uncertain") or delivery.get("retry_at", 0) > time.time():
        return
    project = Path(read_json(job / "task.json", {}).get("project", "project")).name
    body = (html.escape(project) + "\n" +
            '<a href="' + html.escape(report.as_uri(), quote=True) + '">Open audit report</a>\n' +
            html.escape(str(report)))
    # Record intent before delivery: after a crash/timeout we cannot know if
    # the desktop displayed it, so do not risk sending a duplicate alert.
    atomic_json(marker, {"status": "sending", "attempted_at": time.time()})
    try:
        result = subprocess.run([
            runtime["notifySend"], "--app-name=Kimi Audit", "--icon=dialog-information",
            "--urgency=normal", "--expire-time=0", "--", "Kimi audit completed", body,
        ], capture_output=True, timeout=10)
    except subprocess.TimeoutExpired:
        atomic_json(marker, {"status": "uncertain", "attempted_at": time.time()})
        return
    except OSError:
        result = None  # Not launched; retry when the desktop becomes available.
    if result is not None and result.returncode == 0:
        atomic_json(marker, {"status": "sent", "sent_at": time.time()})
    else:
        atomic_json(marker, {"status": "pending", "retry_at": time.time() + 900})


def run_tick(runtime, root, probe=False):
    if not probe:
        # A failed desktop delivery stays pending even after selecting a new
        # project. This only reads task metadata; it never invokes the model.
        for completed_job in sorted((root / "jobs").glob("*")):
            notify_completion(runtime, completed_job)
    job = selected(root)
    if job is None:
        return {"status": "idle"}
    checkpoint = read_json(job / "status.json", {})
    if checkpoint.get("status") in TERMINAL | {"paused"} and not probe:
        return task_status(job)
    configured = {**runtime, "source": str(job / "source")}
    checks = None
    try:
        if probe:
            # Preserve a single JSON result for `kimi-audit probe --json`.
            with contextlib.redirect_stdout(io.StringIO()) as captured:
                tick(configured, job, checkpoint, True)
            checks = json.loads(captured.getvalue())
        else:
            tick(configured, job, checkpoint, False)
    except Hold as hold:
        checkpoint.update(status="blocked" if hold.blocked else "waiting", reason=hold.reason, next_attempt=hold.until)
    except Exception as error:
        checkpoint.update(status="blocked", reason="supervisor-" + type(error).__name__, next_attempt=0)
    if not probe:
        checkpoint["updated_at"] = time.time()
        atomic_json(job / "status.json", checkpoint)
        notify_completion(runtime, job)
    result = {**task_status(job), **checkpoint}
    if checks is not None:
        result["sandbox_checks"] = checks
    return result


def control_task(root, action):
    job = selected(root)
    if job is None:
        raise ValueError("No task selected")
    checkpoint = read_json(job / "status.json", {})
    if checkpoint.get("status") in TERMINAL:
        raise ValueError("Task is already complete or cancelled; start a new audit")
    if action == "resume":
        checkpoint.update(status="waiting", reason="manual-resume")
        # Preserve quota delays; a resume is not permission to bypass quota.
    else:
        checkpoint.update(status="paused" if action == "pause" else "cancelled", reason=action)
    atomic_json(job / "status.json", checkpoint)
    return task_status(job)


def output(result, as_json):
    if as_json:
        print(json.dumps(result))
        return
    print("Status: " + result["status"])
    for window in result.get("windows", []):
        print(f"  {window['window']}: {window['used_percent']:g}% used; resets {window['reset_at'] or 'unknown'}")
    for check, passed in result.get("sandbox_checks", {}).items():
        print(f"  {check}: {'PASS' if passed else 'FAIL'}")
    for key in ("id", "project", "reason", "directory", "report", "warning"):
        if result.get(key):
            print(f"{key.replace('_', ' ').capitalize()}: {result[key]}")
    if result.get("next_attempt"):
        print("Next eligible attempt: " + datetime.fromtimestamp(result["next_attempt"]).astimezone().isoformat(timespec="seconds"))


def main():
    os.umask(0o077)
    signal.signal(signal.SIGTERM, lambda number, frame: sys.exit(128 + number))
    runtime = json.loads(Path(sys.argv[1]).read_text())
    parser = argparse.ArgumentParser(prog="kimi-audit", description="One sandboxed, quota-aware project audit at a time")
    commands = parser.add_subparsers(dest="command", required=True)
    start = commands.add_parser("start", help="Snapshot a project and start its audit")
    start.add_argument("project")
    start.add_argument("--all-files", action="store_true", help="Include regular directory files instead of Git-tracked files")
    start.add_argument("--instructions", help="Text file containing additional audit focus")
    start.add_argument("--prepare-only", action="store_true", help="Save a paused task without invoking Kimi")
    for name in ("quota", "status", "pause", "resume", "cancel", "tick", "probe"):
        commands.add_parser(name)
    for command in commands.choices.values():
        command.add_argument("--json", action="store_true", help="Machine-readable output for Nushell pipelines")
    args = parser.parse_args(sys.argv[2:])
    root = Path(os.environ.get("XDG_STATE_HOME", str(Path.home() / ".local/state"))) / "kimi-audit"
    runtime["credentialsHome"] = str(Path.home() / ".kimi-code")
    try:
        if args.command == "quota":
            try:
                result = Client(runtime["credentialsHome"], runtime["caFile"]).quota_status()
            except Hold as hold:
                result = {"status": "unknown", "reason": hold.reason, "next_attempt": hold.until}
        elif args.command == "status":
            result = task_status(selected(root))
        else:
            if args.command in ("pause", "cancel"):
                subprocess.run([runtime["systemctl"], "--user", "stop", "kimi-audit.service"], check=True)
            with task_lock(root):
                if args.command == "start":
                    result = create_task(runtime, root, args.project, args.all_files, args.instructions)
                    if args.prepare_only:
                        result = control_task(root, "pause")
                elif args.command in ("tick", "probe"):
                    result = run_tick(runtime, root, args.command == "probe")
                else:
                    result = control_task(root, args.command)
            if args.command == "resume" or (args.command == "start" and not args.prepare_only):
                launched = subprocess.run([runtime["systemctl"], "--user", "start", "--no-block", "kimi-audit.service"], capture_output=True)
                if launched.returncode:
                    result["warning"] = "Task saved, but service could not start. Check systemctl --user status kimi-audit.service."
        output(result, args.json)
        return 1 if result["status"] in ("unknown", "blocked") else 0
    except (ValueError, OSError, subprocess.CalledProcessError) as error:
        # Only locally generated ValueErrors are shown; HTTP errors use Hold.
        output({"status": "error", "reason": str(error) if isinstance(error, ValueError) else type(error).__name__}, args.json)
        return 1


if __name__ == "__main__":
    sys.exit(main())
