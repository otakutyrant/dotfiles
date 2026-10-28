# Project workspace instructions

## Route work to the owning repository

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

## Install a Codex skill

When a reusable workflow belongs in a skill, create or update its directory and
`SKILL.md` in `~/Projects/tyrant-skills`, validate it with the skill creator's
validator, and update that repository's README when it is user-facing. Commit
and push `tyrant-skills` first so the dotfiles flake can consume a published
revision. Then declare the skill in `dotfiles/home/options/programs/codex.nix`,
update the pinned `tyrant-skills` flake input, and run the requested
`nh home switch` from `~/Projects/dotfiles`. Verify the installed symlink and
skill metadata after activation; record any durable workflow improvement here.
