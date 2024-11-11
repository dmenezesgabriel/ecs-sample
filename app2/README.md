# Fastify API

## Setup

### Dependencies

```sh
npm init -y && \
npm i -D typescript @types/node tsx vitest @vitest/coverage-v8 supertest @types/supertest tsup && \
npx tsc --init && \  # Init typescript config
npm i fastify @fastify/cookie dotenv zod && \
touch vitest.config.ts
```

### Linters and formatters

```sh
npm install --save-dev --save-exact prettier && \
npm install --save-dev eslint-config-prettier && \
node --eval "fs.writeFileSync('.prettierrc','{}\n')" && \
node --eval "fs.writeFileSync('.prettierignore','# Ignore artifacts:\nbuild\ncoverage\n')" && \
npm init @eslint/config@latest
```

### Configuration files

```json
// tsconfig.json
{ "target": "es2020" }


// set target to es2020
```

```json
// package.json
{
  "scripts": {
    "dev": "tsx watch src/server.ts",
    "build": "tsup src",
    "test": "vitest",
    "test:ci": "vitest run --coverage"
  }
}
```

```js
// eslint.config.mjs
import eslintConfigPrettier from "eslint-config-prettier";

export default [
  // Other configuration
  eslintConfigPrettier,
];
```
