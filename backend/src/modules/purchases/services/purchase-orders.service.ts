import { Injectable, NotFoundException, BadRequestException, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { PurchaseOrder, PurchaseOrderStatus } from '../entities/purchase-order.entity';
import { PurchaseOrderLine } from '../entities/purchase-order-line.entity';
import { VendorsService } from './vendors.service';
import { InventoryService } from '../../inventory/services/inventory.service';
import { ProductsService } from '../../inventory/services/products.service';
import { CreatePurchaseOrderDto } from '../dto/create-purchase-order.dto';
import { PaginationDto, PaginatedResult, paginate } from '../../../common/dto/pagination.dto';

@Injectable()
export class PurchaseOrdersService {
  private readonly logger = new Logger(PurchaseOrdersService.name);

  constructor(
    @InjectRepository(PurchaseOrder)
    private readonly orderRepo: Repository<PurchaseOrder>,
    @InjectRepository(PurchaseOrderLine)
    private readonly lineRepo: Repository<PurchaseOrderLine>,
    private readonly vendorsService: VendorsService,
    private readonly inventoryService: InventoryService,
    private readonly productsService: ProductsService,
  ) {}

  async create(dto: CreatePurchaseOrderDto): Promise<PurchaseOrder> {
    const vendor = await this.vendorsService.findOne(dto.vendorId);

    const lines: PurchaseOrderLine[] = [];
    let total = 0;

    for (const lineDto of dto.lines) {
      const product = await this.productsService.findOne(lineDto.productId);
      const lineTotal = Number(lineDto.quantity) * Number(lineDto.unitCost);
      const line = this.lineRepo.create({
        product,
        quantity: lineDto.quantity,
        unitCost: lineDto.unitCost,
        lineTotal,
        quantityReceived: 0,
      });
      lines.push(line);
      total += lineTotal;
    }

    const order = this.orderRepo.create({
      orderNumber: dto.orderNumber,
      company: { id: dto.companyId } as any,
      vendor,
      orderDate: dto.orderDate,
      expectedDate: dto.expectedDate ?? null,
      notes: dto.notes ?? null,
      status: PurchaseOrderStatus.DRAFT,
      lines,
      total,
    });

    const saved = await this.orderRepo.save(order);
    this.logger.log(`Orden de compra creada: ${saved.orderNumber}`);
    return this.findOne(saved.id);
  }

  async findAll(dto: PaginationDto, status?: string): Promise<PaginatedResult<PurchaseOrder>> {
    const qb = this.orderRepo
      .createQueryBuilder('o')
      .leftJoinAndSelect('o.vendor', 'v')
      .leftJoinAndSelect('o.company', 'c');

    if (status) qb.where('o.status = :status', { status });

    qb.orderBy('o.created_at', 'DESC').skip(dto.skip).take(dto.limit ?? 20);
    const [data, total] = await qb.getManyAndCount();
    return paginate(data, total, dto);
  }

  async findOne(id: string): Promise<PurchaseOrder> {
    const order = await this.orderRepo.findOne({
      where: { id },
      relations: ['vendor', 'company', 'lines', 'lines.product'],
    });
    if (!order) throw new NotFoundException(`Orden de compra #${id} no encontrada`);
    return order;
  }

  async confirm(id: string): Promise<PurchaseOrder> {
    const order = await this.findOne(id);
    if (order.status !== PurchaseOrderStatus.DRAFT) {
      throw new BadRequestException(`Solo se pueden confirmar órdenes en estado DRAFT`);
    }
    await this.orderRepo.update(id, { status: PurchaseOrderStatus.CONFIRMED });
    this.logger.log(`Orden confirmada: ${order.orderNumber}`);
    return this.findOne(id);
  }

  /**
   * Recibe la mercancía: actualiza el stock de todos los productos de la orden.
   */
  async receive(id: string): Promise<PurchaseOrder> {
    const order = await this.findOne(id);
    if (order.status !== PurchaseOrderStatus.CONFIRMED) {
      throw new BadRequestException(`Solo se pueden recibir órdenes en estado CONFIRMED`);
    }

    for (const line of order.lines) {
      const pending = Number(line.quantity) - Number(line.quantityReceived);
      if (pending > 0) {
        await this.inventoryService.adjustStock(line.product.id, pending);
        await this.lineRepo.update(line.id, { quantityReceived: line.quantity });
      }
    }

    await this.orderRepo.update(id, { status: PurchaseOrderStatus.RECEIVED });
    this.logger.log(`Orden recibida y stock actualizado: ${order.orderNumber}`);
    return this.findOne(id);
  }

  async cancel(id: string): Promise<PurchaseOrder> {
    const order = await this.findOne(id);
    if (order.status === PurchaseOrderStatus.RECEIVED) {
      throw new BadRequestException(`No se puede cancelar una orden ya recibida`);
    }
    await this.orderRepo.update(id, { status: PurchaseOrderStatus.CANCELLED });
    return this.findOne(id);
  }
}
