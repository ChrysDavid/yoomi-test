import { Test, TestingModule } from '@nestjs/testing';
import { ProjectsController } from '../../../src/projects/projects.controller';
import { ProjectsService } from '../../../src/projects/projects.service';
import { mockProjects, validCreateProjectDto, validUpdateProjectDto } from '../../fixtures/projects.fixture';
import { mockQueryParams } from '../../fixtures/database.fixture';

describe('ProjectsController', () => {
  let controller: ProjectsController;
  let service: ProjectsService;

  const mockProjectsService = {
    findAll: jest.fn(),
    create: jest.fn(),
    update: jest.fn(),
    remove: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [ProjectsController],
      providers: [
        {
          provide: ProjectsService,
          useValue: mockProjectsService,
        },
      ],
    }).compile();

    controller = module.get<ProjectsController>(ProjectsController);
    service = module.get<ProjectsService>(ProjectsService);
    
    // Reset all mocks before each test
    Object.values(mockProjectsService).forEach(mock => mock.mockReset());
  });

  describe('findAll', () => {
    it('should return paginated projects', async () => {
      const expectedResult = {
        data: mockProjects,
        total: mockProjects.length,
        page: 1,
        pageSize: 10,
      };
      
      mockProjectsService.findAll.mockResolvedValue(expectedResult);

      const result = await controller.findAll(mockQueryParams);

      expect(result).toEqual(expectedResult);
      expect(service.findAll).toHaveBeenCalledWith(mockQueryParams);
    });

    it('should pass query parameters to service', async () => {
      const queryParams = {
        status: 'PUBLISHED',
        q: 'search term',
        page: '2',
        pageSize: '5',
      };
      
      mockProjectsService.findAll.mockResolvedValue({ data: [], total: 0, page: 2, pageSize: 5 });

      await controller.findAll(queryParams);

      expect(service.findAll).toHaveBeenCalledWith(queryParams);
    });
  });

  describe('create', () => {
    it('should create a new project', async () => {
      const createdProject = {
        id: '123',
        ...validCreateProjectDto,
        createdAt: new Date(),
      };
      
      mockProjectsService.create.mockResolvedValue(createdProject);

      const result = await controller.create(validCreateProjectDto);

      expect(result).toEqual(createdProject);
      expect(service.create).toHaveBeenCalledWith(validCreateProjectDto);
    });
  });

  describe('update', () => {
    it('should update an existing project', async () => {
      const projectId = '123';
      const updatedProject = {
        id: projectId,
        ...validUpdateProjectDto,
        createdAt: new Date(),
      };
      
      mockProjectsService.update.mockResolvedValue(updatedProject);

      const result = await controller.update(projectId, validUpdateProjectDto);

      expect(result).toEqual(updatedProject);
      expect(service.update).toHaveBeenCalledWith(projectId, validUpdateProjectDto);
    });
  });

  describe('remove', () => {
    it('should remove a project', async () => {
      const projectId = '123';
      mockProjectsService.remove.mockResolvedValue(undefined);

      const result = await controller.remove(projectId);

      expect(result).toBeUndefined();
      expect(service.remove).toHaveBeenCalledWith(projectId);
    });
  });
});