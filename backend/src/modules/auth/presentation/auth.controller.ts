import { Controller, Post, Body } from '@nestjs/common';
import { AuthService } from '../application/auth.service';
import { LoginDto } from '../dto/login.dto';
import { Public } from '../infrastructure/decorators/public.decorator';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Public()
  @Post('login')
  async login(@Body() loginDto: LoginDto) {
    return this.authService.login(loginDto);
  }
}
