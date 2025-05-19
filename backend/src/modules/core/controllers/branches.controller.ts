import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Query } from '@nestjs/common';
import { BranchesService }     from '../services/branches.service';
import { CreateBranchDto }     from '../dto/create-branch.dto';
import { UpdateBranchDto }     from '../dto/update-branch.dto';
import { JwtAuthGuard }        from '../../auth/guards/jwt-auth.guard';
import { RolesGuard }          from '../../auth/guards/roles.guard';
import { Roles }               from '../../auth/decorators/roles.decorator';

import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';

@ApiTags('Sucursales')
@Controller('branches')
@UseGuards(JwtAuthGuard, RolesGuard)
@ApiBearerAuth()
export class BranchesController {
  constructor(private readonly branchesService: BranchesService) {}

  @Post()
  @Roles('admin')
  @ApiOperation({ summary: 'Crear nueva sucursal' })
  @ApiResponse({ status: 201, description: 'Sucursal creada exitosamente' })
  @ApiResponse({ status: 400, description: 'Datos inválidos' })
  create(@Body() createBranchDto: CreateBranchDto) {
    return this.branchesService.create(createBranchDto);
  }

  @Get()
  @ApiOperation({ summary: 'Obtener todas las sucursales' })
  @ApiResponse({ status: 200, description: 'Lista de sucursales obtenida exitosamente' })
  findAll() {
    return this.branchesService.findAll();
  }

  @Get('company/:companyId')
  @ApiOperation({ summary: 'Obtener sucursales por empresa' })
  @ApiResponse({ status: 200, description: 'Lista de sucursales obtenida exitosamente' })
  findByCompany(@Param('companyId') companyId: string) {
    return this.branchesService.findByCompany(companyId);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Obtener sucursal por ID' })
  @ApiResponse({ status: 200, description: 'Sucursal obtenida exitosamente' })
  @ApiResponse({ status: 404, description: 'Sucursal no encontrada' })
  findOne(@Param('id') id: string) {
    return this.branchesService.findOne(id);
  }

  @Patch(':id')
  @Roles('admin')
  @ApiOperation({ summary: 'Actualizar sucursal' })
  @ApiResponse({ status: 200, description: 'Sucursal actualizada exitosamente' })
  @ApiResponse({ status: 404, description: 'Sucursal no encontrada' })
  update(@Param('id') id: string, @Body() updateBranchDto: UpdateBranchDto) {
    return this.branchesService.update(id, updateBranchDto);
  }

  @Delete(':id')
  @Roles('admin')
  @ApiOperation({ summary: 'Eliminar sucursal' })
  @ApiResponse({ status: 200, description: 'Sucursal eliminada exitosamente' })
  @ApiResponse({ status: 404, description: 'Sucursal no encontrada' })
  remove(@Param('id') id: string) {
    return this.branchesService.remove(id);
  }
}
