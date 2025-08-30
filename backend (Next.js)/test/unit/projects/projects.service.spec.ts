import { Test, TestingModule } from '@nestjs/testing';
import { NotFoundException } from '@nestjs/common';
import { ProjectsService } from '../../../src/projects/projects.service';
import { PrismaService } from '../../../src/prisma/prisma.service';
import { mockPrismaService, resetAllMocks } from '../../helpers/mock.helper';
import { mockProjects, validCreateProjectDto, validUpdateProjectDto } from '../../fixtures/projects.fixture';

describe('ProjectsService', () => {
  let service: ProjectsService;
  let prismaService: PrismaService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ProjectsService,
        {
          provide: PrismaService,
          useValue: mockPrismaService,
        },
      ],
    }).compile();

    service = module.get<ProjectsService>(ProjectsService);
    prismaService = module.get<PrismaService>(PrismaService);

    // Remet tous les mocks à zéro
    resetAllMocks();

    // Rendre $transaction compatible avec les 2 signatures Prisma
    // 1) $transaction([promise1, promise2])
    // 2) $transaction(async (tx) => { ... })
    mockPrismaService.$transaction.mockImplementation(async (arg: any) => {
      if (typeof arg === 'function') {
        // interactive transaction: on passe le "client" mocké comme tx
        return arg(mockPrismaService);
      }
      if (Array.isArray(arg)) {
        return Promise.all(arg);
      }
      return undefined;
    });
  });

  describe('findAll', () => {
    it('should return paginated projects', async () => {
      const mockData = mockProjects.slice(0, 2);
      const mockTotal = 5;

      mockPrismaService.project.findMany.mockResolvedValue(mockData);
      mockPrismaService.project.count.mockResolvedValue(mockTotal);

      const result = await service.findAll({ page: 1, pageSize: 2 });

      expect(result).toEqual({
        data: mockData,
        total: mockTotal,
        page: 1,
        pageSize: 2,
      });

      expect(mockPrismaService.$transaction).toHaveBeenCalledTimes(1);
      expect(mockPrismaService.project.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          where: {},
          skip: 0,
          take: 2,
          orderBy: { createdAt: 'desc' },
        }),
      );
      expect(mockPrismaService.project.count).toHaveBeenCalledWith({
        where: {},
      });
    });

    it('should filter by status', async () => {
      const filteredProjects = mockProjects.filter((p) => p.status === 'DRAFT');

      mockPrismaService.project.findMany.mockResolvedValue(filteredProjects);
      mockPrismaService.project.count.mockResolvedValue(filteredProjects.length);

      const result = await service.findAll({ status: 'DRAFT' });

      expect(result.data).toEqual(filteredProjects);
      expect(mockPrismaService.$transaction).toHaveBeenCalledTimes(1);
      expect(mockPrismaService.project.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { status: 'DRAFT' },
        }),
      );
      expect(mockPrismaService.project.count).toHaveBeenCalledWith({
        where: { status: 'DRAFT' },
      });
    });

    it('should filter by name search', async () => {
      const searchTerm = 'Project 1';
      const filteredProjects = mockProjects.filter((p) => p.name.includes(searchTerm));

      mockPrismaService.project.findMany.mockResolvedValue(filteredProjects);
      mockPrismaService.project.count.mockResolvedValue(filteredProjects.length);

      const result = await service.findAll({ q: searchTerm });

      expect(result.data).toEqual(filteredProjects);
      expect(mockPrismaService.$transaction).toHaveBeenCalledTimes(1);
      expect(mockPrismaService.project.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { name: { contains: searchTerm } },
        }),
      );
      expect(mockPrismaService.project.count).toHaveBeenCalledWith({
        where: { name: { contains: searchTerm } },
      });
    });

    it('should handle default pagination values', async () => {
      mockPrismaService.project.findMany.mockResolvedValue([]);
      mockPrismaService.project.count.mockResolvedValue(0);

      await service.findAll({});

      expect(mockPrismaService.$transaction).toHaveBeenCalledTimes(1);
      expect(mockPrismaService.project.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          skip: 0,
          take: 10,
        }),
      );
      expect(mockPrismaService.project.count).toHaveBeenCalledWith({
        where: {},
      });
    });
  });

  describe('create', () => {
    it('should create a new project', async () => {
      const createdProject = { id: '123', ...validCreateProjectDto, createdAt: new Date() };
      mockPrismaService.project.create.mockResolvedValue(createdProject);

      const result = await service.create(validCreateProjectDto);

      expect(result).toEqual(createdProject);
      expect(mockPrismaService.project.create).toHaveBeenCalledWith({
        data: validCreateProjectDto,
      });
    });
  });

  describe('update', () => {
    it('should update an existing project', async () => {
      const projectId = '123';
      const existingProject = mockProjects[0];
      const updatedProject = { ...existingProject, ...validUpdateProjectDto };

      mockPrismaService.project.findUnique.mockResolvedValue(existingProject);
      mockPrismaService.project.update.mockResolvedValue(updatedProject);

      const result = await service.update(projectId, validUpdateProjectDto);

      expect(result).toEqual(updatedProject);
      expect(mockPrismaService.project.findUnique).toHaveBeenCalledWith({
        where: { id: projectId },
      });
      expect(mockPrismaService.project.update).toHaveBeenCalledWith({
        where: { id: projectId },
        data: validUpdateProjectDto,
      });
    });

    it('should throw NotFoundException for non-existing project', async () => {
      const projectId = 'non-existing';
      mockPrismaService.project.findUnique.mockResolvedValue(null);

      await expect(service.update(projectId, validUpdateProjectDto)).rejects.toThrow(NotFoundException);

      expect(mockPrismaService.project.update).not.toHaveBeenCalled();
    });
  });

  describe('remove', () => {
    it('should remove an existing project', async () => {
      const projectId = '123';
      const existingProject = mockProjects[0];

      mockPrismaService.project.findUnique.mockResolvedValue(existingProject);
      mockPrismaService.project.delete.mockResolvedValue(existingProject);

      await service.remove(projectId);

      expect(mockPrismaService.project.findUnique).toHaveBeenCalledWith({
        where: { id: projectId },
      });
      expect(mockPrismaService.project.delete).toHaveBeenCalledWith({
        where: { id: projectId },
      });
    });

    it('should throw NotFoundException for non-existing project', async () => {
      const projectId = 'non-existing';
      mockPrismaService.project.findUnique.mockResolvedValue(null);

      await expect(service.remove(projectId)).rejects.toThrow(NotFoundException);

      expect(mockPrismaService.project.delete).not.toHaveBeenCalled();
    });
  });
});
