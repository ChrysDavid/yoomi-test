// src/projects/projects.controller.ts
import { Controller, Get, Post, Put, Delete, Body, Param, Query, HttpCode } from '@nestjs/common';
import { ProjectsService } from './projects.service';
import { CreateProjectDto } from './dto/create-project.dto';
import { UpdateProjectDto } from './dto/update-project.dto';

@Controller('projects')
export class ProjectsController {
  constructor(private readonly service: ProjectsService) {}

  @Get() // Route GET /projects
  async findAll(@Query() query: any) {
    return this.service.findAll(query);
  }

  @Post() // Route POST /projects
  async create(@Body() dto: CreateProjectDto) {
    return this.service.create(dto);
  }

  @Put(':id') // Route PUT /projects/:id
  async update(@Param('id') id: string, @Body() dto: UpdateProjectDto) {
    return this.service.update(id, dto);
  }

  @Delete(':id') // Route DELETE /projects/:id
  @HttpCode(204)
  async remove(@Param('id') id: string) {
    return this.service.remove(id);
  }
}