import { Entity, PrimaryGeneratedColumn, Column } from 'typeorm';

@Entity('customers', { schema: 'sales' })
export class Customer {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ length: 100 })
  name: string;
}
