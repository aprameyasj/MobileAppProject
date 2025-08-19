module.exports = {
  root: true,
  env: {
    es6: true,
    node: true,
  },
  extends: [
    "eslint:recommended"
  ],
  parserOptions: {
    sourceType: "module",
    ecmaVersion: 2020,
  },
  ignorePatterns: [
    "/lib/**/*", // Ignore built files.
  ],
  rules: {
    quotes: ["error", "double"],
    "object-curly-spacing": ["error", "never"],
  },
};
