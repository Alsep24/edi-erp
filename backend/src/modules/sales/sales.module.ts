import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Invoice } from './entities/invoice.entity';
import { InvoiceLine } from './entities/invoice-line.entity';
import { Customer } from './entities/customer.entity';
import { InvoicesService } from './services/invoices.service';
import { PdfService } from './services/pdf.service';
import { InventoryModule } from '../inventory/inventory.module';

@Module({
  imports: [TypeOrmModule.forFeature([Invoice, InvoiceLine, Customer]), InventoryModule],
  providers: [InvoicesService, PdfService],
  exports: [InvoicesService],
})
export class SalesModule {}
