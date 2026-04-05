import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, OneToOne } from 'typeorm';
import { ProductStock } from './product-stock.entity';

@Entity('products', { schema: 'inventory' })
export class Product {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ length: 20, unique: true })
  code: string;

  @Column({ length: 100 })
  name: string;

  @Column('decimal', { precision: 19, scale: 4, nullable: true })
  salesPrice: number | null;

  @Column({ length: 100, nullable: true })
  category: string | null;

  @Column({ type: 'text', nullable: true })
  description: string | null;

  @Column({ length: 20, nullable: true })
  unit: string | null;

  @Column('decimal', { precision: 19, scale: 4, nullable: true, name: 'min_stock' })
  minStock: number | null;

  @Column({ name: 'is_active', default: true })
  isActive: boolean;

  @OneToOne(() => ProductStock, (stock) => stock.product)
  stock: ProductStock;

  @CreateDateColumn({ name: 'created_at', type: 'timestamp' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamp' })
  updatedAt: Date;
}
