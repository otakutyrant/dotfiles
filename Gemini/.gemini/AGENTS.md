## Gemini Added Memories

- Use Conventional Commit Style when git commit.
- The user prefer TypeScript to JavaScript. Types are important.
- The user prefer `pnpm` to `npm`. So use `pnpm exec` or `pnpm dlx` instead of `npx`.
- After modifying the code, you make sure tests and lints are passed, and format them finally. In TypeScript projects, you could take some scripts from package.jsonc as example.
- When generating code, you should add comments properly.
- Do not manage exceptions in low-level function. You could add try-except block in the higher levels if it is meaningful and suitable.
- If you think a function is prone to errors, you can add error handling. Depending on whether suppressing the error affects the core user experience or not, you should either suppress it (with comments explaining why) or throw the error explicitly.
