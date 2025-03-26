// eslint.config.js

import js from '@eslint/js'
import tseslint from '@typescript-eslint/eslint-plugin'
import prettier from 'eslint-plugin-prettier'
import node from 'eslint-plugin-n'
import mocha from 'eslint-plugin-mocha'
import jest from 'eslint-plugin-jest'
import globals from 'globals'
import tsParser from '@typescript-eslint/parser'

export default [
  js.configs.recommended,
  {
    files: ['**/*.ts', '**/*.tsx', '**/*.spec.ts', '**/*.test.ts'],
    languageOptions: {
      parser: tsParser,
      ecmaVersion: 12,
      globals: {
        ethers: 'readonly',
        // console, require, etc
        ...globals.node,
        //Jest
        ...globals.jest,
      },
    },
    plugins: {
      '@typescript-eslint': tseslint,
      prettier,
      node,
      mocha,
      jest,
    },
    rules: {
      'no-useless-constructor': 'off',
      'no-unused-expressions': 'off',
      'no-plusplus': 'off',
      'prefer-destructuring': 'off',
      'mocha/no-exclusive-tests': 'error',
      'no-multiple-empty-lines': ['error', { max: 1, maxEOF: 0, maxBOF: 0 }],
      'node/no-unsupported-features/es-syntax': [
        'error',
        { ignores: ['modules'] },
      ],
      'node/no-missing-import': [
        'error',
        {
          allowModules: [],
          tryExtensions: ['.js', '.json', '.node', '.ts', '.d.ts'],
        },
      ],
      'node/no-missing-require': [
        'error',
        {
          allowModules: [],
          tryExtensions: ['.js', '.json', '.node', '.ts', '.d.ts'],
        },
      ],
      camelcase: 'off',
      //Jest rules
      'jest/no-disabled-tests': 'warn',
      'jest/no-focused-tests': 'error',
      'jest/no-identical-title': 'error',
      'jest/prefer-to-have-length': 'warn',
      'jest/valid-expect': 'error',
    },
  },
  {
    ignores: [
      'node_modules',
      'artifacts',
      'cache',
      'coverage',
      'typechain-types',
      'dist',
      'templates',
      '*.spec.ts',
      'build',
      'lib',
    ],
  },
]
