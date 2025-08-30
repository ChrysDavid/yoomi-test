export const mockPrismaService = {
  project: {
    findMany: jest.fn(),
    findUnique: jest.fn(),
    create: jest.fn(),
    update: jest.fn(),
    delete: jest.fn(),
    count: jest.fn(),
  },
  $transaction: jest.fn(),
  $connect: jest.fn(),
  $disconnect: jest.fn(),
};

// Mock des données de réponse HTTP
export const mockHttpResponse = {
  status: jest.fn().mockReturnThis(),
  json: jest.fn().mockReturnThis(),
  send: jest.fn().mockReturnThis(),
};

// Mock des données de requête HTTP
export const mockHttpRequest = {
  query: {},
  body: {},
  params: {},
};

// Helper pour reset tous les mocks
export const resetAllMocks = () => {
  Object.values(mockPrismaService.project).forEach(mock => mock.mockReset());
  mockPrismaService.$transaction.mockReset();
  mockHttpResponse.status.mockClear();
  mockHttpResponse.json.mockClear();
  mockHttpResponse.send.mockClear();
};