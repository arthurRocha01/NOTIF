import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  Delete,
} from '@nestjs/common';
import { UserService } from '../application/user.service';
import { UserResponseDto } from '../dto/user-response.dto';
import { CreateUserDto } from '../dto/create-user.dto';
import { UpdateUserDto } from '../dto/update-user.dto';
import { Public } from 'src/modules/auth/infrastructure/decorators/public.decorator';

@Controller('users')
export class UserController {
  constructor(private readonly userService: UserService) {}

  @Get()
  async findAll(): Promise<UserResponseDto[]> {
    const users = await this.userService.listUsers();
    return users.map((user) => UserResponseDto.fromDomain(user));
  }

  @Get(':id')
  async findById(@Param('id') id: string): Promise<UserResponseDto> {
    const user = await this.userService.getUserById(id);
    return UserResponseDto.fromDomain(user);
  }

  @Get('by-email/:email')
  async findByEmail(@Param('email') email: string): Promise<UserResponseDto> {
    const user = await this.userService.getUserByEmail(email);
    return UserResponseDto.fromDomain(user);
  }

  @Public()
  @Post()
  async create(@Body() createUserDto: CreateUserDto): Promise<UserResponseDto> {
    const user = await this.userService.createUser(createUserDto);
    return UserResponseDto.fromDomain(user);
  }

  @Patch(':id')
  async update(
    @Param('id') id: string,
    @Body() updateUserDto: UpdateUserDto,
  ): Promise<UserResponseDto> {
    const user = await this.userService.updateUser(id, updateUserDto);
    return UserResponseDto.fromDomain(user);
  }

  @Delete(':id')
  async remove(@Param('id') id: string): Promise<void> {
    await this.userService.deleteUser(id);
  }

  @Patch(':id/fcm-token')
  updateFcmToken(@Param('id') id: string, @Body('fcmToken') fcmToken: string) {
    return this.userService.updateFcmToken(id, fcmToken);
  }
}
