import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn } from 'typeorm';
import { PurchaseOrder } from './purchase-order.entity';
import { Product } from '../../inventory/entities/product.entity';

@Entity('purchase_order_lines', { schema: 'purchases' })
export class PurchaseOrderLine {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => PurchaseOrder, (order) => order.lines)
  @JoinColumn({ name: 'order_id' })
  order: PurchaseOrder;

  @ManyToOne(() => Product)
  @JoinColumn({ name: 'product_id' })
  product: Product;

  @Column('decimal', { precision: 19, scale: 4 })
  quantity: number;

  @Column('decimal', { precision: 19, scale: 4, name: 'unit_cost' })
  unitCost: number;

  @Column('decimal', { precision: 19, scale: 4, name: 'line_total' })
  lineTotal: number;

  @Column('decimal', { precision: 19, scale: 4, name: 'quantity_received', default: 0 })
  quantityReceived: number;
}
