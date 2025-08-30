import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from '../../../src/app.module';
import { PrismaService } from '../../../src/prisma/prisma.service';
import { Status } from '../../../src/projects/dto/create-project.dto';

describe('ProjectsController (e2e)', () => {
  let app: INestApplication;
  let prismaService: PrismaService;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.useGlobalPipes(new ValidationPipe({
      whitelist: true,
      transform: true,
    }));

    prismaService = moduleFixture.get<PrismaService>(PrismaService);

    await app.init();
  });

  beforeEach(async () => {
    // Clean database before each test
    await prismaService.project.deleteMany();
  });

  afterAll(async () => {
    await prismaService.project.deleteMany();
    await app.close();
  });

  describe('GET /projects', () => {
    beforeEach(async () => {
      // Seed test data
      await prismaService.project.createMany({
        data: [
          {
            name: 'Test Project 1',
            status: Status.DRAFT,
            amount: 1000,
          },
          {
            name: 'Test Project 2',
            status: Status.PUBLISHED,
            amount: 2000,
          },
          {
            name: 'Another Project',
            status: Status.ARCHIVED,
            amount: 3000,
          },
        ],
      });
    });

    it('should return all projects with pagination', () => {
      return request(app.getHttpServer())
        .get('/projects')
        .expect(200)
        .expect((res) => {
          expect(res.body).toHaveProperty('data');
          expect(res.body).toHaveProperty('total', 3);
          expect(res.body).toHaveProperty('page', 1);
          expect(res.body).toHaveProperty('pageSize', 10);
          expect(res.body.data).toHaveLength(3);
        });
    });

    it('should filter projects by status', () => {
      return request(app.getHttpServer())
        .get('/projects?status=DRAFT')
        .expect(200)
        .expect((res) => {
          expect(res.body.data).toHaveLength(1);
          expect(res.body.data[0].status).toBe('DRAFT');
          expect(res.body.total).toBe(1);
        });
    });

    it('should search projects by name', () => {
      return request(app.getHttpServer())
        .get('/projects?q=Test')
        .expect(200)
        .expect((res) => {
          expect(res.body.data).toHaveLength(2);
          expect(res.body.total).toBe(2);
          res.body.data.forEach((project: any) => {
            expect(project.name).toContain('Test');
          });
        });
    });

    it('should paginate results', () => {
      return request(app.getHttpServer())
        .get('/projects?page=1&pageSize=2')
        .expect(200)
        .expect((res) => {
          expect(res.body.data).toHaveLength(2);
          expect(res.body.page).toBe(1);
          expect(res.body.pageSize).toBe(2);
          expect(res.body.total).toBe(3);
        });
    });

    it('should combine filters', () => {
      return request(app.getHttpServer())
        .get('/projects?status=PUBLISHED&q=Test')
        .expect(200)
        .expect((res) => {
          expect(res.body.data).toHaveLength(1);
          expect(res.body.data[0].status).toBe('PUBLISHED');
          expect(res.body.data[0].name).toContain('Test');
        });
    });
  });

  describe('POST /projects', () => {
    it('should create a new project', () => {
      const newProject = {
        name: 'New Test Project',
        status: Status.DRAFT,
        amount: 5000,
      };

      return request(app.getHttpServer())
        .post('/projects')
        .send(newProject)
        .expect(201)
        .expect((res) => {
          expect(res.body).toHaveProperty('id');
          expect(res.body.name).toBe(newProject.name);
          expect(res.body.status).toBe(newProject.status);
          expect(res.body.amount).toBe(newProject.amount);
          expect(res.body).toHaveProperty('createdAt');
        });
    });

    it('should validate required fields', () => {
      const invalidProject = {
        name: '', // Invalid: empty name
        status: 'INVALID', // Invalid: not in enum
        amount: -100, // Invalid: negative amount
      };

      return request(app.getHttpServer())
        .post('/projects')
        .send(invalidProject)
        .expect(400);
    });

    it('should validate name length', () => {
      const invalidProject = {
        name: 'a'.repeat(256), // Too long
        status: Status.DRAFT,
        amount: 1000,
      };

      return request(app.getHttpServer())
        .post('/projects')
        .send(invalidProject)
        .expect(400);
    });

    it('should validate status enum', () => {
      const invalidProject = {
        name: 'Valid Project Name',
        status: 'INVALID_STATUS',
        amount: 1000,
      };

      return request(app.getHttpServer())
        .post('/projects')
        .send(invalidProject)
        .expect(400);
    });

    it('should validate amount is positive', () => {
      const invalidProject = {
        name: 'Valid Project Name',
        status: Status.DRAFT,
        amount: -500,
      };

      return request(app.getHttpServer())
        .post('/projects')
        .send(invalidProject)
        .expect(400);
    });
  });

  describe('PUT /projects/:id', () => {
    let projectId: string;

    beforeEach(async () => {
      const project = await prismaService.project.create({
        data: {
          name: 'Original Project',
          status: Status.DRAFT,
          amount: 1000,
        },
      });
      projectId = project.id;
    });

    it('should update an existing project', () => {
      const updateData = {
        name: 'Updated Project Name',
        status: Status.PUBLISHED,
        amount: 1500,
      };

      return request(app.getHttpServer())
        .put(`/projects/${projectId}`)
        .send(updateData)
        .expect(200)
        .expect((res) => {
          expect(res.body.id).toBe(projectId);
          expect(res.body.name).toBe(updateData.name);
          expect(res.body.status).toBe(updateData.status);
          expect(res.body.amount).toBe(updateData.amount);
        });
    });

    it('should partially update a project', () => {
      const updateData = {
        name: 'Partially Updated Name',
      };

      return request(app.getHttpServer())
        .put(`/projects/${projectId}`)
        .send(updateData)
        .expect(200)
        .expect((res) => {
          expect(res.body.name).toBe(updateData.name);
          expect(res.body.status).toBe(Status.DRAFT); // Unchanged
          expect(res.body.amount).toBe(1000); // Unchanged
        });
    });

    it('should return 404 for non-existing project', () => {
      const nonExistingId = '00000000-0000-0000-0000-000000000000';
      const updateData = {
        name: 'Updated Name',
      };

      return request(app.getHttpServer())
        .put(`/projects/${nonExistingId}`)
        .send(updateData)
        .expect(404);
    });

    it('should validate update data', () => {
      const invalidUpdateData = {
        name: '', // Invalid: empty name
        amount: -100, // Invalid: negative amount
      };

      return request(app.getHttpServer())
        .put(`/projects/${projectId}`)
        .send(invalidUpdateData)
        .expect(400);
    });
  });

  describe('DELETE /projects/:id', () => {
    let projectId: string;

    beforeEach(async () => {
      const project = await prismaService.project.create({
        data: {
          name: 'Project to Delete',
          status: Status.DRAFT,
          amount: 1000,
        },
      });
      projectId = project.id;
    });

    it('should delete an existing project', () => {
      return request(app.getHttpServer())
        .delete(`/projects/${projectId}`)
        .expect(204);
    });

    it('should return 404 for non-existing project', () => {
      const nonExistingId = '00000000-0000-0000-0000-000000000000';

      return request(app.getHttpServer())
        .delete(`/projects/${nonExistingId}`)
        .expect(404);
    });

    it('should actually remove the project from database', async () => {
      await request(app.getHttpServer())
        .delete(`/projects/${projectId}`)
        .expect(204);

      // Verify project is actually deleted
      const deletedProject = await prismaService.project.findUnique({
        where: { id: projectId },
      });

      expect(deletedProject).toBeNull();
    });
  });
});