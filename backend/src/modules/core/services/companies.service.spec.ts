import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CompaniesService } from './companies.service';
import { Company } from '../entities/company.entity';

describe('CompaniesService', () => {
  let service: CompaniesService;
  let repo: Repository<Company>;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        CompaniesService,
        { provide: getRepositoryToken(Company), useClass: Repository },
      ],
    }).compile();

    service = module.get<CompaniesService>(CompaniesService);
    repo = module.get<Repository<Company>>(getRepositoryToken(Company));
  });

  it('should create a company', async () => {
    const dto = { name: 'c', nit: '123' } as any;
    const entity = { id: '1', name: 'c' } as Company;
    jest.spyOn(repo, 'create').mockReturnValue(entity);
    jest.spyOn(repo, 'save').mockResolvedValue(entity);

    const result = await service.create(dto);

    expect(repo.create).toHaveBeenCalledWith({ name: 'c', taxId: '123' });
    expect(repo.save).toHaveBeenCalledWith(entity);
    expect(result).toBe(entity);
  });
});
