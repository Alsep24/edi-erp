import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { Role } from '../entities/role.entity';
import { Permission } from '../entities/permission.entity';
import { CreateRoleDto } from '../dto/create-role.dto';
import { UpdateRoleDto } from '../dto/update-role.dto';

@Injectable()
export class RolesService {
  constructor(
    @InjectRepository(Role)
    private readonly roleRepo: Repository<Role>,
    @InjectRepository(Permission)
    private readonly permissionRepo: Repository<Permission>,
  ) {}

  async create(dto: CreateRoleDto): Promise<Role> {
    const role = this.roleRepo.create({
      name: dto.name,
      description: dto.description,
    });
    if (dto.permissionIds?.length) {
      role.permissions = await this.permissionRepo.findBy({ id: In(dto.permissionIds) });
    }
    return this.roleRepo.save(role);
  }

  findAll(): Promise<Role[]> {
    return this.roleRepo.find({
      where: { isActive: true },
      order: { name: 'ASC' },
    });
  }

  async findOne(id: string): Promise<Role> {
    const role = await this.roleRepo.findOne({ where: { id }, relations: ['permissions'] });
    if (!role) throw new NotFoundException(`Role #${id} not found`);
    return role;
  }

  async update(id: string, dto: UpdateRoleDto): Promise<Role> {
    const role = await this.findOne(id);
    if (dto.permissionIds !== undefined) {
      role.permissions = dto.permissionIds.length
        ? await this.permissionRepo.findBy({ id: In(dto.permissionIds) })
        : [];
    }
    Object.assign(role, {
      name: dto.name ?? role.name,
      description: dto.description ?? role.description,
      isActive: dto.isActive ?? role.isActive,
    });
    return this.roleRepo.save(role);
  }

  async remove(id: string): Promise<Role> {
    const role = await this.findOne(id);
    await this.roleRepo.update(id, { isActive: false });
    return role;
  }
}
