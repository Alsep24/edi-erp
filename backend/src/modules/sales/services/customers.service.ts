import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Like } from 'typeorm';
import { Customer } from '../entities/customer.entity';
import { CreateCustomerDto } from '../dto/create-customer.dto';
import { UpdateCustomerDto } from '../dto/update-customer.dto';

@Injectable()
export class CustomersService {
  constructor(
    @InjectRepository(Customer)
    private readonly customerRepo: Repository<Customer>,
  ) {}

  async create(dto: CreateCustomerDto): Promise<Customer> {
    if (dto.email) {
      const existing = await this.customerRepo.findOne({ where: { email: dto.email } });
      if (existing) throw new ConflictException(`Customer with email '${dto.email}' already exists`);
    }
    const customer = this.customerRepo.create(dto);
    return this.customerRepo.save(customer);
  }

  findAll(search?: string): Promise<Customer[]> {
    if (search) {
      return this.customerRepo.find({
        where: [
          { name: Like(`%${search}%`), isActive: true },
          { email: Like(`%${search}%`), isActive: true },
          { taxId: Like(`%${search}%`), isActive: true },
        ],
        order: { name: 'ASC' },
      });
    }
    return this.customerRepo.find({
      where: { isActive: true },
      order: { name: 'ASC' },
    });
  }

  async findOne(id: string): Promise<Customer> {
    const customer = await this.customerRepo.findOne({ where: { id } });
    if (!customer) throw new NotFoundException(`Customer #${id} not found`);
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
