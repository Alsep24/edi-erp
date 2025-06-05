import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn } from 'typeorm';
import { Invoice } from './invoice.entity';
import { Product } from '../../inventory/entities/product.entity';

@Entity('invoice_lines', { schema: 'sales' })
export class InvoiceLine {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => Invoice, invoice => invoice.lines)
  @JoinColumn({ name: 'invoice_id' })
  invoice: Invoice;

  @ManyToOne(() => Product)
  @JoinColumn({ name: 'product_id' })
  product: Product;

  @Column('decimal', { precision: 19, scale: 4 })
  quantity: number;

  @Column('decimal', { precision: 19, scale: 4 })
  unitPrice: number;

  @Column('decimal', { precision: 19, scale: 4 })
  lineTotal: number;
}
