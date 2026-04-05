import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { ConfigService } from '@nestjs/config';
import { UsersService } from './users.service';
import { User } from '../entities/user.entity';

const mockUserRepo = {
  create: jest.fn(),
  save: jest.fn(),
  find: jest.fn(),
  findOne: jest.fn(),
  update: jest.fn(),
  delete: jest.fn(),
};

const mockConfigService = {
  get: jest.fn().mockReturnValue('10'),
};

describe('UsersService', () => {
  let service: UsersService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UsersService,
        { provide: getRepositoryToken(User), useValue: mockUserRepo },
        { provide: ConfigService, useValue: mockConfigService },
      ],
    }).compile();

    service = module.get<UsersService>(UsersService);
    jest.clearAllMocks();
  });

  it('debería crear un usuario con contraseña hasheada', async () => {
    const dto = { username: 'john', email: 'john@example.com', password: 'secret123' } as any;
    const entity = { id: 'u1', username: 'john' } as User;
    mockUserRepo.create.mockReturnValue(entity);
    mockUserRepo.save.mockResolvedValue(entity);

    const result = await service.create(dto);
    expect(mockUserRepo.save).toHaveBeenCalled();
    // Verificar que se guarda el hash, no la contraseña en texto plano
    const createCall = mockUserRepo.create.mock.calls[0][0];
    expect(createCall.passwordHash).toBeDefined();
    expect(createCall.passwordHash).not.toBe('secret123');
    expect(result.username).toBe('john');
  });

  it('debería retornar todos los usuarios', async () => {
    const users = [{ id: 'u1' } as User, { id: 'u2' } as User];
    mockUserRepo.find.mockResolvedValue(users);
    const result = await service.findAll();
    expect(result).toHaveLength(2);
  });

  it('debería buscar usuario por username', async () => {
    const user = { id: 'u1', username: 'john' } as User;
    mockUserRepo.findOne.mockResolvedValue(user);
    const result = await service.findByUsername('john');
    expect(result?.username).toBe('john');
  });
});
