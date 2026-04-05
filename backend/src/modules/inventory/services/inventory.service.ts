import { Injectable, BadRequestException, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ProductStock } from '../entities/product-stock.entity';
import { Product } from '../entities/product.entity';

@Injectable()
export class InventoryService {
  private readonly logger = new Logger(InventoryService.name);

  constructor(
    @InjectRepository(ProductStock)
    private readonly stockRepo: Repository<ProductStock>,
    @InjectRepository(Product)
    private readonly productRepo: Repository<Product>,
  ) {}

  async adjustStock(productId: string, quantityDelta: number): Promise<ProductStock> {
    let stock = await this.stockRepo.findOne({
      where: { product: { id: productId } },
      relations: ['product'],
    });

    if (!stock) {
      const product = await this.productRepo.findOne({ where: { id: productId } });
      if (!product) throw new BadRequestException(`Product #${productId} not found`);
      stock = this.stockRepo.create({ product, quantityOnHand: 0 });
    }

    const newQty = Number(stock.quantityOnHand) + quantityDelta;

    // Evitar stock negativo en salidas
    if (quantityDelta < 0 && newQty < 0) {
      throw new BadRequestException(
        `Stock insuficiente para el producto "${stock.product?.name ?? productId}". ` +
          `Disponible: ${stock.quantityOnHand}, requerido: ${Math.abs(quantityDelta)}`,
      );
    }

    stock.quantityOnHand = newQty;
    const saved = await this.stockRepo.save(stock);
    this.logger.verbose(
      `Stock ajustado: producto ${productId}, delta ${quantityDelta}, nuevo stock ${newQty}`,
    );
    return saved;
  }

  async getStockForProduct(productId: string): Promise<number> {
    const stock = await this.stockRepo.findOne({ where: { product: { id: productId } } });
    return stock ? Number(stock.quantityOnHand) : 0;
  }
}
