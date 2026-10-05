"""Host-only OAuth and fixed-endpoint HTTP; never mounted in the audit sandbox."""
import contextlib
import json
import math
import os
import ssl
import tempfile
import threading
import time
import urllib.error
import urllib.parse
import urllib.request
from datetime import datetime
from pathlib import Path

API = "https://api.kimi.com/coding/v1"
AUTH = "https://auth.kimi.com/api/oauth/token"


class Hold(Exception):
    def __init__(self, reason, until=0, blocked=False):
        super().__init__(reason)
        self.reason, self.until, self.blocked = reason, until, blocked


def atomic_json(path, value):
    path = Path(path)
    fd, tmp = tempfile.mkstemp(dir=path.parent, prefix=path.name + ".")
    try:
        with os.fdopen(fd, "w") as stream:
            json.dump(value, stream, indent=2)
            stream.write("\n")
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(tmp, path)
    finally:
        Path(tmp).unlink(missing_ok=True)


def quota_deadline(payload, now):
    """Fail closed on unknown usage; all exhausted windows must reset."""
    usages = payload.get("usages", {}) if isinstance(payload, dict) else {}
    if not isinstance(usages, dict):
        raise Hold("quota-response-unrecognized", now + 3600)
    deadlines = []
    for key in ("limit_5h", "limit_7d", "limit_month_total", "limit_month_code"):
        entry = usages.get(key)
        if entry is None and key.startswith("limit_month"):
            continue
        try:
            ratio = float(entry["used_ratio"])
            if not math.isfinite(ratio) or ratio < 0:
                raise ValueError()
        except (TypeError, ValueError, KeyError):
            raise Hold("quota-response-unrecognized", now + 3600) from None
        if ratio >= 1:
            try:
                reset = datetime.fromisoformat(entry["reset_time"].replace("Z", "+00:00"))
                if reset.tzinfo is None:
                    raise ValueError()
                deadlines.append(max(now + 900, reset.timestamp() + 60))
            except (ValueError, KeyError, TypeError, AttributeError):
                deadlines.append(now + 3600)
    return max(deadlines, default=0)


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, *args, **kwargs):
        return None


