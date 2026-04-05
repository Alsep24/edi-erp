import { IsString, IsNotEmpty, MinLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class ChangePasswordDto {
  @ApiProperty({ example: 'myOldPassword123', description: 'Contraseña actual' })
  @IsString()
  @IsNotEmpty()
  currentPassword: string;

  @ApiProperty({ example: 'myNewPassword456!', description: 'Nueva contraseña (mín. 8 caracteres)' })
  @IsString()
  @IsNotEmpty()
  @MinLength(8)
  newPassword: string;
}
