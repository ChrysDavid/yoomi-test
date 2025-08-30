module.exports = {
  displayName: 'Projects API Tests',
  testEnvironment: 'node',
  roots: ['<rootDir>/src', '<rootDir>/test'],
  testMatch: [
    '<rootDir>/test/**/*.(test|spec).ts',
    '<rootDir>/src/**/*.(test|spec).ts'
  ],
  transform: {
    '^.+\\.ts$': 'ts-jest',
  },
  coverageDirectory: 'coverage',
  collectCoverageFrom: [
    'src/**/*.ts',
    '!src/**/*.spec.ts',
    '!src/**/*.e2e-spec.ts',
    '!src/main.ts',
    '!src/**/*.module.ts',
    '!src/**/*.interface.ts',
    '!src/**/*.enum.ts',
  ],
  moduleFileExtensions: ['js', 'json', 'ts'],
  rootDir: '.',
  testEnvironment: 'node',
  setupFilesAfterEnv: ['<rootDir>/test/helpers/setup.helper.ts'],
  testTimeout: 10000,
  moduleNameMapper: {
    '^src/(.*)$': '<rootDir>/src/$1'
  },
  
  coverageReporters: ['text', 'lcov', 'html'],
  coverageThreshold: {
    global: {
      branches: 70,
      functions: 70,
      lines: 70,
      statements: 70,
    },
  },
};