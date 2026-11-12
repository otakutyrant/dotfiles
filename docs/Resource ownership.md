Revision: 1

# Language support

The guidance applies to all languages. Language-specific explanations below
adapt it to their syntax and ecosystem. Supporting rules are available for
TypeScript (`.ts`, `.tsx`, `.mts`, `.cts`) through Oxlint and Python through
Pylint. The Oxlint rule also works on JavaScript when enabled for those files.
Other languages currently rely on the guidance without owned checks.

# Give each resource one owner

Treat direct access to a database model, filesystem area, remote API, queue, or
other external mechanism as an owned capability. Identify the lowest coherent
module that can own its operations and keep mechanism-specific behavior there.

- Let the owner access the resource directly and expose operations in domain
  terms.

- Where practical, order functions in each resource interface implementation by
  CRUD responsibility: create, read, update, then delete.

- Require other production modules to call those operations instead of reaching
  through the owner to the underlying client or delegate. The supporting rule is
  `enforce-resource-owner-access`, which reports configured expressions such as
  `database.user` outside their configured owner paths and exceptions.

- Allow integration tests to access resources directly when preparing test data
  or verifying effects.

- Treat generated types, schemas, and enum values as data definitions rather
  than resource operations unless using them performs external work.

- Place shared ownership contracts low enough for producers and consumers
  without introducing an upward dependency.

Do not infer ownership from the current distribution of calls. Read the
project's declared ownership and architecture first. When no owner exists,
choose one from responsibility and dependency direction before configuring a
mechanical restriction.

# Oxlint enforcement

Merge this plugin into `oxlint.config.ts`, preserving existing plugins, file
scopes, ignores, and rules:

```ts
jsPlugins: [
  { name: "tyrant-resource-ownership", specifier: "./tools/tyrant_resource_ownership/oxlint/index.ts" },
],
overrides: [{
  files: ["src/**/*.{ts,tsx,mts,cts}"],
  rules: {
    "tyrant-resource-ownership/enforce-resource-owner-access": ["error", { rootDir: ".", resources: [{ access: "client.resource", allowedPaths: ["src/resource-owner/**"] }] }],
  },
}],
```

Replace the example resource expression and owner paths with actual ownership.
Add test exceptions only for suites that need direct access; configure every
governed resource.

# Pylint enforcement

Merge into `pyproject.toml`, preserving other plugins and enabled checks:

```toml
[tool.pylint.main]
init-hook = "import sys; from pathlib import Path; sys.path.insert(0, str(Path.cwd()))"
load-plugins = ["tools.tyrant_resource_ownership.pylint"]

[tool.pylint."messages control"]
enable = [
  "enforce-resource-owner-access",
  "invalid-resource-owner-config",
]
```

## Configure resource owners

Add the owner configuration to `pyproject.toml`:

```toml
[tool.pylint.tyrant-resource-ownership]
tyrant-resource-root = "."
tyrant-resource-owners = '[{"access":"database.user","allowedPaths":["services/user/**","**/*_integration_test.py"]}]'
```

Paths are relative to `tyrant-resource-root`, resolved from the invocation
working directory. Allowed paths support exact paths, directory prefixes ending
in `/**`, and filename suffix patterns starting with `**/*`, matching the Oxlint
rule. Configure actual resource expressions and justified test exceptions. The
checker recognizes attribute access and constant string subscripts, such as
`database.user` and `database["user"]`. It does not track aliases, dynamic keys,
or infer resource identity. Malformed configuration produces a diagnostic.

# Verification

Read the applicable configuration before changing enforcement. Run the project's
Nur-owned lint, architecture, and test tasks for the changed responsibility.
Mechanical checks establish only the constraints they implement; review the
semantic contracts and relevant callers as well.
