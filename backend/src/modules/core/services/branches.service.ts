// src/modules/core/services/branches.service.ts
import { Injectable } from '@nestjs/common';
import { CreateBranchDto } from '../dto/create-branch.dto';
import { UpdateBranchDto } from '../dto/update-branch.dto';

@Injectable()
export class BranchesService {
  create(dto: CreateBranchDto) { /* … */ }
  findAll() { /* … */ }
  findByCompany(companyId: string) { /* … */ }
  findOne(id: string) { /* … */ }
  update(id: string, dto: UpdateBranchDto) { /* … */ }
  remove(id: string) { /* … */ }
}
