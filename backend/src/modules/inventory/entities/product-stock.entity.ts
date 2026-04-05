import { Entity, PrimaryGeneratedColumn, Column, OneToOne, JoinColumn, UpdateDateColumn } from 'typeorm';
import { Product } from './product.entity';

@Entity('product_stock', { schema: 'inventory' })
export class ProductStock {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @OneToOne(() => Product, (product) => product.stock)
  @JoinColumn({ name: 'product_id' })
  product: Product;

  @Column('decimal', { precision: 19, scale: 4, default: 0, name: 'quantity_on_hand' })
  quantityOnHand: number;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamp' })
  updatedAt: Date;
}
