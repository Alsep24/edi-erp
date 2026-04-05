import { Test, TestingModule } from '@nestjs/testing';
import { ProductsService } from './products.service';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Product } from '../entities/product.entity';
import { ProductStock } from '../entities/product-stock.entity';
import { ConflictException, NotFoundException } from '@nestjs/common';
import { PaginationDto } from '../../../common/dto/pagination.dto';

const mockProduct = {
  id: 'product-uuid-1',
  code: 'PROD-001',
  name: 'Laptop Test',
  salesPrice: 1299.99,
  category: 'Electrónica',
  unit: 'unit',
  isActive: true,
  stock: { quantityOnHand: 10 },
};

const mockProductRepo = {
  findOne: jest.fn(),
  find: jest.fn(),
  create: jest.fn(),
  save: jest.fn(),
  update: jest.fn(),
  createQueryBuilder: jest.fn(),
};

const mockStockRepo = {
  create: jest.fn(),
  save: jest.fn(),
  findOne: jest.fn(),
};

describe('ProductsService', () => {
  let service: ProductsService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ProductsService,
        { provide: getRepositoryToken(Product), useValue: mockProductRepo },
        { provide: getRepositoryToken(ProductStock), useValue: mockStockRepo },
      ],
    }).compile();

    service = module.get<ProductsService>(ProductsService);
    jest.clearAllMocks();
  });

  describe('create', () => {
    const dto = { code: 'PROD-002', name: 'Nuevo Producto', salesPrice: 50 };

    it('debería crear un producto y su stock inicial', async () => {
      mockProductRepo.findOne.mockResolvedValueOnce(null); // no existe
      mockProductRepo.create.mockReturnValue({ ...dto, id: 'new-uuid' });
      mockProductRepo.save.mockResolvedValue({ ...dto, id: 'new-uuid' });
      mockStockRepo.create.mockReturnValue({ quantityOnHand: 0 });
      mockStockRepo.save.mockResolvedValue({ quantityOnHand: 0 });
      // findOne al final del create
      mockProductRepo.findOne.mockResolvedValueOnce({ ...mockProduct, ...dto });

      const result = await service.create(dto as any);
      expect(mockStockRepo.save).toHaveBeenCalledTimes(1);
      expect(result.code).toBe('PROD-002');
    });

    it('debería lanzar ConflictException si el código ya existe', async () => {
      mockProductRepo.findOne.mockResolvedValue(mockProduct);
      await expect(service.create(dto as any)).rejects.toThrow(ConflictException);
    });
  });

  describe('findOne', () => {
    it('debería retornar el producto si existe', async () => {
      mockProductRepo.findOne.mockResolvedValue(mockProduct);
      const result = await service.findOne('product-uuid-1');
      expect(result.code).toBe('PROD-001');
    });

    it('debería lanzar NotFoundException si no existe', async () => {
      mockProductRepo.findOne.mockResolvedValue(null);
      await expect(service.findOne('nonexistent')).rejects.toThrow(NotFoundException);
    });
  });

  describe('remove', () => {
    it('debería desactivar el producto (soft delete)', async () => {
      mockProductRepo.findOne.mockResolvedValue(mockProduct);
      mockProductRepo.update.mockResolvedValue({});
      await service.remove('product-uuid-1');
      expect(mockProductRepo.update).toHaveBeenCalledWith('product-uuid-1', { isActive: false });
    });
  });
});
