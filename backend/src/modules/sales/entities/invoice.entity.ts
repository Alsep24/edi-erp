import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, OneToMany, JoinColumn, CreateDateColumn, UpdateDateColumn } from 'typeorm';
import { Company } from '../../core/entities/company.entity';
import { Customer } from '../../sales/entities/customer.entity';
import { InvoiceLine } from './invoice-line.entity';

@Entity('invoices', { schema: 'sales' })
export class Invoice {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => Company)
  @JoinColumn({ name: 'company_id' })
  company: Company;

  @Column({ name: 'invoice_number', length: 20 })
  invoiceNumber: string;

  @ManyToOne(() => Customer, { nullable: true })
  @JoinColumn({ name: 'customer_id' })
  customer?: Customer;

  @Column({ name: 'invoice_date', type: 'date' })
  invoiceDate: string;

  @Column({ type: 'decimal', precision: 19, scale: 4, default: 0 })
  total: number;

  @OneToMany(() => InvoiceLine, line => line.invoice, { cascade: true })
  lines: InvoiceLine[];

  @CreateDateColumn({ name: 'created_at', type: 'timestamp' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamp' })
  updatedAt: Date;
}
