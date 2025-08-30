import { validate } from 'class-validator';
import { plainToClass } from 'class-transformer';
import { UpdateProjectDto } from '../../../../src/projects/dto/update-project.dto';
import { Status } from '../../../../src/projects/dto/create-project.dto';

describe('UpdateProjectDto', () => {
  it('should pass validation with empty object (all fields optional)', async () => {
    const emptyData = {};

    const dto = plainToClass(UpdateProjectDto, emptyData);
    const errors = await validate(dto);

    expect(errors).toHaveLength(0);
  });

  it('should pass validation with partial valid data', async () => {
    const partialData = {
      name: 'Updated Project Name',
    };

    const dto = plainToClass(UpdateProjectDto, partialData);
    const errors = await validate(dto);

    expect(errors).toHaveLength(0);
  });

  it('should pass validation with all valid fields', async () => {
    const validData = {
      name: 'Updated Project',
      status: Status.PUBLISHED,
      amount: 2000,
    };

    const dto = plainToClass(UpdateProjectDto, validData);
    const errors = await validate(dto);

    expect(errors).toHaveLength(0);
  });

  describe('optional field validation', () => {
    it('should validate name if provided', async () => {
      const invalidData = {
        name: '', // Invalid: empty string
      };

      const dto = plainToClass(UpdateProjectDto, invalidData);
      const errors = await validate(dto);

      expect(errors).toHaveLength(1);
      expect(errors[0].property).toBe('name');
    });

    it('should validate status if provided', async () => {
      const invalidData = {
        status: 'INVALID_STATUS', // Invalid: not in enum
      };

      const dto = plainToClass(UpdateProjectDto, invalidData);
      const errors = await validate(dto);

      expect(errors).toHaveLength(1);
      expect(errors[0].property).toBe('status');
    });

    it('should validate amount if provided', async () => {
      const invalidData = {
        amount: -100, // Invalid: negative number
      };

      const dto = plainToClass(UpdateProjectDto, invalidData);
      const errors = await validate(dto);

      expect(errors).toHaveLength(1);
      expect(errors[0].property).toBe('amount');
    });
  });

  it('should validate multiple fields if provided', async () => {
    const mixedData = {
      name: 'Valid Name', // Valid
      status: 'INVALID', // Invalid
      amount: 1500, // Valid
    };

    const dto = plainToClass(UpdateProjectDto, mixedData);
    const errors = await validate(dto);

    expect(errors).toHaveLength(1);
    expect(errors[0].property).toBe('status');
  });
});