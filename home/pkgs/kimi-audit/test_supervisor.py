"""Offline regression tests; no credentials, quota or model tokens used."""
import io
import json
import tempfile
import unittest
import shutil
import subprocess
from pathlib import Path
from unittest.mock import patch

from host_api import Client, Hold, NoRedirect, quota_deadline
from supervisor import report_from_log, retry_deadline, tick
from tasks import create_task, control_task, notify_completion, run_tick, selected, snapshot, task_lock, task_status


class QuotaTests(unittest.TestCase):
    def payload(self, short=0.1, week=0.2):
        return {"usages": {
            "limit_5h": {"used_ratio": short, "reset_time": "2026-10-03T12:00:00Z"},
            "limit_7d": {"used_ratio": week, "reset_time": "2026-10-07T12:00:00Z"},
        }}

    def test_both_windows_must_reset(self):
        from datetime import datetime
        expected = datetime.fromisoformat("2026-10-07T12:00:00+00:00").timestamp() + 60
        self.assertEqual(quota_deadline(self.payload(1, "1"), 100), expected)

    def test_available(self):
        self.assertEqual(quota_deadline(self.payload(), 100), 0)

    def test_unknown_usage_fails_closed(self):
        for payload in ({}, {"usages": {}}, self.payload(float("nan")), self.payload(-1)):
            with self.assertRaises(Hold):
                quota_deadline(payload, 100)

    def test_monthly_limit_and_missing_reset(self):
        payload = self.payload()
        payload["usages"]["limit_month_code"] = {"used_ratio": 1}
        self.assertEqual(quota_deadline(payload, 100), 3700)

    def test_retry_after(self):
        self.assertEqual(retry_deadline("7200", 100), 7300)
        self.assertEqual(retry_deadline(None, 100), 3700)
        self.assertEqual(retry_deadline("-1", 100), 1000)

    def test_redirects_never_forward_credentials(self):
        self.assertIsNone(NoRedirect().redirect_request(None, None, 302, "", {}, "https://example.org"))

    def test_quota_status_preserves_percentages_when_exhausted(self):
        response = io.BytesIO(json.dumps(self.payload(0.25, 1)).encode())
        response.status = 200
        with tempfile.TemporaryDirectory() as home:
            client = Client(home, None)
            with patch.object(client, "access_token", return_value="fake"), patch.object(client, "request", return_value=response):
                result = client.quota_status()
        self.assertEqual(result["status"], "exhausted")
        self.assertEqual([w["used_percent"] for w in result["windows"]], [25, 100])


class ProjectTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.base = Path(self.tmp.name)
        self.root = self.base / "state"
        self.root.mkdir()
        self.project = self.base / "project with spaces"
        self.project.mkdir()
        (self.project / "main.py").write_text("print('source')")
        self.runtime = {"scripts": str(Path(__file__).parent), "bins": {"git": shutil.which("git")}}

    def test_snapshot_never_follows_symlinks_or_includes_dotenv(self):
        secret = self.base / "secret"
        secret.write_text("PRIVATE")
        (self.project / "leak").symlink_to(secret)
        (self.project / "outside").symlink_to(self.base, target_is_directory=True)
        (self.project / ".env").write_text("KEY=PRIVATE")
        manifest = snapshot(self.project, self.base / "copy", self.runtime["bins"]["git"], True)
        self.assertEqual([f["path"] for f in manifest["files"]], ["main.py"])
        self.assertFalse((self.base / "copy/leak").exists())
        self.assertFalse((self.base / "copy/.env").exists())

    def test_git_snapshot_uses_tracked_working_tree_only(self):
        git = self.runtime["bins"]["git"]
        subprocess.run([git, "init", "-q", str(self.project)], check=True)
        subprocess.run([git, "-C", str(self.project), "add", "main.py"], check=True)
        (self.project / "main.py").write_text("updated working tree")
        (self.project / "private.txt").write_text("untracked")
        snapshot(self.project, self.base / "copy", git)
        self.assertEqual((self.base / "copy/main.py").read_text(), "updated working tree")
        self.assertFalse((self.base / "copy/private.txt").exists())

    def test_one_task_at_a_time_and_cancel_preserves_previous_data(self):
        first = create_task(self.runtime, self.root, self.project, True)
        with self.assertRaises(ValueError):
            create_task(self.runtime, self.root, self.project, True)
        control_task(self.root, "cancel")
        second = create_task(self.runtime, self.root, self.project, True)
        self.assertNotEqual(first["id"], second["id"])
        self.assertTrue(Path(first["directory"], "source/main.py").exists())

    def test_paused_task_does_not_invoke_supervisor(self):
        create_task(self.runtime, self.root, self.project, True)
        control_task(self.root, "pause")
        with patch("tasks.tick") as invoke:
            self.assertEqual(run_tick(self.runtime, self.root)["status"], "paused")
            invoke.assert_not_called()
        self.assertEqual(control_task(self.root, "resume")["status"], "waiting")

    def test_snapshot_stays_stable_when_project_changes(self):
        create_task(self.runtime, self.root, self.project, True)
        (self.project / "main.py").write_text("changed")
        self.assertEqual((selected(self.root) / "source/main.py").read_text(), "print('source')")

    def test_failed_snapshot_does_not_replace_current_task(self):
        first = create_task(self.runtime, self.root, self.project, True)
        control_task(self.root, "cancel")
        empty = self.base / "empty"
        empty.mkdir()
        with self.assertRaises(ValueError):
            create_task(self.runtime, self.root, empty, True)
        self.assertEqual(task_status(selected(self.root))["id"], first["id"])

    def test_global_lock_prevents_overlapping_execution(self):
        with task_lock(self.root):
            with self.assertRaises(ValueError):
                with task_lock(self.root):
                    self.fail("must not enter")


class NotificationTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.job = self.root / "jobs/123456abcdef"
        self.job.mkdir(parents=True)
        (self.job / "status.json").write_text('{"status":"complete"}')
        (self.job / "task.json").write_text('{"project":"/tmp/example<&>"}')
        (self.job / "REPORT.md").write_text("report")
        self.runtime = {"notifySend": "/fake/notify-send"}

    def test_success_notifies_once_across_ticks_without_selected_task(self):
        with patch("tasks.subprocess.run", return_value=subprocess.CompletedProcess([], 0)) as send:
            run_tick(self.runtime, self.root)
            run_tick(self.runtime, self.root)
            self.assertEqual(send.call_count, 1)
            body = send.call_args.args[0][-1]
            self.assertIn("example&lt;&amp;&gt;", body)
            self.assertIn((self.job / "REPORT.md").as_uri(), body)
            self.assertEqual(json.loads((self.job / "notification.json").read_text())["status"], "sent")

    def test_failed_delivery_retries_after_delay(self):
        with patch("tasks.time.time", return_value=1000), patch("tasks.subprocess.run", return_value=subprocess.CompletedProcess([], 1)) as send:
            notify_completion(self.runtime, self.job)
            notify_completion(self.runtime, self.job)
            self.assertEqual(send.call_count, 1)
        with patch("tasks.time.time", return_value=2000), patch("tasks.subprocess.run", return_value=subprocess.CompletedProcess([], 0)) as send:
            notify_completion(self.runtime, self.job)
            self.assertEqual(send.call_count, 1)

    def test_ambiguous_delivery_is_not_repeated(self):
        with patch("tasks.subprocess.run", side_effect=subprocess.TimeoutExpired("notify-send", 10)) as send:
            notify_completion(self.runtime, self.job)
            notify_completion(self.runtime, self.job)
            self.assertEqual(send.call_count, 1)
        (self.job / "notification.json").write_text('{"status":"sending"}')
        with patch("tasks.subprocess.run") as send:
            notify_completion(self.runtime, self.job)
            send.assert_not_called()

    def test_no_notification_for_unfinished_cancelled_or_missing_report(self):
        with patch("tasks.subprocess.run") as send:
            for status in ("waiting", "running", "paused", "blocked", "cancelled"):
                (self.job / "status.json").write_text(json.dumps({"status": status}))
                notify_completion(self.runtime, self.job)
            (self.job / "status.json").write_text('{"status":"complete"}')
            (self.job / "REPORT.md").unlink()
            notify_completion(self.runtime, self.job)
            send.assert_not_called()


class CheckpointTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        (self.root / "prompt.txt").write_text("test")
        self.runtime = {"source": "/src", "scripts": str(self.root),
                        "credentialsHome": str(self.root), "caFile": None}

    def test_only_final_assistant_with_completion_counts(self):
        log = self.root / "log"
        hint = {"type": "session.resume_hint"}
        for role in ("tool", "meta", "assistant"):
            event = {"role": role, "content": "Report\nAUDIT_COMPLETE"}
            log.write_text(json.dumps(event) + "\n" + json.dumps(hint))
            self.assertEqual(report_from_log(log), "Report\n" if role == "assistant" else None)
        log.write_text(json.dumps({"role": "assistant", "content": "Report\nAUDIT_COMPLETE"}))
        self.assertIsNone(report_from_log(log))

    def test_completed_waiting_and_blocked_do_not_query_quota(self):
        for checkpoint in ({"status": "complete"}, {"next_attempt": 9e12},
                           {"status": "blocked", "reason": "kimi-exit-1"}):
            with patch("supervisor.Client") as client:
                tick(self.runtime, self.root, checkpoint, False)
                client.return_value.check_quota.assert_not_called()

    def test_quota_failure_prevents_agent_launch(self):
        with patch("supervisor.Client") as client, patch("supervisor.invoke") as invoke:
            client.return_value.check_quota.side_effect = Hold("quota-exhausted", 9999)
            with self.assertRaises(Hold):
                tick(self.runtime, self.root, {}, False)
            invoke.assert_not_called()

    def test_successful_completion_stops_future_runs(self):
        checkpoint = {}
        with patch("supervisor.Client") as client, patch("supervisor.invoke", return_value="Report\n") as invoke:
            client.return_value.token_file = self.root / "absent-token"
            tick(self.runtime, self.root, checkpoint, False)
            tick(self.runtime, self.root, checkpoint, False)
            self.assertEqual(invoke.call_count, 1)
            self.assertEqual(checkpoint["status"], "complete")
            self.assertEqual((self.root / "REPORT.md").read_text(), "Report\n")

    def test_oauth_refresh_is_private_and_releases_native_lock(self):
        (self.root / "credentials").mkdir()
        token = self.root / "credentials/kimi-code.json"
        token.write_text(json.dumps({"access_token": "old", "refresh_token": "refresh", "expires_at": 0}))
        response = io.BytesIO(json.dumps({"access_token": "new", "refresh_token": "rotated", "expires_in": 3600}).encode())
        response.status = 200
        client = Client(self.root, None)
        with patch.object(client, "request", return_value=response):
            self.assertEqual(client.access_token(), "new")
        self.assertEqual(token.stat().st_mode & 0o777, 0o600)
        self.assertFalse((self.root / "oauth/kimi-code.lock").exists())
        self.assertEqual(json.loads(token.read_text())["refresh_token"], "rotated")

    def test_existing_native_refresh_lock_is_not_stolen(self):
        lock = self.root / "oauth/kimi-code.lock"
        lock.mkdir(parents=True)
        with self.assertRaises(Hold):
            with Client(self.root, None).refresh_lock():
                self.fail("must not enter")
        self.assertTrue(lock.is_dir())


if __name__ == "__main__":
    unittest.main()
