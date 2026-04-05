import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Vendor } from './entities/vendor.entity';
import { PurchaseOrder } from './entities/purchase-order.entity';
import { PurchaseOrderLine } from './entities/purchase-order-line.entity';
import { VendorsService } from './services/vendors.service';
import { PurchaseOrdersService } from './services/purchase-orders.service';
import { VendorsController } from './controllers/vendors.controller';
import { PurchaseOrdersController } from './controllers/purchase-orders.controller';
import { InventoryModule } from '../inventory/inventory.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([Vendor, PurchaseOrder, PurchaseOrderLine]),
    InventoryModule,
  ],
  controllers: [VendorsController, PurchaseOrdersController],
  providers: [VendorsService, PurchaseOrdersService],
  exports: [VendorsService, PurchaseOrdersService],
})
export class PurchasesModule {}
