import { Injectable, NotFoundException, ConflictException, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Customer } from '../entities/customer.entity';
import { CreateCustomerDto } from '../dto/create-customer.dto';
import { UpdateCustomerDto } from '../dto/update-customer.dto';
import { PaginationDto, PaginatedResult, paginate } from '../../../common/dto/pagination.dto';

@Injectable()
export class CustomersService {
  private readonly logger = new Logger(CustomersService.name);

  constructor(
    @InjectRepository(Customer)
    private readonly customerRepo: Repository<Customer>,
  ) {}

  async create(dto: CreateCustomerDto): Promise<Customer> {
    if (dto.email) {
      const existing = await this.customerRepo.findOne({ where: { email: dto.email } });
      if (existing) throw new ConflictException(`Cliente con email '${dto.email}' ya existe`);
    }
    const customer = this.customerRepo.create(dto);
    const saved = await this.customerRepo.save(customer);
    this.logger.log(`Cliente creado: ${saved.name}`);
    return saved;
  }

  async findAll(dto: PaginationDto, search?: string): Promise<PaginatedResult<Customer>> {
    const qb = this.customerRepo.createQueryBuilder('c').where('c.is_active = true');

    if (search) {
      qb.andWhere(
        '(c.name ILIKE :search OR c.email ILIKE :search OR c.tax_id ILIKE :search)',
        { search: `%${search}%` },
      );
    }

    qb.orderBy('c.name', 'ASC').skip(dto.skip).take(dto.limit ?? 20);
    const [data, total] = await qb.getManyAndCount();
    return paginate(data, total, dto);
  }

  async findOne(id: string): Promise<Customer> {
    const customer = await this.customerRepo.findOne({ where: { id } });
    if (!customer) throw new NotFoundException(`Cliente #${id} no encontrado`);
    return customer;
  }

  async update(id: string, dto: UpdateCustomerDto): Promise<Customer> {
    await this.findOne(id);
    await this.customerRepo.update(id, dto as any);
    return this.findOne(id);
  }

  async remove(id: string): Promise<Customer> {
    const customer = await this.findOne(id);
    await this.customerRepo.update(id, { isActive: false });
    return customer;
  }
}
