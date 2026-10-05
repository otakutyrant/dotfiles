"""One timer tick: quota preflight, sandboxed continuation, durable checkpoint."""
import hashlib
import http.server
import json
import os
import signal
import socketserver
import subprocess
import threading
import time
from email.utils import parsedate_to_datetime
from pathlib import Path

from host_api import API, Client, Hold, atomic_json


def retry_deadline(value, now):
    try:
        return max(now + 900, now + float(value))
    except (TypeError, ValueError):
        try:
            return max(now + 900, parsedate_to_datetime(value).timestamp())
        except (TypeError, ValueError, AttributeError):
            return now + 3600


class Broker(socketserver.ThreadingMixIn, socketserver.UnixStreamServer):
    daemon_threads = True


def broker(socket_path, client):
    class Handler(http.server.BaseHTTPRequestHandler):
        protocol_version = "HTTP/1.1"

        def log_message(self, *args):
            pass  # Never log Authorization or request bodies.

        def simple(self, status, body):
            self.send_response(status)
            self.send_header("Content-Length", str(len(body)))
            self.send_header("Connection", "close")
            self.end_headers()
            self.wfile.write(body)
            self.close_connection = True

        def do_GET(self):
            self.simple(200 if self.path == "/health" else 403, b"audit broker")

        def do_CONNECT(self):
            self.simple(403, b"denied")

        def do_POST(self):
            if self.path != "/kimi/chat/completions":
                self.simple(403, b"denied")
                return
            try:
                length = int(self.headers.get("Content-Length", "0"))
            except ValueError:
                length = 0
            if not 0 < length <= 24 * 1024 * 1024:
                self.simple(413, b"invalid size")
                return
            body = self.rfile.read(length)
            try:
                with self.server.request_lock:
                    if self.server.hold:
                        raise self.server.hold
                    # Check before EVERY model request, not merely once per run;
                    # do not deliberately fall through to the paid booster.
                    client.check_quota()
                    response = client.request(API + "/chat/completions", body,
                                              client.access_token(), "application/json")
                    with response:
                        if response.status == 429:
                            raise Hold("model-rate-limited", retry_deadline(response.headers.get("Retry-After"), time.time()))
                        if response.status in (401, 403):
                            raise Hold("login-required", blocked=True)
                        if response.status != 200:
                            raise Hold("model-http-" + str(response.status),
                                       time.time() + 900, blocked=response.status < 500)
                        self.send_response(200)
                        self.send_header("Content-Type", response.headers.get("Content-Type", "text/event-stream"))
                        self.send_header("Transfer-Encoding", "chunked")
                        self.send_header("Connection", "close")
                        self.end_headers()
                        while chunk := response.read1(65536):
                            self.wfile.write(f"{len(chunk):x}\r\n".encode() + chunk + b"\r\n")
                            self.wfile.flush()
                        self.wfile.write(b"0\r\n\r\n")
                        self.wfile.flush()
                        self.close_connection = True
            except Hold as hold:
                self.server.hold = hold
                try:
                    self.simple(429, b'{"error":{"message":"Audit paused by quota supervisor"}}')
                except OSError:
                    pass
            except (OSError, ValueError):
                self.server.hold = Hold("model-transport-error", time.time() + 900)

    server = Broker(str(socket_path), Handler)
    server.hold = None
    server.request_lock = threading.Lock()
    return server


def prepare(runtime, state):
    for name in ("home/.kimi-code", "home/empty-skills", "out", "tools", "gateway", "logs"):
        (state / name).mkdir(parents=True, exist_ok=True, mode=0o700)
    tools = dict(runtime["bins"])
    for name in ("cat", "head", "tail", "ls", "wc", "sort", "uniq", "cut", "readlink", "env", "true", "timeout"):
        tools[name] = runtime["coreutils"] + "/" + name
    for name, target in tools.items():
        link = state / "tools" / name
        if link.is_symlink():
            link.unlink()
        link.symlink_to(target)
    config = state / "home/.kimi-code/config.toml"
    config.write_text('''default_model = "audit"
telemetry = false
[providers.audit]
type = "kimi"
base_url = "http://127.0.0.1:8765/kimi"
api_key = "audit-placeholder-not-a-secret"
[models.audit]
provider = "audit"
model = "kimi-for-coding"
max_context_size = 1048576
''')
    # Only the non-secret runtime description enters the sandbox.
    atomic_json(state / "runtime.json", {"bins": runtime["bins"]})


