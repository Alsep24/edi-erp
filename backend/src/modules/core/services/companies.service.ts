import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Company } from '../entities/company.entity';
import { CreateCompanyDto } from '../dto/create-company.dto';
import { UpdateCompanyDto } from '../dto/update-company.dto';

@Injectable()
export class CompaniesService {
  constructor(
    @InjectRepository(Company)
    private readonly companyRepo: Repository<Company>,
  ) {}

  async create(dto: CreateCompanyDto): Promise<Company> {
    const entity = this.companyRepo.create({
      name: dto.name,
      taxId: dto.nit,
    });
    return this.companyRepo.save(entity);
  }

  findAll(): Promise<Company[]> {
    return this.companyRepo.find();
  }

  findOne(id: string): Promise<Company | null> {
    return this.companyRepo.findOne({ where: { id } });
  }

  async update(id: string, dto: UpdateCompanyDto): Promise<Company | null> {
    await this.companyRepo.update(id, {
      name: dto.name,
      taxId: dto.nit,
      legalName: dto.legalName,
      address: dto.address,
      isActive: dto.isActive,
    });
    return this.findOne(id);
  }

  async remove(id: string): Promise<void> {
    await this.companyRepo.delete(id);
  }
}
