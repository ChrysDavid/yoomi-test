import { Injectable, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  // Cette méthode se connecte à la base de données au démarrage du module
  async onModuleInit() {
    await this.$connect();
  }
  
  // Cette méthode ferme la connexion à la base de données à l'arrêt du module
  async onModuleDestroy() {
    await this.$disconnect();
  }
}