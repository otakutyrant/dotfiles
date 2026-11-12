Revision: 1

# Scope and graph ownership

Treat the modules directly contained in a directory as a dependency graph.
Declare that graph in the directory's exact entry file.

A module may be a file or a directory with its own entry file. The parent's
entry places a child directory in the parent graph; the child's entry governs
the modules inside it. Inspect every affected graph when a change crosses a
directory boundary. A file module and directory module with the same basename
are mutually exclusive.

# Define module roles

The graph has three roles:

- A shared module provides foundations independent of features. It may depend
  only on shared modules in the same directory and forms the lowest layer.

- A feature module provides a coherent capability built from lower capabilities.
  Every feature module belongs to exactly one layer. Declare a TypeScript or
  Python layer with `@layer`, listing one module or several peer modules. It may
  depend on its own layer, lower feature layers, and shared modules in the same
  directory.

- An entry module is the directory's exact entry file. It composes the
  directory's capabilities and may depend on feature and shared modules in the
  same directory. It forms the highest layer and declares the feature-layer
  order in its documentation. It is the declaration site, not necessarily a
  barrel file: lower modules remain directly importable by outside modules
  whenever the layer graph permits that import, and the entry file need not
  gather and re-export every lower-layer identity. Barrel files are banned in
  Tyrant conventions.

Classify extracted types and definitions by their responsibility and
dependencies, not their filename. Feature-independent foundations may be shared
modules; feature-specific contracts may instead own a lower feature layer. Give
these production modules ordinary names and their own layer assignments rather
than inheriting a feature's layer through names such as `user.types.ts` or
`user.definitions.ts`.

# Declare feature layers in the entry file

In the entry file's leading documentation, declare every feature module exactly
once, from lowest to highest. Give each declaration a short relationship
description that explains what the layer provides and why grouped modules are
peers. Shared modules and the entry module are not declared.

For example:

```text
@layer materials.ts - Provides the core data.
@layer paragraphs.ts, lexicons.ts - Derive peer views from materials.
@layer metrics.ts - Aggregates the derived views.
```

Keep the declarations consistent with the modules and their imports. Declaration
order changes dependency permissions; do not alphabetize layers. Modules within
one declaration are peers, but dependency cycles remain forbidden.

# Handle modules with the same filename-stem prefix

An inherited file is a same-directory test file whose first dotted filename
component matches another file module. Recognized test suffixes are `.test`,
`.spec`, `.unit`, `.orchestration`, `.integration`, `.performance`, and
`.benchmark` before a TypeScript extension. It inherits the layer of that
matching module, whether the module is shared, feature, or entry. For example,
`user.unit.test.ts` is an inherited file when `user.ts` exists, and it belongs
to `user.ts`'s layer. Likewise, `index.test.ts` belongs to the entry layer of
`index.ts`.

The inherited file remains a separately importable source module with its own
imports and exports. Only its layer assignment is inherited: do not add the file
to the entry-file declaration. A suffix such as `.unit.test` does not create
another layer or a sub-group beneath `user`; for example, `user.unit.test.ts`
and `user.integration.test.ts` both use `user.ts`'s layer. Each inherited file
has the same dependency permissions as that layer, including permission to
import `user.ts` and other modules in the same or a lower layer. Only the exact
entry file has the entry role.

Filename-prefix inheritance applies to TypeScript. Python v1 supports ordinary
importable filenames only, not dotted test names or namespace children; keep
such tests outside contracted package roots.

Prefix inheritance applies only to recognized test siblings with an existing
base file. Production files such as `user.types.ts`, `user.definitions.ts`, and
`index.types.ts` require their own exact shared configuration or `@layer`
declaration. Shared configuration does not implicitly match other production
files by prefix. A test without a base also requires an explicit assignment.

# Programming language specifications

Apply this convention only to the languages listed below.

| Language   | Exact entry file                       | Documentation style            |
| ---------- | -------------------------------------- | ------------------------------ |
| TypeScript | `index.ts` (or `.tsx`, `.mts`, `.cts`) | Leading TSDoc block comment    |
| Python     | `__init__.py`                          | Docstring                      |
| Nushell    | `mod.nu`                               | Leading multiple line comments |
| Nix        | `default.nix`                          | Leading block comment          |

# Enforce the declared architecture

For TypeScript and Python, use Layerer with the native dependency engine as
described below.

Before implementation, place each responsibility in its intended layer and check
all ancestor contracts. Update declarations with module moves. If a check fails,
reconsider ownership or a genuine architecture change before changing
permissions. Do not infer a new layer order from existing violations.

Run the project's architecture command after source or declaration changes.
Verify that every contracted root and unimported module is analyzed, and keep
cycle detection separate from downward-edge permissions. Probe valid, forbidden,
and malformed declarations when setting up or materially changing enforcement.
Nix uses the documented convention and project checks; no Layerer adapter exists
for Nix. Do not claim executable coverage where no checker is configured.

# TypeScript package contracts with Layerer

Layerer owns the adapter, while dependency-cruiser resolves imports. Read the
selected Layerer checkout's README and manifest before installing; the current
package is local and unpublished and needs Node 22.18+. Build it through its own
Nur catalog before adding its TypeScript directory as a file dependency. For
sibling checkouts, from the consumer:

```nu
pnpm add -D dependency-cruiser @tyrant/package-layers@file:../layerer/typescript
```

Merge into the existing dependency-cruiser TypeScript configuration:

```ts
import {
  readPackageLayers,
  generatePackageLayerRules,
} from "@tyrant/package-layers";

const packages = readPackageLayers({
  projectRoot: import.meta.dirname,
  roots: ["src"],
  sharedModules: ["constants.ts", "types.ts"],
});

export default {
  forbidden: [
    { name: "no-cycles", severity: "error", from: {}, to: { circular: true } },
    ...generatePackageLayerRules(packages),
  ],
  options: { tsPreCompilationDeps: true },
};
```

Replace roots and shared names with actual responsibilities. Preserve existing
project-layer rules, unresolved-import rules, resolver options, aliases, and
cycle checks. Source the check from every contracted root and standalone
entrypoint, including unimported files; generated rules do not expand the
analyzed graph. Keep generated/dependency trees outside the contracted roots or
explicitly excluded. Layerer exclusions are exact project-relative
paths/subtrees, not globs.

Use leading TSDoc in exact `index.ts`, `.tsx`, `.mts`, or `.cts` entries.
Register `@layer` as a repeatable custom block tag in `tsdoc.json` when TSDoc is
checked. Declare literal immediate filenames or directory names, lowest first,
with relationship descriptions. Shared names are configured separately; the
exact entry is implicit highest. Recognized test siblings inherit their existing
first-component base file's layer by default. Production dotted filenames
require exact layer declarations or exact shared-module configuration; they do
not inherit by prefix. Nested modules also obey every ancestor contract.

Missing, stale, duplicate, ambiguous, malformed, and legacy declarations must
fail. Do not suppress entry tests wholesale: inherited entry siblings have the
entry layer's permissions. Same-layer imports do not permit dependency cycles.

Use disposable fixtures to prove downward/peer imports pass, upward imports
fail, and malformed declarations fail before graph validation. Run the
consumer's normal dependency-cruiser command after edits. When Layerer itself
changes, rebuild it and reinstall the consumer's file dependency before
rechecking.

# Python package contracts with Layerer

Use Layerer's Python adapter with native Import Linter; Python consumers need no
Node installation. Read the selected checkout's README and Python manifest
before installing. The current adapter is local and unpublished and needs Python
3.13+. For sibling checkouts, from the consumer:

```nu
uv add --dev --editable ../layerer/python
```

Merge actual package roots into `pyproject.toml`:

```toml
[tool.layerer]
shared-modules = ["constants.py", "errors.py", "types.py"]
cycles = true
packages = [{ path = "src/my_package", name = "my_package" }]
```

Paths are relative to the configuration file. Mapping roots must not overlap.
Use explicit import names for mapped/plugin namespaces. `exclude`, when needed,
contains exact project-relative paths/subtrees rather than globs; excluded
source is absent from analysis. Do not use exclusions to hide violations.

Put ordered `@layer` declarations in each package's actual `__init__.py`
docstring. Name immediate ordinary `.py` files or regular child packages, lowest
first, with relationship descriptions. Shared names match exactly and are
configured separately. The entry is implicit highest, and nested modules obey
all ancestor contracts. Python v1 does not support dotted filenames or namespace
children; keep dotted tests outside contracted package roots.

Run all configured roots with `uv run layerer check --config pyproject.toml`.
Repeat `--package import_name` only when intentionally selecting configured
roots. Wire the all-roots check into normal validation and CI. Preserve
independent project-wide Import Linter contracts; Layerer does not infer those
policies.

Cycles default to false; enable them deliberately as above when this check owns
cycle enforcement. Native acyclic-sibling contracts can reject a cycle between
collapsed sibling packages even without an individual-file cycle.

Probe downward and peer imports, forbidden upward imports, malformed/stale tags,
and an ancestor boundary. Use the real command and check its failure status.
Input/execution errors exit 2; broken contracts propagate the engine status.
Layerer parses source without importing application initializers; never replace
that analysis with runtime imports. Computed imports unresolved by the native
engine remain outside the guarantee.

# Nushell enforcement limits

The custom Rust checker source is retained by project-agents-md, with its MIT
license, pending a released CLI and LSP extension interface. It is not installed
into projects or claimed as active enforcement.

Use the project's pinned stock upstream `nu-lint`, inspect `nu-lint --list` and
`nu-lint rules`, and configure only IDs it actually provides. Do not substitute
a fork or claim the parked rules ran. Apply the layer guidance directly and run
the available upstream checks with error severity for required constraints.

Before enabling these assets in the future, verify a released extension
interface works in both CLI and LSP, adapt registration without patching
upstream core, and probe valid and violating source through the real consumer
command.

The retained package checker uses `@layer` in leading `mod.nu` comments. It has
no configured shared modules or dotted-prefix inheritance, and is not a
replacement for Layerer in TypeScript or Python. Preserve these limits rather
than claiming it implements all languages' layer policies.

# Verification

Read the applicable configuration before changing enforcement. Run the project's
Nur-owned lint, architecture, and test tasks for the changed responsibility.
Mechanical checks establish only the constraints they implement; review the
semantic contracts and relevant callers as well.
