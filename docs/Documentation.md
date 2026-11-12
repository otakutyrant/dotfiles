Revision: 2

# Language support

The guidance applies to all languages. Language-specific explanations below
adapt it to their syntax and ecosystem. Supporting rules are available for
TypeScript (`.ts`, `.tsx`, `.mts`, `.cts`) through Oxlint and Python through
Pylint. Other languages currently rely on the guidance without owned checks.

# Document roles and contracts

Apply this convention in any language, using the project's documentation syntax
and configured tag vocabulary.

- Start each source file with documentation explaining its responsibility. For
  an infrastructure adapter, name the external systems or mechanisms it owns.
  The supporting rule is `require-file-doc`.

- Separate file documentation from the following code with a blank line. The
  supporting rule is `require-empty-line-after-file-doc`.

- Document public declarations. Explain meaningful inputs, outputs, side
  effects, invariants, failures, authorization, and fallback behavior where
  applicable. Avoid comments that only repeat a declaration's name or type. The
  supporting rule is `require-doc-for-public-api`, which checks TypeScript
  exports and public Python classes, functions, and methods.

- Documentation for private declarations is not required by default. Private
  implementation details are expected to change, remain confined to their owning
  file, and fall outside the user's routine review scope. If the user needs to
  review those details, they may request documentation. When requested, document
  the relevant private declarations using the same contract guidance as public
  declarations.

- Use supported behavioral tags when they clarify a real contract. Follow the
  project's tag order and grouping; do not invent tags or fill every tag with
  boilerplate. Package layer tags must explain dependency relationships. The
  supporting rule is `enforce-doc-tag-order`: Oxlint checks tag order and
  blank-line groups from the nearest `tsdoc.json`; Pylint checks its configured
  tag order without checking groups.

- When documentation has one short content line, put the text and its delimiters
  on one source line: `/** Summary. */` in TypeScript or `"""Summary."""` in
  Python. Use the multiline form when the documentation has multiple content
  lines or exceeds the rule's single-line length limit. The supporting rule is
  `prefer-single-line-doc`.

## Comment syntax

- In TypeScript, use TSDoc block comments (`/** ... */`) for file documentation
  and public declaration documentation. Read `tsdoc.json` for supported tags.

- In Python, use docstrings for file documentation and public declaration
  documentation. Read the configured doc-tag order if present.

- In other languages, use normal block comments for file documentation and
  public declaration documentation. If the language has no block comments, use
  its native documentation syntax.

- Use line comments for local implementation notes and other ordinary comments
  in every language, including comments spanning multiple lines: prefix each
  line with the language's line-comment marker. If a language has no line
  comments, use its native comment syntax. The supporting rule is
  `require-line-comments`: it rejects ordinary TypeScript `/* ... */` comments
  and Python standalone strings used as comments, while allowing documentation
  and strings used as data. It has no autofix because moving an inline comment
  can change code behavior.

## Automatic fixes

Oxlint can fix `require-empty-line-after-file-doc`, `prefer-single-line-doc`,
and `enforce-doc-tag-order` through `--fix`. Pylint checks remain read-only; the
installed `fix_documentation` Python companion fixes the same three rules. The
narrower `fix_doc_tag_order` companion fixes tag ordering only. See Python
enforcement below for preview and `--write` commands. The fixers preserve tag
continuation lines and leave ambiguous string literals or docstrings sharing a
line with code for manual repair. Other rules report without fixing.

# Oxlint enforcement

Merge this plugin into `oxlint.config.ts`, preserving existing plugins, file
scopes, ignores, and rules:

```ts
jsPlugins: [
  { name: "tyrant-documentation", specifier: "./tools/tyrant_documentation/oxlint/index.ts" },
],
overrides: [{
  files: ["src/**/*.{ts,tsx,mts,cts}"],
  rules: {
    "tyrant-documentation/require-file-doc": "error",
    "tyrant-documentation/require-empty-line-after-file-doc": "error",
    "tyrant-documentation/require-doc-for-public-api": "error",
    "tyrant-documentation/prefer-single-line-doc": "error",
    "tyrant-documentation/enforce-doc-tag-order": "error",
    "tyrant-documentation/require-line-comments": "error",
  },
}],
```

Read `tsdoc.json` and preserve its `supportForTags` order and grouping. Register
architecture tags separately when applicable.

# Pylint enforcement

Documentation checks read the source stream analyzed by Pylint, including
`--from-stdin` content for unsaved buffers and files that do not yet exist on
disk. They do not substitute the saved file for the supplied source.

Merge into `pyproject.toml`, preserving other plugins and enabled checks:

```toml
[tool.pylint.main]
init-hook = "import sys; from pathlib import Path; sys.path.insert(0, str(Path.cwd()))"
load-plugins = ["tools.tyrant_documentation.pylint"]

[tool.pylint."messages control"]
enable = [
  "require-file-doc",
  "require-empty-line-after-file-doc",
  "require-doc-for-public-api",
  "prefer-single-line-doc",
  "enforce-doc-tag-order",
  "require-line-comments",
]

[tool.pylint.tyrant-doc-tag-order]
tyrant-doc-tag-order = ["@remarks", "@param", "@returns"]
```

Tags use `@tag - value` docstring lines; replace the example order with the
project vocabulary.

## Fix documentation formatting

The installed `fix_documentation` companion fixes
`require-empty-line-after-file-doc`, `prefer-single-line-doc`, and
`enforce-doc-tag-order`. Preview or apply changes from the project root:

```nu
uv run python -m tools.tyrant_documentation.pylint.fix_documentation src/module.py
uv run python -m tools.tyrant_documentation.pylint.fix_documentation --write src/module.py
```

It adds an empty line after module documentation and compacts short docstrings
onto one source line, preserving their quote style and prefix. It reads tag
order from `pyproject.toml`; if no order is configured, it still fixes spacing
and compact form. It does not invent missing documentation or modify string
data. Escaped or concatenated literals and docstrings sharing a line with code
may need manual repair. Preview and exit-status behavior match the narrower
tag-order command below. Pylint itself continues to report without editing.

## Fix doc-tag order only

Pylint does not apply source fixes. The installed companion module fixes
`enforce-doc-tag-order` explicitly, reading the same `tyrant-doc-tag-order`
setting from the project's `pyproject.toml`. Run from the project root:

```nu
uv run python -m tools.tyrant_documentation.pylint.fix_doc_tag_order src/module.py
uv run python -m tools.tyrant_documentation.pylint.fix_doc_tag_order --write src/module.py
```

The first command reports files that would change and exits nonzero without
writing. The second applies fixes. Pass multiple explicit file paths as needed;
use `--config path/to/pyproject.toml` to select another TOML configuration. The
order may be a TOML list or a comma-separated string, as in Pylint.

The fixer sorts configured tag blocks stably, carrying continuation lines with
their tags and keeping unknown tag blocks in their existing slots. It preserves
source outside docstring literals, encoding, quote style, and line endings.
Escaped or concatenated literals requiring changes are reported for manual
repair rather than rewritten. A nonzero exit status after `--write` means some
docstrings still need repair; successfully applied fixes remain in place. It
does not add tags, impose blank-line groups, or fix other Pylint diagnostics.
Run Pylint again after applying fixes.

# Verification

Read the applicable configuration before changing enforcement. Run the project's
Nur-owned lint, architecture, and test tasks for the changed responsibility.
Mechanical checks establish only the constraints they implement; review the
semantic contracts and relevant callers as well.