def sandbox_args(runtime, state, probe=False):
    args = [runtime["bins"]["bwrap"], "--unshare-all", "--die-with-parent",
            "--new-session", "--clearenv", "--dir", "/nix/store"]
    for store in Path(runtime["storesFile"]).read_text().splitlines():
        args += ["--ro-bind", store, store]
    args += ["--ro-bind", runtime["source"], "/src",
             "--ro-bind", str(state / "tools"), "/tools", "--dir", "/audit",
             "--ro-bind", str(state / "runtime.json"), "/audit/runtime.json"]
    args += ["--ro-bind", str(state / "prompt.txt"), "/audit/prompt.txt"]
    args += ["--ro-bind", str(state / "manifest.json"), "/audit/manifest.json"]
    for name in ("inside.py", "offline-shell.nu"):
        args += ["--ro-bind", str(Path(runtime["scripts"]) / name), "/audit/" + name]
    args += ["--dir", "/bin", "--ro-bind", str(Path(runtime["scripts"]) / "offline-shell.nu"), "/bin/bash",
             "--ro-bind", str(Path(runtime["scripts"]) / "offline-shell.nu"), "/bin/sh",
             "--dir", "/usr/bin", "--symlink", runtime["coreutils"] + "/env", "/usr/bin/env",
             "--bind", str(state / "home"), "/home/audit",
             "--bind", str(state / "out"), "/out",
             "--ro-bind", str(state / "gateway/socket"), "/gateway/socket",
             "--tmpfs", "/tmp", "--proc", "/proc", "--dev", "/dev"]
    env = {"HOME": "/home/audit", "KIMI_CODE_HOME": "/home/audit/.kimi-code",
           "PATH": "/tools:/bin", "SHELL": "/bin/bash", "LANG": "C.UTF-8",
           "TERM": "dumb", "KIMI_DISABLE_TELEMETRY": "1", "NO_PROXY": "127.0.0.1,localhost"}
    for key, value in env.items():
        args += ["--setenv", key, value]
    return args + ["--chdir", "/src", "/tools/python3", "/audit/inside.py"] + (["--probe"] if probe else [])


def report_from_log(path):
    last = None
    resumed = False
    for line in path.read_text().splitlines():
        try:
            item = json.loads(line)
        except ValueError:
            continue
        if not isinstance(item, dict):
            continue
        if item.get("role") == "assistant":
            last = item
        if item.get("type") == "session.resume_hint":
            resumed = True
    if (resumed and last and not last.get("tool_calls") and
            isinstance(last.get("content"), str) and
            last["content"].rstrip().endswith("\nAUDIT_COMPLETE")):
        return last["content"].rsplit("\nAUDIT_COMPLETE", 1)[0].strip() + "\n"
    return None


def invoke(runtime, state, client, probe):
    prepare(runtime, state)
    socket = state / "gateway/socket"
    socket.unlink(missing_ok=True)
    server = broker(socket, client)
    threading.Thread(target=server.serve_forever, daemon=True).start()
    stamp = str(time.time_ns())
    log = state / "logs" / (stamp + ".jsonl")
    args = sandbox_args(runtime, state, probe)
    atomic_json(state / "last-invocation.json", {"argv": args, "log": str(log)})
    process = None
    try:
        with log.open("w") as output:
            process = subprocess.Popen(args, stdout=output, stderr=subprocess.STDOUT)
            deadline = time.monotonic() + 6900
            while process.poll() is None:
                if server.hold or time.monotonic() > deadline:
                    process.send_signal(signal.SIGTERM)
                    try:
                        process.wait(timeout=20)
                    except subprocess.TimeoutExpired:
                        process.kill()
                        process.wait()
                    if not server.hold:
                        server.hold = Hold("run-timeout", time.time() + 900)
                    break
                time.sleep(0.5)
        if server.hold:
            raise server.hold
        if process.returncode != 0:
            raise Hold("kimi-exit-" + str(process.returncode), blocked=True)
        if probe:
            print(log.read_text().strip())
            return None
        return report_from_log(log)
    finally:
        if process is not None and process.poll() is None:
            process.terminate()
            try:
                process.wait(timeout=20)
            except subprocess.TimeoutExpired:
                process.kill()
                process.wait()
        server.shutdown()
        server.server_close()
        socket.unlink(missing_ok=True)


def tick(runtime, state, checkpoint, probe):
    client = Client(runtime["credentialsHome"], runtime["caFile"])
    if probe:
        invoke(runtime, state, client, True)
        return
    fingerprint = hashlib.sha256((runtime["source"] + (state / "prompt.txt").read_text()).encode()).hexdigest()
    if checkpoint.get("task", fingerprint) != fingerprint:
        raise Hold("task-changed-use-new-state-directory", blocked=True)
    checkpoint["task"] = fingerprint
    if checkpoint.get("status") == "complete":
        return
    # A changed credential file unblocks authentication only, never code errors.
    credential_version = client.token_file.stat().st_mtime_ns if client.token_file.exists() else 0
    if checkpoint.get("status") == "blocked":
        if checkpoint.get("reason") != "login-required" or checkpoint.get("credential_version") == credential_version:
            return
    checkpoint["credential_version"] = credential_version
    if checkpoint.get("next_attempt", 0) > time.time():
        return
    client.check_quota()
    # Limit successful-but-unfinished turns: no infinite spending if the model
    # repeatedly ignores the completion contract. Quota pauses do not count.
    if checkpoint.get("unfinished_turns", 0) >= 8:
        raise Hold("unfinished-turn-limit-review-progress", blocked=True)
    checkpoint.update(status="running", next_attempt=0)
    atomic_json(state / "status.json", checkpoint)
    report = invoke(runtime, state, client, False)
    if report:
        (state / "REPORT.md").write_text(report)
        checkpoint.update(status="complete", reason="report-written", next_attempt=0)
    else:
        checkpoint["unfinished_turns"] = checkpoint.get("unfinished_turns", 0) + 1
        checkpoint.update(status="waiting", reason="continue-session", next_attempt=time.time() + 900)
