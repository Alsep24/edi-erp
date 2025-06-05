// src/modules/core/services/configurations.service.ts
import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CreateConfigurationDto } from '../dto/create-configuration.dto';
import { UpdateConfigurationDto } from '../dto/update-configuration.dto';
import { Configuration } from '../entities/configuration.entity';

@Injectable()
export class ConfigurationsService {
  constructor(
    @InjectRepository(Configuration)
    private readonly configRepo: Repository<Configuration>,
  ) {}

  async create(dto: CreateConfigurationDto): Promise<Configuration> {
    const entity = this.configRepo.create({
      key: dto.key,
      value: dto.value,
      company: dto.companyId ? ({ id: dto.companyId } as any) : undefined,
    });
    return this.configRepo.save(entity);
  }

  findAll(): Promise<Configuration[]> {
    return this.configRepo.find();
  }

  findByCompany(companyId: string): Promise<Configuration[]> {
    return this.configRepo.find({ where: { company: { id: companyId } } });
  }

  findByKey(key: string, companyId?: string): Promise<Configuration | null> {
    return this.configRepo.findOne({
      where: {
        key,
        ...(companyId ? { company: { id: companyId } } : {}),
      } as any,
    });
  }

  findOne(id: string): Promise<Configuration | null> {
    return this.configRepo.findOne({ where: { id } });
  }

  async update(id: string, dto: UpdateConfigurationDto): Promise<Configuration | null> {
    await this.configRepo.update(id, {
      value: dto.value,
      ...(dto.companyId ? { company: { id: dto.companyId } } : {}),
    } as any);
    return this.findOne(id);
  }

  async remove(id: string): Promise<void> {
    await this.configRepo.delete(id);
  }
}
