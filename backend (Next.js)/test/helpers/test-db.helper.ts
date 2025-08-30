import { PrismaClient } from '@prisma/client';

export class TestDbHelper {
  private static prisma: PrismaClient;

  static async setupTestDb(): Promise<PrismaClient> {
    // Utilise une base SQLite en mémoire pour les tests
    this.prisma = new PrismaClient({
      datasources: {
        db: {
          url: 'file:./test.db'
        }
      }
    });

    await this.prisma.$connect();
    return this.prisma;
  }

  static async cleanupTestDb(): Promise<void> {
    if (this.prisma) {
      // Nettoie toutes les données de test
      await this.prisma.project.deleteMany();
      await this.prisma.$disconnect();
    }
  }

  static async seedTestData(): Promise<void> {
    if (!this.prisma) {
      throw new Error('Test database not initialized');
    }

    // Insert des données de test
    await this.prisma.project.createMany({
      data: [
        {
          name: "Test Project 1",
          status: "DRAFT",
          amount: 1000,
        },
        {
          name: "Test Project 2",  
          status: "PUBLISHED",
          amount: 2000,
        }
      ]
    });
  }

  static getPrisma(): PrismaClient {
    return this.prisma;
  }
}