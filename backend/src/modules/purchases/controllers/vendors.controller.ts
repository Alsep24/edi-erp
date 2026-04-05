import {
  Controller, Get, Post, Body, Patch, Param, Delete,
  UseGuards, ParseUUIDPipe, Query,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../auth/decorators/roles.decorator';
import { VendorsService } from '../services/vendors.service';
import { CreateVendorDto } from '../dto/create-vendor.dto';
import { PaginationDto } from '../../../common/dto/pagination.dto';

@ApiTags('purchases')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('vendors')
export class VendorsController {
  constructor(private readonly vendorsService: VendorsService) {}

  @ApiOperation({ summary: 'Create a new vendor' })
  @Post()
  create(@Body() dto: CreateVendorDto) {
    return this.vendorsService.create(dto);
  }

  @ApiOperation({ summary: 'Get all vendors (paginated)' })
  @ApiQuery({ name: 'search', required: false })
  @Get()
  findAll(@Query() pagination: PaginationDto, @Query('search') search?: string) {
    return this.vendorsService.findAll(pagination, search);
  }

  @ApiOperation({ summary: 'Get vendor by ID' })
  @Get(':id')
  findOne(@Param('id', ParseUUIDPipe) id: string) {
    return this.vendorsService.findOne(id);
  }

  @ApiOperation({ summary: 'Update vendor' })
  @Patch(':id')
  update(@Param('id', ParseUUIDPipe) id: string, @Body() dto: Partial<CreateVendorDto>) {
    return this.vendorsService.update(id, dto);
  }

  @ApiOperation({ summary: 'Deactivate vendor' })
  @Roles('admin')
  @Delete(':id')
  remove(@Param('id', ParseUUIDPipe) id: string) {
    return this.vendorsService.remove(id);
  }
}
