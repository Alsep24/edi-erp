import { Test, TestingModule } from '@nestjs/testing';
import { AuthService } from './auth.service';
import { UsersService } from '../../users/services/users.service';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { UnauthorizedException } from '@nestjs/common';
import * as bcrypt from 'bcrypt';

const mockUser = {
  id: 'user-uuid-1',
  username: 'testuser',
  email: 'test@example.com',
  passwordHash: '',
  firstName: 'Test',
  lastName: 'User',
  isAdmin: false,
  isActive: true,
  roles: [],
};

const mockUsersService = {
  findByUsername: jest.fn(),
  findOne: jest.fn(),
};

const mockJwtService = {
  signAsync: jest.fn().mockResolvedValue('mock-token'),
};

const mockConfigService = {
  get: jest.fn((key: string) => {
    const config: Record<string, string> = {
      'jwt.expiresIn': '1d',
      'jwt.refreshExpiresIn': '7d',
      'jwt.secret': 'test-secret',
    };
    return config[key];
  }),
};

describe('AuthService', () => {
  let service: AuthService;

  beforeAll(async () => {
    // Generar hash real para el test
    mockUser.passwordHash = await bcrypt.hash('password123', 10);
  });

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        { provide: UsersService, useValue: mockUsersService },
        { provide: JwtService, useValue: mockJwtService },
        { provide: ConfigService, useValue: mockConfigService },
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);
    jest.clearAllMocks();
  });

  describe('validateUser', () => {
    it('debería retornar el usuario si las credenciales son correctas', async () => {
      mockUsersService.findByUsername.mockResolvedValue(mockUser);
      const result = await service.validateUser('testuser', 'password123');
      expect(result).toEqual(mockUser);
    });

    it('debería retornar null si el usuario no existe', async () => {
      mockUsersService.findByUsername.mockResolvedValue(null);
      const result = await service.validateUser('noexiste', 'password123');
      expect(result).toBeNull();
    });

    it('debería retornar null si la contraseña es incorrecta', async () => {
      mockUsersService.findByUsername.mockResolvedValue(mockUser);
      const result = await service.validateUser('testuser', 'wrongpassword');
      expect(result).toBeNull();
    });
  });

  describe('login', () => {
    it('debería retornar tokens y datos del usuario al loguearse correctamente', async () => {
      mockUsersService.findByUsername.mockResolvedValue(mockUser);
      const result = await service.login({ username: 'testuser', password: 'password123' });
      expect(result).toHaveProperty('accessToken');
      expect(result).toHaveProperty('refreshToken');
      expect(result.user).toMatchObject({ username: 'testuser', email: 'test@example.com' });
    });

    it('debería lanzar UnauthorizedException si las credenciales son incorrectas', async () => {
      mockUsersService.findByUsername.mockResolvedValue(null);
      await expect(service.login({ username: 'bad', password: 'bad' }))
        .rejects.toThrow(UnauthorizedException);
    });
  });

  describe('getProfile', () => {
    it('debería retornar el perfil sin passwordHash', async () => {
      mockUsersService.findOne.mockResolvedValue(mockUser);
      const result = await service.getProfile(mockUser.id);
      expect(result).not.toHaveProperty('passwordHash');
      expect(result).toHaveProperty('username', 'testuser');
    });

    it('debería lanzar UnauthorizedException si el usuario no existe', async () => {
      mockUsersService.findOne.mockResolvedValue(null);
      await expect(service.getProfile('nonexistent-id')).rejects.toThrow(UnauthorizedException);
    });
  });

  describe('logout', () => {
    it('debería retornar mensaje de éxito', () => {
      const result = service.logout();
      expect(result.message).toContain('Logged out');
    });
  });
});
