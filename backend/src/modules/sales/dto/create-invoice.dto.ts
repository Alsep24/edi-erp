import {
  IsString, IsNotEmpty, IsOptional, IsUUID, IsArray,
  ValidateNested, IsNumber, Min, IsDateString,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';

export class CreateInvoiceLineDto {
  @ApiProperty({ example: 'uuid-del-producto' })
  @IsUUID()
  productId: string;

  @ApiProperty({ example: 2 })
  @IsNumber()
  @Min(0.0001)
  @Type(() => Number)
  quantity: number;

  @ApiProperty({ example: 1299.99 })
  @IsNumber()
  @Min(0)
  @Type(() => Number)
  unitPrice: number;
}

export class CreateInvoiceDto {
  @ApiProperty({ example: 'uuid-empresa' })
  @IsUUID()
  companyId: string;

  @ApiProperty({ example: 'FAC-2024-001' })
  @IsString()
  @IsNotEmpty()
  invoiceNumber: string;

  @ApiPropertyOptional({ example: 'uuid-cliente' })
  @IsOptional()
  @IsUUID()
  customerId?: string;

  @ApiProperty({ example: '2024-01-15' })
  @IsDateString()
  invoiceDate: string;

  @ApiProperty({ type: [CreateInvoiceLineDto] })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CreateInvoiceLineDto)
  lines: CreateInvoiceLineDto[];
}
