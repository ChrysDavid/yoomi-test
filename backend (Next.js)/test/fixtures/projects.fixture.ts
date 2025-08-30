import { Status } from '../../src/projects/dto/create-project.dto';

export const mockProjects = [
  {
    id: '1',
    name: 'Test Project 1',
    status: Status.DRAFT,
    amount: 1000,
    createdAt: new Date('2024-01-01T00:00:00Z'),
  },
  {
    id: '2',
    name: 'Test Project 2',
    status: Status.PUBLISHED,
    amount: 2000,
    createdAt: new Date('2024-01-02T00:00:00Z'),
  },
  {
    id: '3',
    name: 'Test Project 3',
    status: Status.ARCHIVED,
    amount: 3000,
    createdAt: new Date('2024-01-03T00:00:00Z'),
  },
];

export const validCreateProjectDto = {
  name: 'New Test Project',
  status: Status.DRAFT,
  amount: 5000,
};

export const validUpdateProjectDto = {
  name: 'Updated Project Name',
  status: Status.PUBLISHED,
  amount: 5500,
};

export const invalidCreateProjectDto = {
  name: '', // Invalid: empty string
  status: 'INVALID_STATUS', // Invalid: not in enum
  amount: -100, // Invalid: negative number
};