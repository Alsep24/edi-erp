import { Injectable, NotFoundException, ConflictException, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Product } from '../entities/product.entity';
import { ProductStock } from '../entities/product-stock.entity';
import { CreateProductDto } from '../dto/create-product.dto';
import { UpdateProductDto } from '../dto/update-product.dto';
import { PaginationDto, PaginatedResult, paginate } from '../../../common/dto/pagination.dto';

@Injectable()
export class ProductsService {
  private readonly logger = new Logger(ProductsService.name);

  constructor(
    @InjectRepository(Product)
    private readonly productRepo: Repository<Product>,
    @InjectRepository(ProductStock)
    private readonly stockRepo: Repository<ProductStock>,
  ) {}

  async create(dto: CreateProductDto): Promise<Product> {
    const existing = await this.productRepo.findOne({ where: { code: dto.code } });
    if (existing) throw new ConflictException(`Producto con código '${dto.code}' ya existe`);

    const product = this.productRepo.create(dto);
    const saved = await this.productRepo.save(product);

    // Inicializar stock en 0
    const stock = this.stockRepo.create({ product: saved, quantityOnHand: 0 });
    await this.stockRepo.save(stock);

    this.logger.log(`Producto creado: ${saved.code} - ${saved.name}`);
    return this.findOne(saved.id);
  }

  async findAll(dto: PaginationDto, search?: string): Promise<PaginatedResult<Product>> {
    const qb = this.productRepo
      .createQueryBuilder('p')
      .leftJoinAndSelect('p.stock', 's')
      .where('p.is_active = true');

    if (search) {
      qb.andWhere('(p.name ILIKE :search OR p.code ILIKE :search OR p.category ILIKE :search)', {
        search: `%${search}%`,
      });
    }

    const sortField = dto.sortBy ? `p.${dto.sortBy}` : 'p.name';
    qb.orderBy(sortField, dto.sortOrder ?? 'ASC')
      .skip(dto.skip)
      .take(dto.limit ?? 20);

    const [data, total] = await qb.getManyAndCount();
    return paginate(data, total, dto);
  }

  async findOne(id: string): Promise<Product> {
    const product = await this.productRepo.findOne({ where: { id }, relations: ['stock'] });
    if (!product) throw new NotFoundException(`Producto #${id} no encontrado`);
    return product;
  }

  async update(id: string, dto: UpdateProductDto): Promise<Product> {
    await this.findOne(id);
    await this.productRepo.update(id, dto as any);
    return this.findOne(id);
  }

  async remove(id: string): Promise<Product> {
    const product = await this.findOne(id);
    await this.productRepo.update(id, { isActive: false });
    this.logger.log(`Producto desactivado: ${product.code}`);
    return product;
  }

  async getStock(id: string): Promise<ProductStock> {
    const stock = await this.stockRepo.findOne({ where: { product: { id } }, relations: ['product'] });
    if (!stock) throw new NotFoundException(`Stock para producto #${id} no encontrado`);
    return stock;
  }

  async getLowStock(threshold = 5): Promise<Product[]> {
    return this.productRepo
      .createQueryBuilder('p')
      .leftJoinAndSelect('p.stock', 's')
      .where('p.is_active = true')
      .andWhere('s.quantity_on_hand <= :threshold', { threshold })
      .orderBy('s.quantity_on_hand', 'ASC')
      .getMany();
  }
}
