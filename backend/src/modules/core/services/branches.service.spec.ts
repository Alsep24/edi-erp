import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { BranchesService } from './branches.service';
import { Branch } from '../entities/branch.entity';

describe('BranchesService', () => {
  let service: BranchesService;
  let repo: Repository<Branch>;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        BranchesService,
        {
          provide: getRepositoryToken(Branch),
          useClass: Repository,
        },
      ],
    }).compile();

    service = module.get<BranchesService>(BranchesService);
    repo = module.get<Repository<Branch>>(getRepositoryToken(Branch));
  });

  it('should create a branch', async () => {
    const dto = { name: 'b' } as any;
    const entity = { id: '1', ...dto } as Branch;
    jest.spyOn(repo, 'create').mockReturnValue(entity);
    jest.spyOn(repo, 'save').mockResolvedValue(entity);

    const result = await service.create(dto);

    expect(repo.create).toHaveBeenCalledWith(dto);
    expect(repo.save).toHaveBeenCalledWith(entity);
    expect(result).toBe(entity);
  });

  it('should find all', async () => {
    const data = [{} as Branch];
    jest.spyOn(repo, 'find').mockResolvedValue(data);
    expect(await service.findAll()).toBe(data);
  });
});
