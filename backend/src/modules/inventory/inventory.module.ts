import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Product } from './entities/product.entity';
import { ProductStock } from './entities/product-stock.entity';
import { InventoryService } from './services/inventory.service';

@Module({
  imports: [TypeOrmModule.forFeature([Product, ProductStock])],
  providers: [InventoryService],
  exports: [InventoryService, TypeOrmModule],
})
export class InventoryModule {}
