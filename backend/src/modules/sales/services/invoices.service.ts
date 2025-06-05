import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Invoice } from '../entities/invoice.entity';
import { InventoryService } from '../../inventory/services/inventory.service';
import { PdfService } from './pdf.service';

@Injectable()
export class InvoicesService {
  constructor(
    @InjectRepository(Invoice)
    private invoiceRepo: Repository<Invoice>,
    private inventoryService: InventoryService,
    private pdfService: PdfService,
  ) {}

  async create(invoice: Invoice): Promise<Invoice> {
    const saved = await this.invoiceRepo.save(invoice);
    if (invoice.lines) {
      for (const line of invoice.lines) {
        await this.inventoryService.adjustStock(line.product.id, -Number(line.quantity));
      }
    }
    return saved;
  }

  generatePdf(invoice: Invoice): Buffer {
    const docDefinition = {
      content: [
        { text: 'Factura #' + invoice.invoiceNumber, style: 'header' },
        { text: 'Cliente: ' + (invoice.customer?.name || ''), margin: [0, 10, 0, 10] },
        {
          table: {
            widths: ['*', 'auto', 'auto', 'auto'],
            body: [
              ['Producto', 'Cantidad', 'Precio', 'Total'],
              ...invoice.lines.map((l) => [l.product.name, l.quantity, l.unitPrice, l.lineTotal]),
            ],
          },
        },
        { text: 'Total: ' + invoice.total, alignment: 'right', margin: [0, 10, 0, 0] },
      ],
    } as any;
    return this.pdfService.generate(docDefinition);
  }
}
