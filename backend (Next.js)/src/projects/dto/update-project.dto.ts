import { PartialType } from '@nestjs/mapped-types';
import { CreateProjectDto } from './create-project.dto';

// PartialType rend tous les champs du CreateProjectDto optionnels pour les mises à jour
export class UpdateProjectDto extends PartialType(CreateProjectDto) {}