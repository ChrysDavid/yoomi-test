import { IsString, Length, IsEnum, IsNumber, Min } from 'class-validator';

// Enum pour définir les statuts possibles d'un projet
export enum Status {
  DRAFT = 'DRAFT',
  PUBLISHED = 'PUBLISHED',
  ARCHIVED = 'ARCHIVED',
}

// DTO (Data Transfer Object) pour valider les données de création d'un projet
export class CreateProjectDto {
  @IsString()
  @Length(1, 255)
  name: string;

  @IsEnum(Status)
  status: Status;

  @IsNumber()
  @Min(0)
  amount: number;
}