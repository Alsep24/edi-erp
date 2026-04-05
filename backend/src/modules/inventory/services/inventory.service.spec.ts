import { Test, TestingModule } from '@nestjs/testing';
import { InventoryService } from './inventory.service';
import { getRepositoryToken } from '@nestjs/typeorm';
import { ProductStock } from '../entities/product-stock.entity';
import { Product } from '../entities/product.entity';
import { BadRequestException } from '@nestjs/common';

const mockProduct = { id: 'p1', name: 'Test Product', code: 'P001' };
const mockStock = { id: 's1', product: mockProduct, quantityOnHand: 10 };

const mockStockRepo = {
  findOne: jest.fn(),
  create: jest.fn(),
  save: jest.fn(),
};

const mockProductRepo = {
  findOne: jest.fn(),
};

describe('InventoryService', () => {
  let service: InventoryService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        InventoryService,
        { provide: getRepositoryToken(ProductStock), useValue: mockStockRepo },
        { provide: getRepositoryToken(Product), useValue: mockProductRepo },
      ],
    }).compile();

    service = module.get<InventoryService>(InventoryService);
    jest.clearAllMocks();
  });

  describe('adjustStock', () => {
    it('debería incrementar stock correctamente', async () => {
      mockStockRepo.findOne.mockResolvedValue({ ...mockStock });
      mockStockRepo.save.mockResolvedValue({ ...mockStock, quantityOnHand: 15 });
      const result = await service.adjustStock('p1', 5);
      expect(result.quantityOnHand).toBe(15);
    });

    it('debería decrementar stock correctamente', async () => {
      mockStockRepo.findOne.mockResolvedValue({ ...mockStock });
      mockStockRepo.save.mockResolvedValue({ ...mockStock, quantityOnHand: 7 });
      const result = await service.adjustStock('p1', -3);
      expect(result.quantityOnHand).toBe(7);
    });

    it('debería lanzar BadRequestException si el stock queda negativo', async () => {
      mockStockRepo.findOne.mockResolvedValue({ ...mockStock, quantityOnHand: 2 });
      await expect(service.adjustStock('p1', -5)).rejects.toThrow(BadRequestException);
    });

    it('debería crear stock si no existe', async () => {
      mockStockRepo.findOne.mockResolvedValue(null);
      mockProductRepo.findOne.mockResolvedValue(mockProduct);
      mockStockRepo.create.mockReturnValue({ product: mockProduct, quantityOnHand: 0 });
      mockStockRepo.save.mockResolvedValue({ product: mockProduct, quantityOnHand: 10 });
      const result = await service.adjustStock('p1', 10);
      expect(mockStockRepo.create).toHaveBeenCalledWith({ product: mockProduct, quantityOnHand: 0 });
      expect(result.quantityOnHand).toBe(10);
    });
  });
});
