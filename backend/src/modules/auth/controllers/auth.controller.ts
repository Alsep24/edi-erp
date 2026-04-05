import { Body, Controller, Get, Post, Request, Response, UseGuards } from '@nestjs/common';
import { Response as Res } from 'express';
import { Throttle, SkipThrottle } from '@nestjs/throttler';
import { AuthService } from '../services/auth.service';
import { LoginDto } from '../dto/login.dto';
import { RefreshTokenDto } from '../dto/refresh-token.dto';
import { JwtAuthGuard } from '../guards/jwt-auth.guard';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';

@ApiTags('auth')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @ApiOperation({ summary: 'Login with username and password' })
  @Throttle({ default: { ttl: 60000, limit: 5 } })
  @Post('login')
  async login(@Body() dto: LoginDto, @Response({ passthrough: true }) res: Res) {
    const result = await this.authService.login(dto);
    // Guardar refreshToken en cookie HTTP-only
    res.cookie('refresh_token', result.refreshToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'strict',
      maxAge: 7 * 24 * 60 * 60 * 1000, // 7 días
      path: '/api/auth',
    });
    const { refreshToken: _, ...response } = result;
    return response;
  }

  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get current user profile' })
  @UseGuards(JwtAuthGuard)
  @Get('profile')
  async profile(@Request() req) {
    return this.authService.getProfile(req.user.id);
  }

  @ApiBearerAuth()
  @ApiOperation({ summary: 'Logout current session' })
  @SkipThrottle()
  @UseGuards(JwtAuthGuard)
  @Post('logout')
  async logout(@Response({ passthrough: true }) res: Res) {
    res.clearCookie('refresh_token', { path: '/api/auth' });
    return this.authService.logout();
  }

  @ApiOperation({ summary: 'Refresh access token using cookie' })
  @SkipThrottle()
  @Post('refresh')
  async refresh(@Request() req, @Body() dto: RefreshTokenDto) {
    const token = req.cookies?.refresh_token || dto.refreshToken;
    return this.authService.refreshToken(token);
  }
}
