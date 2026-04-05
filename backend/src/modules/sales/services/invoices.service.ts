import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Invoice } from '../entities/invoice.entity';
import { InvoiceLine } from '../entities/invoice-line.entity';
import { Customer } from '../entities/customer.entity';
import { InventoryService } from '../../inventory/services/inventory.service';
import { ProductsService } from '../../inventory/services/products.service';
import { PdfService } from './pdf.service';
import { CreateInvoiceDto } from '../dto/create-invoice.dto';

@Injectable()
export class InvoicesService {
  constructor(
    @InjectRepository(Invoice)
    private readonly invoiceRepo: Repository<Invoice>,
    @InjectRepository(InvoiceLine)
    private readonly lineRepo: Repository<InvoiceLine>,
    @InjectRepository(Customer)
    private readonly customerRepo: Repository<Customer>,
    private readonly inventoryService: InventoryService,
    private readonly productsService: ProductsService,
    private readonly pdfService: PdfService,
  ) {}

  async create(dto: CreateInvoiceDto): Promise<Invoice> {
    // Validate and build lines
    const lines: InvoiceLine[] = [];
    let total = 0;
    for (const lineDto of dto.lines) {
      const product = await this.productsService.findOne(lineDto.productId);
      const lineTotal = Number(lineDto.quantity) * Number(lineDto.unitPrice);
      const line = this.lineRepo.create({
        product,
        quantity: lineDto.quantity,
        unitPrice: lineDto.unitPrice,
        lineTotal,
      });
      lines.push(line);
      total += lineTotal;
    }

    let customer: Customer | undefined;
    if (dto.customerId) {
      customer = await this.customerRepo.findOne({ where: { id: dto.customerId } });
      if (!customer) throw new BadRequestException(`Customer #${dto.customerId} not found`);
    }

    const invoice = this.invoiceRepo.create({
      company: { id: dto.companyId } as any,
      invoiceNumber: dto.invoiceNumber,
      customer,
      invoiceDate: dto.invoiceDate,
      lines,
      total,
    });

    const saved = await this.invoiceRepo.save(invoice);

    // Descontar inventario
    for (const lineDto of dto.lines) {
      await this.inventoryService.adjustStock(lineDto.productId, -Number(lineDto.quantity));
    }

    return this.findOne(saved.id);
  }

  findAll(): Promise<Invoice[]> {
    return this.invoiceRepo.find({
      relations: ['customer', 'company', 'lines', 'lines.product'],
      order: { createdAt: 'DESC' },
    });
  }

  async findOne(id: string): Promise<Invoice> {
    const invoice = await this.invoiceRepo.findOne({
      where: { id },
      relations: ['customer', 'company', 'lines', 'lines.product'],
    });
    if (!invoice) throw new NotFoundException(`Invoice #${id} not found`);
    return invoice;
  }

  async generatePdf(id: string): Promise<Buffer> {
    const invoice = await this.findOne(id);
    const docDefinition = {
      content: [
        { text: `Factura #${invoice.invoiceNumber}`, style: 'header', fontSize: 18, bold: true },
        { text: `Fecha: ${invoice.invoiceDate}`, margin: [0, 6, 0, 0] },
        { text: `Cliente: ${invoice.customer?.name ?? 'Consumidor Final'}`, margin: [0, 4, 0, 10] },
        {
          table: {
            widths: ['*', 'auto', 'auto', 'auto'],
            body: [
              [
                { text: 'Producto', bold: true },
                { text: 'Cantidad', bold: true },
                { text: 'Precio Unit.', bold: true },
                { text: 'Total', bold: true },
              ],
              ...invoice.lines.map((l) => [
                l.product.name,
                String(l.quantity),
                `$${Number(l.unitPrice).toFixed(2)}`,
                `$${Number(l.lineTotal).toFixed(2)}`,
              ]),
            ],
          },
        },
        {
          text: `Total: $${Number(invoice.total).toFixed(2)}`,
          alignment: 'right',
          bold: true,
          fontSize: 14,
          margin: [0, 12, 0, 0],
        },
      ],
    } as any;
    return this.pdfService.generate(docDefinition);
  }
}
