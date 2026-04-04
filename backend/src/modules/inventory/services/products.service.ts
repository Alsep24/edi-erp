import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Product } from '../entities/product.entity';
import { ProductStock } from '../entities/product-stock.entity';
import { CreateProductDto } from '../dto/create-product.dto';
import { UpdateProductDto } from '../dto/update-product.dto';

@Injectable()
export class ProductsService {
  constructor(
    @InjectRepository(Product)
    private readonly productRepo: Repository<Product>,
    @InjectRepository(ProductStock)
    private readonly stockRepo: Repository<ProductStock>,
  ) {}

  async create(dto: CreateProductDto): Promise<Product> {
    const existing = await this.productRepo.findOne({ where: { code: dto.code } });
    if (existing) {
      throw new ConflictException(`Product with code '${dto.code}' already exists`);
    }
    const product = this.productRepo.create(dto);
    const saved = await this.productRepo.save(product);
    // Inicializar stock en 0
    const stock = this.stockRepo.create({ product: saved, quantityOnHand: 0 });
    await this.stockRepo.save(stock);
    return this.findOne(saved.id);
  }

  findAll(): Promise<Product[]> {
    return this.productRepo.find({
      where: { isActive: true },
      relations: ['stock'],
      order: { name: 'ASC' },
    });
  }

  async findOne(id: string): Promise<Product> {
    const product = await this.productRepo.findOne({
      where: { id },
      relations: ['stock'],
    });
    if (!product) throw new NotFoundException(`Product #${id} not found`);
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
    return product;
  }

  async getStock(id: string): Promise<ProductStock> {
    const stock = await this.stockRepo.findOne({
      where: { product: { id } },
      relations: ['product'],
    });
    if (!stock) throw new NotFoundException(`Stock for product #${id} not found`);
    return stock;
  }

  getLowStock(threshold: number = 5): Promise<Product[]> {
    return this.productRepo
      .createQueryBuilder('p')
      .leftJoinAndSelect('p.stock', 's')
      .where('p.is_active = true')
      .andWhere('s.quantity_on_hand <= :threshold', { threshold })
      .orderBy('s.quantity_on_hand', 'ASC')
      .getMany();
  }
}
