Revision: 2

# Language support

The guidance applies to all languages. Language-specific explanations below
adapt it to their syntax and ecosystem. Supporting rules are available for
TypeScript (`.ts`, `.tsx`, `.mts`, `.cts`) through Oxlint and Python through
Pylint. The Oxlint rule also works on JavaScript when enabled for those files.
Other languages currently rely on the guidance without owned checks.

# Make failures part of the domain contract

- Before introducing an error, inspect the project's existing error model,
  project and package layers, and the callers that handle the failure. Reuse a
  meaningful domain error when one already describes the condition.

- Represent failures with a stable machine-readable identity and a useful
  human-readable message. Examples include invalid input, missing configuration,
  an unexpected exhaustive-branch value, and an internal failure exposed at a
  boundary. Choose identities for actual failure distinctions callers need; do
  not create an empty generic wrapper just to satisfy a linter.

- Keep an error definition in the lowest appropriate owning layer available to
  its producers and consumers. Shared error contracts must not import upper
  application layers. Feature-specific failures belong with their feature unless
  their meaning is truly shared. Follow the project's architecture contracts.
  When installed for its languages, read `Module layers.md` and
  `Project layers.md` to keep placement consistent with the declared dependency
  graphs.

- Use the language's idiomatic domain exception, tagged value, or result type
  and the project's established propagation mechanism. A structured error
  contract can carry a code and message without itself being throwable: use the
  existing domain exception wrapper where the runtime requires one. Do not
  replace thrown exceptions with plain records without checking callers and
  runtime behavior. The supporting rule is `no-direct-error-instantiation`,
  which rejects direct construction of the built-in `Error` in TypeScript and
  `Exception` in Python. It does not enforce stable codes, useful messages,
  correct classification, or appropriate boundary translation.

- Keep transport and user-interface translation at the boundary that owns it.
  Preserve the failure identity through lower layers so that boundary code can
  classify it. Follow the project's policy for logging internal failures,
  returning safe messages, and giving actionable feedback for recoverable cases;
  do not prescribe a framework-specific response shape in shared domain code.

# Oxlint enforcement

Merge this plugin into `oxlint.config.ts`, preserving existing plugins, file
scopes, ignores, and rules:

```ts
jsPlugins: [
  { name: "tyrant-domain-errors", specifier: "./tools/tyrant_domain_errors/oxlint/index.ts" },
],
overrides: [{
  files: ["src/**/*.{ts,tsx,mts,cts}"],
  rules: {
    "tyrant-domain-errors/no-direct-error-instantiation": "error",
  },
}],
```

# Pylint enforcement

Merge into `pyproject.toml`, preserving other plugins and enabled checks:

```toml
[tool.pylint.main]
init-hook = "import sys; from pathlib import Path; sys.path.insert(0, str(Path.cwd()))"
load-plugins = ["tools.tyrant_domain_errors.pylint"]

[tool.pylint."messages control"]
enable = [
  "no-direct-error-instantiation",
]
```

# Verification

Read the applicable configuration before changing enforcement. Run the project's
Nur-owned lint, architecture, and test tasks for the changed responsibility.
Mechanical checks establish only the constraints they implement; review the
semantic contracts and relevant callers as well.