class Client:
    def __init__(self, home, ca_file):
        self.home = Path(home)
        self.token_file = self.home / "credentials/kimi-code.json"
        self.mutex = threading.Lock()
        self.opener = urllib.request.build_opener(
            urllib.request.ProxyHandler({}), NoRedirect(),
            urllib.request.HTTPSHandler(context=ssl.create_default_context(cafile=ca_file)),
        )

    def request(self, url, data=None, token=None, content_type=None):
        # No caller-supplied URL, redirects, proxy credentials or general tunnel.
        if url not in (AUTH, API + "/usages", API + "/chat/completions"):
            raise ValueError("endpoint denied")
        headers = {"Accept": "application/json", "User-Agent": "kimi-code-cli/2.0.2"}
        if token:
            headers["Authorization"] = "Bearer " + token
        if content_type:
            headers["Content-Type"] = content_type
        device = self.home / "device_id"
        if device.exists():
            headers["X-Msh-Device-Id"] = device.read_text().strip()
        headers.update({"X-Msh-Platform": "kimi_code_cli", "X-Msh-Version": "2.0.2"})
        try:
            return self.opener.open(urllib.request.Request(url, data, headers), timeout=60)
        except urllib.error.HTTPError as error:
            return error
        except (OSError, urllib.error.URLError):
            raise Hold("network-unavailable", time.time() + 900) from None

    def read_token(self):
        try:
            value = json.loads(self.token_file.read_text())
            if not value.get("access_token") or not value.get("refresh_token"):
                raise ValueError()
            float(value["expires_at"])
            return value
        except (OSError, ValueError, KeyError, TypeError):
            raise Hold("login-required", blocked=True) from None

    @contextlib.contextmanager
    def refresh_lock(self):
        # Match Kimi's proper-lockfile directory and heartbeat. Never steal an
        # existing lock: even a stale-looking lock might belong to a suspended
        # Kimi process. Retry later; a leftover lock needs manual inspection.
        parent = self.home / "oauth"
        parent.mkdir(mode=0o700, exist_ok=True)
        (parent / "kimi-code").touch(mode=0o600, exist_ok=True)
        lock = parent / "kimi-code.lock"
        try:
            lock.mkdir(mode=0o700)
        except FileExistsError:
            raise Hold("oauth-refresh-lock-busy", time.time() + 900) from None
        stop = threading.Event()
        compromised = threading.Event()
        inode = lock.stat().st_ino

        def heartbeat():
            while not stop.wait(1):
                try:
                    if lock.stat().st_ino != inode:
                        compromised.set()
                        return
                    os.utime(lock, None)
                except OSError:
                    compromised.set()
                    return

        thread = threading.Thread(target=heartbeat, daemon=True)
        thread.start()
        try:
            yield compromised
        finally:
            stop.set()
            thread.join()
            if lock.exists() and lock.stat().st_ino == inode:
                lock.rmdir()

    def access_token(self):
        with self.mutex:
            token = self.read_token()
            if float(token["expires_at"]) > time.time() + 120:
                return token["access_token"]
            with self.refresh_lock() as compromised:
                token = self.read_token()  # Another Kimi process may have refreshed.
                if float(token["expires_at"]) > time.time() + 120:
                    return token["access_token"]
                data = urllib.parse.urlencode({
                    "client_id": "17e5f671-d194-4dfb-9706-5516cb48c098",
                    "grant_type": "refresh_token", "refresh_token": token["refresh_token"],
                }).encode()
                with self.request(AUTH, data, content_type="application/x-www-form-urlencoded") as response:
                    if response.status in (400, 401, 403):
                        raise Hold("login-required", blocked=True)
                    if response.status != 200:
                        raise Hold("oauth-server-unavailable", time.time() + 900)
                    refreshed = json.load(response)
                try:
                    expires = float(refreshed["expires_in"])
                    if not math.isfinite(expires) or expires <= 0:
                        raise ValueError()
                    for key in ("access_token", "refresh_token"):
                        if not isinstance(refreshed[key], str) or not refreshed[key]:
                            raise ValueError()
                except (KeyError, TypeError, ValueError):
                    raise Hold("invalid-oauth-response", blocked=True) from None
                if compromised.is_set() or self.read_token() != token:
                    raise Hold("oauth-refresh-conflict", blocked=True)
                refreshed["expires_at"] = int(time.time()) + expires
                atomic_json(self.token_file, refreshed)
                return refreshed["access_token"]

    def quota_status(self):
        with self.request(API + "/usages", token=self.access_token()) as response:
            if response.status in (401, 403):
                raise Hold("login-required", blocked=True)
            if response.status != 200:
                raise Hold("quota-server-unavailable", time.time() + 900)
            try:
                payload = json.load(response)
                deadline = quota_deadline(payload, time.time())
            except (ValueError, AttributeError):
                raise Hold("quota-response-unrecognized", time.time() + 3600) from None
        if deadline:
            status = "exhausted"
        else:
            status = "available"
        windows = []
        for key, name in (("limit_5h", "five-hour"), ("limit_7d", "weekly"),
                          ("limit_month_total", "monthly-total"), ("limit_month_code", "monthly-code")):
            entry = payload["usages"].get(key)
            if entry is not None:
                windows.append({"window": name, "used_percent": round(float(entry["used_ratio"]) * 100, 2),
                                "reset_at": entry.get("reset_time")})
        return {"status": status, "windows": windows, "next_attempt": deadline,
                "checked_at": time.time()}

    def check_quota(self):
        result = self.quota_status()
        if result["status"] != "available":
            raise Hold("quota-exhausted", result["next_attempt"])
