import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ConfigurationsService } from './configurations.service';
import { Configuration } from '../entities/configuration.entity';

describe('ConfigurationsService', () => {
  let service: ConfigurationsService;
  let repo: Repository<Configuration>;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ConfigurationsService,
        { provide: getRepositoryToken(Configuration), useClass: Repository },
      ],
    }).compile();

    service = module.get<ConfigurationsService>(ConfigurationsService);
    repo = module.get<Repository<Configuration>>(getRepositoryToken(Configuration));
  });

  it('should create a configuration', async () => {
    const dto = { key: 'k', value: 'v', companyId: '1' } as any;
    const entity = { id: '1', ...dto } as Configuration;
    jest.spyOn(repo, 'create').mockReturnValue(entity);
    jest.spyOn(repo, 'save').mockResolvedValue(entity);

    const result = await service.create(dto);

    expect(repo.create).toHaveBeenCalled();
    expect(repo.save).toHaveBeenCalledWith(entity);
    expect(result).toBe(entity);
  });
});
