"""Network-isolated Kimi entry point; only the model HTTP bridge is available."""
import json
import select
import socket
import socketserver
import subprocess
import sys
import threading
import urllib.error
import urllib.request
from pathlib import Path


class Bridge(socketserver.BaseRequestHandler):
    def handle(self):
        with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as upstream:
            upstream.connect("/gateway/socket")
            while True:
                ready, _, _ = select.select([self.request, upstream], [], [], 300)
                if not ready:
                    return
                for source in ready:
                    data = source.recv(65536)
                    if not data:
                        return
                    (upstream if source is self.request else self.request).sendall(data)


class Server(socketserver.ThreadingMixIn, socketserver.TCPServer):
    allow_reuse_address = True
    daemon_threads = True


def main():
    server = Server(("127.0.0.1", 8765), Bridge)
    threading.Thread(target=server.serve_forever, daemon=True).start()
    if "--probe" in sys.argv:
        checks = {"host_home_hidden": not Path("/home/otakutyrant").exists()}
        try:
            Path("/src/.audit-write-probe").write_text("unexpected")
            checks["source_readonly"] = False
        except OSError:
            checks["source_readonly"] = True
        try:
            with socket.create_connection(("1.1.1.1", 443), 2):
                checks["external_network_blocked"] = False
        except OSError:
            checks["external_network_blocked"] = True
        checks["broker_ready"] = urllib.request.urlopen("http://127.0.0.1:8765/health").status == 200
        try:
            urllib.request.urlopen("http://127.0.0.1:8765/denied")
            checks["other_routes_denied"] = False
        except urllib.error.HTTPError as error:
            checks["other_routes_denied"] = error.code == 403
        result = subprocess.run([
            "/bin/bash", "-c",
            '/tools/python3 -c \'import socket; socket.create_connection(("127.0.0.1",8765),2)\'',
        ], capture_output=True)
        checks["shell_broker_blocked"] = result.returncode != 0 and b"ConnectionRefusedError" in result.stderr
        print(json.dumps(checks))
        return 0 if all(checks.values()) else 1
    # This home belongs only to this task. --continue resumes its sole session,
    # including one whose quota error prevented a final resume_hint event.
    command = ["/tools/kimi", "--continue", "--skills-dir", "/home/audit/empty-skills",
               "--output-format", "stream-json", "--prompt", Path("/audit/prompt.txt").read_text()]
    return subprocess.call(command, cwd="/src")


if __name__ == "__main__":
    sys.exit(main())
