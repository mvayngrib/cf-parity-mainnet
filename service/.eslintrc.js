module.exports = {
  "env": {
    "browser": true,
    "commonjs": true,
    "es6": true,
    "node": true
  },
  "parserOptions": {
    "sourceType": "module",
    "ecmaVersion": 9,
  },
  "extends": "eslint:recommended",
  "rules": {
    "no-trailing-commas": "off",
    "indent": [
      "warn",
      2
    ],
    "linebreak-style": [
      "error",
      "unix"
    ],
    "quotes": [
      "warn",
      "single"
    ],
    "semi": [
      "warn",
      "never"
    ]
  }
};
