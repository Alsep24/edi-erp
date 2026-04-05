import {
  Controller, Get, Post, Body, Param, Patch,
  UseGuards, ParseUUIDPipe, Query,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { PurchaseOrdersService } from '../services/purchase-orders.service';
import { CreatePurchaseOrderDto } from '../dto/create-purchase-order.dto';
import { PaginationDto } from '../../../common/dto/pagination.dto';

@ApiTags('purchases')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('purchase-orders')
export class PurchaseOrdersController {
  constructor(private readonly ordersService: PurchaseOrdersService) {}

  @ApiOperation({ summary: 'Create a new purchase order (draft)' })
  @Post()
  create(@Body() dto: CreatePurchaseOrderDto) {
    return this.ordersService.create(dto);
  }

  @ApiOperation({ summary: 'Get all purchase orders (paginated)' })
  @ApiQuery({ name: 'status', required: false, enum: ['draft', 'confirmed', 'received', 'cancelled'] })
  @Get()
  findAll(@Query() pagination: PaginationDto, @Query('status') status?: string) {
    return this.ordersService.findAll(pagination, status);
  }

  @ApiOperation({ summary: 'Get purchase order by ID' })
  @Get(':id')
  findOne(@Param('id', ParseUUIDPipe) id: string) {
    return this.ordersService.findOne(id);
  }

  @ApiOperation({ summary: 'Confirm a draft purchase order' })
  @Patch(':id/confirm')
  confirm(@Param('id', ParseUUIDPipe) id: string) {
    return this.ordersService.confirm(id);
  }

  @ApiOperation({ summary: 'Receive merchandise and update inventory automatically' })
  @Patch(':id/receive')
  receive(@Param('id', ParseUUIDPipe) id: string) {
    return this.ordersService.receive(id);
  }

  @ApiOperation({ summary: 'Cancel a purchase order' })
  @Patch(':id/cancel')
  cancel(@Param('id', ParseUUIDPipe) id: string) {
    return this.ordersService.cancel(id);
  }
}
