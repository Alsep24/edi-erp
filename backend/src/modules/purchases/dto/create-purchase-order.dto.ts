import {
  IsString, IsNotEmpty, IsOptional, IsUUID, IsArray,
  ValidateNested, IsNumber, Min, IsDateString,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';

export class CreatePurchaseOrderLineDto {
  @ApiProperty({ example: 'uuid-del-producto' })
  @IsUUID()
  productId: string;

  @ApiProperty({ example: 10 })
  @IsNumber() @Min(0.0001) @Type(() => Number)
  quantity: number;

  @ApiProperty({ example: 500.00 })
  @IsNumber() @Min(0) @Type(() => Number)
  unitCost: number;
}

export class CreatePurchaseOrderDto {
  @ApiProperty({ example: 'OC-2024-001' })
  @IsString() @IsNotEmpty()
  orderNumber: string;

  @ApiProperty({ example: 'uuid-empresa' })
  @IsUUID()
  companyId: string;

  @ApiProperty({ example: 'uuid-proveedor' })
  @IsUUID()
  vendorId: string;

  @ApiProperty({ example: '2024-01-15' })
  @IsDateString()
  orderDate: string;

  @ApiPropertyOptional({ example: '2024-01-30' })
  @IsOptional() @IsDateString()
  expectedDate?: string;

  @ApiPropertyOptional({ example: 'Pago anticipado' })
  @IsOptional() @IsString()
  notes?: string;

  @ApiProperty({ type: [CreatePurchaseOrderLineDto] })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CreatePurchaseOrderLineDto)
  lines: CreatePurchaseOrderLineDto[];
}
