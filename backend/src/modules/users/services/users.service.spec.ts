import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { UsersService } from './users.service';
import { User } from '../entities/user.entity';

describe('UsersService', () => {
  let service: UsersService;
  let repo: Repository<User>;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UsersService,
        { provide: getRepositoryToken(User), useClass: Repository },
      ],
    }).compile();

    service = module.get<UsersService>(UsersService);
    repo = module.get<Repository<User>>(getRepositoryToken(User));
  });

  it('should create a user', async () => {
    const dto = { username: 'u', email: 'e', password: 'p' } as any;
    const entity = { id: '1' } as User;
    jest.spyOn(repo, 'create').mockReturnValue(entity);
    jest.spyOn(repo, 'save').mockResolvedValue(entity);

    const result = await service.create(dto);

    expect(repo.create).toHaveBeenCalledWith({
      username: 'u',
      email: 'e',
      passwordHash: 'p',
      firstName: undefined,
      lastName: undefined,
      isAdmin: false,
    });
    expect(repo.save).toHaveBeenCalledWith(entity);
    expect(result).toBe(entity);
  });

  it('should find all', async () => {
    const data = [{} as User];
    jest.spyOn(repo, 'find').mockResolvedValue(data);
    expect(await service.findAll()).toBe(data);
  });
});
