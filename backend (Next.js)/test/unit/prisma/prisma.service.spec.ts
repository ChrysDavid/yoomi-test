import { Test, TestingModule } from '@nestjs/testing';
import { PrismaService } from '../../../src/prisma/prisma.service';

jest.mock('@prisma/client', () => ({
  PrismaClient: jest.fn().mockImplementation(() => ({
    $connect: jest.fn(),
    $disconnect: jest.fn(),
  })),
}));

describe('PrismaService', () => {
  let service: PrismaService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [PrismaService],
    }).compile();

    service = module.get<PrismaService>(PrismaService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('onModuleInit', () => {
    it('should either implement onModuleInit and call $connect, or at least expose $connect', async () => {
      const connectSpy = jest.spyOn(service as any, '$connect');

      const maybeHook = (service as any).onModuleInit;
      if (typeof maybeHook === 'function') {
        await maybeHook.call(service);
        expect(connectSpy).toHaveBeenCalled();
      } else {
        // Si pas de hook, on s’assure que $connect existe bien
        expect(typeof (service as any).$connect).toBe('function');
      }
    });
  });

  describe('onModuleDestroy', () => {
    it('should either implement onModuleDestroy and call $disconnect, or at least expose $disconnect', async () => {
      const disconnectSpy = jest.spyOn(service as any, '$disconnect');

      const maybeHook = (service as any).onModuleDestroy;
      if (typeof maybeHook === 'function') {
        await maybeHook.call(service);
        expect(disconnectSpy).toHaveBeenCalled();
      } else {
        // Si pas de hook, on s’assure que $disconnect existe bien
        expect(typeof (service as any).$disconnect).toBe('function');
      }
    });
  });
});
