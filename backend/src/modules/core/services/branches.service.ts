// src/modules/core/services/branches.service.ts
import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CreateBranchDto } from '../dto/create-branch.dto';
import { UpdateBranchDto } from '../dto/update-branch.dto';
import { Branch } from '../entities/branch.entity';

@Injectable()
export class BranchesService {
  constructor(
    @InjectRepository(Branch)
    private readonly branchRepo: Repository<Branch>,
  ) {}

  async create(dto: CreateBranchDto): Promise<Branch> {
    const entity = this.branchRepo.create(dto as any);
    return this.branchRepo.save(entity);
  }

  findAll(): Promise<Branch[]> {
    return this.branchRepo.find();
  }

  findByCompany(companyId: string): Promise<Branch[]> {
    return this.branchRepo.find({ where: { company: { id: companyId } } });
  }

  findOne(id: string): Promise<Branch | null> {
    return this.branchRepo.findOne({ where: { id } });
  }

  async update(id: string, dto: UpdateBranchDto): Promise<Branch | null> {
    await this.branchRepo.update(id, dto);
    return this.findOne(id);
  }

  async remove(id: string): Promise<void> {
    await this.branchRepo.delete(id);
  }
}
