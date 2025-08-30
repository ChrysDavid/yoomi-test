import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateProjectDto } from './dto/create-project.dto';
import { UpdateProjectDto } from './dto/update-project.dto';

@Injectable()
export class ProjectsService {
  constructor(private prisma: PrismaService) {}

  async findAll(query: any) {
    const { status, q, page = 1, pageSize = 10 } = query;
    
    const where: any = {};
    if (status) where.status = status;
    if (q) where.name = { contains: q };

    const pageNum = Number(page) > 0 ? Number(page) : 1;
    const size = Number(pageSize) > 0 ? Number(pageSize) : 10;
    const skip = (pageNum - 1) * size;

    const [data, total] = await this.prisma.$transaction([
      this.prisma.project.findMany({ 
        where, 
        skip, 
        take: size, 
        orderBy: { createdAt: 'desc' } // Tri par date de création décroissante
      }),
      this.prisma.project.count({ where }), // Compte le total d'enregistrements correspondants
    ]);

    return { data, total, page: pageNum, pageSize: size };
  }

  // Méthode pour créer un nouveau projet
  async create(dto: CreateProjectDto) {
    return this.prisma.project.create({ data: dto as any });
  }

  // Méthode pour mettre à jour un projet existant
  async update(id: string, dto: UpdateProjectDto) {
    // Vérifier si le projet existe avant de le mettre à jour
    const exists = await this.prisma.project.findUnique({ where: { id } });
    if (!exists) throw new NotFoundException(`Project ${id} not found`);
    
    return this.prisma.project.update({ where: { id }, data: dto as any });
  }

  // Méthode pour supprimer un projet
  async remove(id: string) {
    // Vérifier si le projet existe avant de le supprimer
    const exists = await this.prisma.project.findUnique({ where: { id } });
    if (!exists) throw new NotFoundException(`Project ${id} not found`);
    
    await this.prisma.project.delete({ where: { id } });
  }
}