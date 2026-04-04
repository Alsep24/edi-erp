import { IsNumber, IsNotEmpty, IsOptional, IsString } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';

export class AdjustStockDto {
  @ApiProperty({ example: 10, description: 'Cantidad a ajustar (positivo=entrada, negativo=salida)' })
  @IsNumber()
  @IsNotEmpty()
  @Type(() => Number)
  quantity: number;

  @ApiPropertyOptional({ example: 'Compra proveedor', description: 'Motivo del ajuste' })
  @IsOptional()
  @IsString()
  reason?: string;
}
