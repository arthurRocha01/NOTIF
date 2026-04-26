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
import { Public } from '../../../modules/auth/infrastructure/decorators/public.decorator';
import { BypassBlock } from '../../../modules/assignments/infrastructure/decorators/bypass-block.decorator';
import { Roles } from '../../../modules/auth/infrastructure/decorators/roles.decorator';

@Controller('users')
export class UserController {
  constructor(private readonly userService: UserService) {}

  @Get()
  @Roles('SUPERVISOR', 'ADMIN')
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
  @BypassBlock()
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
  @Roles('ADMIN')
  async remove(@Param('id') id: string): Promise<void> {
    await this.userService.deleteUser(id);
  }
}
