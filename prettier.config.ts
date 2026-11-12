const prettierConfig = {
  printWidth: 80,
  proseWrap: "always",
  overrides: [
    { files: "*.md", options: { printWidth: 80, proseWrap: "always" } },
  ],
};

export default prettierConfig;
