export const testDatabaseConfig = {
  provider: 'sqlite',
  url: 'file:./test.db',
};

export const mockPaginationResult = {
  data: [],
  total: 0,
  page: 1,
  pageSize: 10,
};

export const mockQueryParams = {
  page: '1',
  pageSize: '10',
  status: 'DRAFT',
  q: 'test',
};