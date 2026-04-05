import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Product } from './entities/product.entity';
import { ProductStock } from './entities/product-stock.entity';
import { InventoryService } from './services/inventory.service';
import { ProductsService } from './services/products.service';
import { ProductsController } from './controllers/products.controller';

@Module({
  imports: [TypeOrmModule.forFeature([Product, ProductStock])],
  controllers: [ProductsController],
  providers: [InventoryService, ProductsService],
  exports: [InventoryService, ProductsService, TypeOrmModule],
})
export class InventoryModule {}
