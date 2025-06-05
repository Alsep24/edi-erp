import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ProductStock } from '../entities/product-stock.entity';
import { Product } from '../entities/product.entity';

@Injectable()
export class InventoryService {
  constructor(
    @InjectRepository(ProductStock)
    private stockRepo: Repository<ProductStock>,
    @InjectRepository(Product)
    private productRepo: Repository<Product>,
  ) {}

  async adjustStock(productId: string, quantityDelta: number): Promise<void> {
    let stock = await this.stockRepo.findOne({ where: { product: { id: productId } }, relations: ['product'] });
    if (!stock) {
      const product = await this.productRepo.findOne({ where: { id: productId } });
      stock = this.stockRepo.create({ product, quantityOnHand: 0 });
    }
    stock.quantityOnHand += quantityDelta;
    await this.stockRepo.save(stock);
  }
}
