// src/modules/core/services/configurations.service.ts
import { Injectable } from '@nestjs/common';
import { CreateConfigurationDto } from '../dto/create-configuration.dto';
import { UpdateConfigurationDto } from '../dto/update-configuration.dto';

@Injectable()
export class ConfigurationsService {
  create(dto: CreateConfigurationDto) { /* … */ }
  findAll() { /* … */ }
  findByCompany(companyId: string) { /* … */ }
  findByKey(key: string, companyId?: string) { /* … */ }
  findOne(id: string) { /* … */ }
  update(id: string, dto: UpdateConfigurationDto) { /* … */ }
  remove(id: string) { /* … */ }
}
