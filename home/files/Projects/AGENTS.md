Use `~/Projects` as the shared entry point and route each task to the narrowest
owning repository. Set that repository as the working directory before doing
project work so commands and instructions have the correct scope.

Before working in a user-owned repository, read its complete `AGENTS.md` when
one is present. Treat repository-local instructions as supplements to this file
and preserve unrelated worktree changes throughout the task.

When subagents are explicitly requested or otherwise permitted, assign each
subagent one repository-scoped task and direct it to work from that repository's
root. Never allow multiple agents to edit the same files, so parallel work
remains isolated and reviewable.
