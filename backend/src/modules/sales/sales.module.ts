import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Invoice } from './entities/invoice.entity';
import { InvoiceLine } from './entities/invoice-line.entity';
import { Customer } from './entities/customer.entity';
import { InvoicesService } from './services/invoices.service';
import { CustomersService } from './services/customers.service';
import { PdfService } from './services/pdf.service';
import { InvoicesController } from './controllers/invoices.controller';
import { CustomersController } from './controllers/customers.controller';
import { InventoryModule } from '../inventory/inventory.module';

@Module({
  imports: [TypeOrmModule.forFeature([Invoice, InvoiceLine, Customer]), InventoryModule],
  controllers: [InvoicesController, CustomersController],
  providers: [InvoicesService, CustomersService, PdfService],
  exports: [InvoicesService, CustomersService],
})
export class SalesModule {}
