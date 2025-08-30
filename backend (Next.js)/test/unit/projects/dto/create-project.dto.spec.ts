import { validate } from 'class-validator';
import { plainToClass } from 'class-transformer';
import { CreateProjectDto, Status } from '../../../../src/projects/dto/create-project.dto';

describe('CreateProjectDto', () => {
  it('should pass validation with valid data', async () => {
    const validData = {
      name: 'Test Project',
      status: Status.DRAFT,
      amount: 1000,
    };

    const dto = plainToClass(CreateProjectDto, validData);
    const errors = await validate(dto);

    expect(errors).toHaveLength(0);
  });

  describe('name validation', () => {
    it('should fail validation when name is empty', async () => {
      const invalidData = {
        name: '',
        status: Status.DRAFT,
        amount: 1000,
      };

      const dto = plainToClass(CreateProjectDto, invalidData);
      const errors = await validate(dto);

      expect(errors).toHaveLength(1);
      expect(errors[0].property).toBe('name');
      expect(errors[0].constraints).toHaveProperty('isLength');
    });

    it('should fail validation when name is too long', async () => {
      const invalidData = {
        name: 'a'.repeat(256), // 256 characters, exceeds max length of 255
        status: Status.DRAFT,
        amount: 1000,
      };

      const dto = plainToClass(CreateProjectDto, invalidData);
      const errors = await validate(dto);

      expect(errors).toHaveLength(1);
      expect(errors[0].property).toBe('name');
      expect(errors[0].constraints).toHaveProperty('isLength');
    });

    it('should fail validation when name is not a string', async () => {
      const invalidData = {
        name: 123,
        status: Status.DRAFT,
        amount: 1000,
      };

      const dto = plainToClass(CreateProjectDto, invalidData);
      const errors = await validate(dto);

      expect(errors).toHaveLength(1);
      expect(errors[0].property).toBe('name');
      expect(errors[0].constraints).toHaveProperty('isString');
    });
  });

  describe('status validation', () => {
    it('should pass validation with valid status values', async () => {
      const validStatuses = [Status.DRAFT, Status.PUBLISHED, Status.ARCHIVED];

      for (const status of validStatuses) {
        const validData = {
          name: 'Test Project',
          status: status,
          amount: 1000,
        };

        const dto = plainToClass(CreateProjectDto, validData);
        const errors = await validate(dto);

        expect(errors).toHaveLength(0);
      }
    });

    it('should fail validation with invalid status', async () => {
      const invalidData = {
        name: 'Test Project',
        status: 'INVALID_STATUS',
        amount: 1000,
      };

      const dto = plainToClass(CreateProjectDto, invalidData);
      const errors = await validate(dto);

      expect(errors).toHaveLength(1);
      expect(errors[0].property).toBe('status');
      expect(errors[0].constraints).toHaveProperty('isEnum');
    });
  });

  describe('amount validation', () => {
    it('should pass validation with valid positive numbers', async () => {
      const validAmounts = [0, 1, 100, 1000.50];

      for (const amount of validAmounts) {
        const validData = {
          name: 'Test Project',
          status: Status.DRAFT,
          amount: amount,
        };

        const dto = plainToClass(CreateProjectDto, validData);
        const errors = await validate(dto);

        expect(errors).toHaveLength(0);
      }
    });

    it('should fail validation with negative numbers', async () => {
      const invalidData = {
        name: 'Test Project',
        status: Status.DRAFT,
        amount: -100,
      };

      const dto = plainToClass(CreateProjectDto, invalidData);
      const errors = await validate(dto);

      expect(errors).toHaveLength(1);
      expect(errors[0].property).toBe('amount');
      expect(errors[0].constraints).toHaveProperty('min');
    });

    it('should fail validation when amount is not a number', async () => {
      const invalidData = {
        name: 'Test Project',
        status: Status.DRAFT,
        amount: 'not a number',
      };

      const dto = plainToClass(CreateProjectDto, invalidData);
      const errors = await validate(dto);

      expect(errors).toHaveLength(1);
      expect(errors[0].property).toBe('amount');
      expect(errors[0].constraints).toHaveProperty('isNumber');
    });
  });

  it('should fail validation with multiple invalid fields', async () => {
    const invalidData = {
      name: '',
      status: 'INVALID',
      amount: -100,
    };

    const dto = plainToClass(CreateProjectDto, invalidData);
    const errors = await validate(dto);

    expect(errors).toHaveLength(3);
    
    const properties = errors.map(error => error.property);
    expect(properties).toContain('name');
    expect(properties).toContain('status');
    expect(properties).toContain('amount');
  });
});