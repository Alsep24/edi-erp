import { Controller, Get, Post, Body, Patch, Param, Delete, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { ConfigurationsService } from '../services/configurations.service';
import { CreateConfigurationDto } from '../dto/create-configuration.dto';
import { UpdateConfigurationDto } from '../dto/update-configuration.dto';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../auth/decorators/roles.decorator';

@ApiTags('Configuraciones')
@Controller('configurations')
@UseGuards(JwtAuthGuard, RolesGuard)
@ApiBearerAuth()
export class ConfigurationsController {
  constructor(private readonly configurationsService: ConfigurationsService) {}

  @Post()
  @Roles('admin')
  @ApiOperation({ summary: 'Crear nueva configuración' })
  create(@Body() dto: CreateConfigurationDto) {
    return this.configurationsService.create(dto);
  }

  @Get()
  @ApiOperation({ summary: 'Obtener todas las configuraciones' })
  findAll() {
    return this.configurationsService.findAll();
  }

  @Get('company/:companyId')
  findByCompany(@Param('companyId') companyId: string) {
    return this.configurationsService.findByCompany(companyId);
  }

  @Get('key/:key')
  findByKey(@Param('key') key: string, @Query('companyId') companyId?: string) {
    return this.configurationsService.findByKey(key, companyId);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.configurationsService.findOne(id);
  }

  @Patch(':id')
  @Roles('admin')
  update(@Param('id') id: string, @Body() dto: UpdateConfigurationDto) {
    return this.configurationsService.update(id, dto);
  }

  @Delete(':id')
  @Roles('admin')
  remove(@Param('id') id: string) {
    return this.configurationsService.remove(id);
  }
}
