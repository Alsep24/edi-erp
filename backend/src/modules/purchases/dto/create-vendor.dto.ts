import { IsString, IsNotEmpty, IsOptional, IsEmail, MaxLength } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateVendorDto {
  @ApiProperty({ example: 'Distribuidora XYZ' })
  @IsString() @IsNotEmpty() @MaxLength(100)
  name: string;

  @ApiPropertyOptional({ example: '800123456-1' })
  @IsOptional() @IsString() @MaxLength(30)
  taxId?: string;

  @ApiPropertyOptional({ example: 'ventas@xyz.com' })
  @IsOptional() @IsEmail() @MaxLength(100)
  email?: string;

  @ApiPropertyOptional({ example: '+57 300 000 0000' })
  @IsOptional() @IsString() @MaxLength(20)
  phone?: string;

  @ApiPropertyOptional({ example: 'Carrera 10 #20-30' })
  @IsOptional() @IsString() @MaxLength(200)
  address?: string;

  @ApiPropertyOptional({ example: 'Medellín' })
  @IsOptional() @IsString() @MaxLength(100)
  city?: string;

  @ApiPropertyOptional({ example: 'Colombia' })
  @IsOptional() @IsString() @MaxLength(100)
  country?: string;

  @ApiPropertyOptional({ example: '30 días' })
  @IsOptional() @IsString() @MaxLength(200)
  paymentTerms?: string;
}
