import { Body, Controller, Delete, Get, Param, ParseUUIDPipe, Patch, Post, Req } from '@nestjs/common';
import { UserService } from '../application/user.service';
import { UserResponseDto } from '../dto/user-response.dto';
import { UserProfileDto } from '../dto/user-profile.dto';
import { CreateUserDto } from '../dto/create-user.dto';
import { UpdateUserDto } from '../dto/update-user.dto';
import { Public } from '../../../modules/auth/infrastructure/decorators/public.decorator';
import { BypassBlock } from '../../../modules/assignments/infrastructure/decorators/bypass-block.decorator';
import { Roles } from '../../../modules/auth/infrastructure/decorators/roles.decorator';
import type { AuthenticatedRequest } from '../../../modules/auth/domain/authenticated-request.interface';

@Controller('users')
export class UserController {
  constructor(private readonly userService: UserService) {}

  @Get()
  @Roles('SUPERVISOR', 'ADMIN')
  async findAll(): Promise<UserResponseDto[]> {
    const users = await this.userService.listUsers();
    return users.map((user) => UserResponseDto.fromDomain(user));
  }

  @Get('profile')
  @BypassBlock()
  async profile(@Req() req: AuthenticatedRequest): Promise<UserProfileDto> {
    return this.userService.getUserProfile(req.user.userId);
  }

  @Patch('fcm-token')
  @BypassBlock()
  async updateFcmToken(
    @Req() req: AuthenticatedRequest,
    @Body('fcmToken') fcmToken: string,
  ): Promise<void> {
    await this.userService.updateUser(req.user.userId, { fcmToken });
  }

  @Patch('password')
  @BypassBlock()
  async updatePassword(
    @Req() req: AuthenticatedRequest,
    @Body('password') password: string,
  ): Promise<void> {
    await this.userService.updateUser(req.user.userId, { password });
  }

  @Get(':id')
  async findById(@Param('id') id: string): Promise<UserResponseDto> {
    const user = await this.userService.getUserById(id);
    return UserResponseDto.fromDomain(user);
  }

  @Public()
  @Post()
  async create(@Body() createUserDto: CreateUserDto): Promise<UserResponseDto> {
    const user = await this.userService.createUser(createUserDto);
    return UserResponseDto.fromDomain(user);
  }

  @Patch(':id')
  @BypassBlock()
  async update(
    @Param('id') id: string,
    @Body() updateUserDto: UpdateUserDto,
  ): Promise<UserResponseDto> {
    const user = await this.userService.updateUser(id, updateUserDto);
    return UserResponseDto.fromDomain(user);
  }

  @Delete(':id')
  @Roles('ADMIN')
  async remove(@Param('id', ParseUUIDPipe) id: string): Promise<void> {
    await this.userService.deleteUser(id);
  }
}
