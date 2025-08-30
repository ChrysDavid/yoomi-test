import { ValidationPipe } from '@nestjs/common';

// Configuration globale pour tous les tests
beforeEach(() => {
  // Reset des mocks avant chaque test
  jest.clearAllMocks();
});

// Configuration Jest globale
export const testConfig = {
  validationPipe: new ValidationPipe({
    whitelist: true,
    transform: true,
    forbidNonWhitelisted: true,
  }),
};

// Timeout par défaut pour les tests
jest.setTimeout(10000);