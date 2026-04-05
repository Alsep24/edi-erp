import { Injectable, NotFoundException, ConflictException, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Vendor } from '../entities/vendor.entity';
import { CreateVendorDto } from '../dto/create-vendor.dto';
import { PaginationDto, PaginatedResult, paginate } from '../../../common/dto/pagination.dto';

@Injectable()
export class VendorsService {
  private readonly logger = new Logger(VendorsService.name);

  constructor(
    @InjectRepository(Vendor)
    private readonly vendorRepo: Repository<Vendor>,
  ) {}

  async create(dto: CreateVendorDto): Promise<Vendor> {
    if (dto.email) {
      const existing = await this.vendorRepo.findOne({ where: { email: dto.email } });
      if (existing) throw new ConflictException(`Proveedor con email '${dto.email}' ya existe`);
    }
    const vendor = this.vendorRepo.create(dto);
    const saved = await this.vendorRepo.save(vendor);
    this.logger.log(`Proveedor creado: ${saved.name}`);
    return saved;
  }

  async findAll(dto: PaginationDto, search?: string): Promise<PaginatedResult<Vendor>> {
    const qb = this.vendorRepo.createQueryBuilder('v').where('v.is_active = true');
    if (search) {
      qb.andWhere('(v.name ILIKE :s OR v.tax_id ILIKE :s OR v.email ILIKE :s)', { s: `%${search}%` });
    }
    qb.orderBy('v.name', 'ASC').skip(dto.skip).take(dto.limit ?? 20);
    const [data, total] = await qb.getManyAndCount();
    return paginate(data, total, dto);
  }

  async findOne(id: string): Promise<Vendor> {
    const vendor = await this.vendorRepo.findOne({ where: { id } });
    if (!vendor) throw new NotFoundException(`Proveedor #${id} no encontrado`);
    return vendor;
  }

  async update(id: string, dto: Partial<CreateVendorDto>): Promise<Vendor> {
    await this.findOne(id);
    await this.vendorRepo.update(id, dto as any);
    return this.findOne(id);
  }

  async remove(id: string): Promise<Vendor> {
    const vendor = await this.findOne(id);
    await this.vendorRepo.update(id, { isActive: false });
    return vendor;
  }
}
