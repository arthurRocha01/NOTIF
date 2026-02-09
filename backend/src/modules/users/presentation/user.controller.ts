import {
  Body,
  Controller,
  Get,
  NotFoundException,
  Param,
  Patch,
  Post,
  HttpCode,
  Delete,
  HttpStatus,
} from '@nestjs/common';
import {
  ApiOkResponse,
  ApiOperation,
  ApiResponse,
  ApiTags,
  ApiParam,
  ApiBody,
  ApiNotFoundResponse,
} from '@nestjs/swagger';
import { UserService } from '../application/user.service';
import { UserResponseDto } from '../dto/user-response.dto';
import { CreateUserDto } from '../dto/create-user.dto';
import { UpdateUserDto } from '../dto/update-user.dto';

@ApiTags('Users')
@Controller('users')
export class UserController {
  constructor(private readonly userService: UserService) {}

  @Get()
  @ApiOperation({ summary: 'Listar todos os usuários' })
  @ApiOkResponse({
    description: 'Lista de usuários retornada com sucesso',
    type: UserResponseDto,
    isArray: true,
  })
  async getAllUsers(): Promise<UserResponseDto[]> {
    const users = await this.userService.getAllUsers();

    return users.map(
      (user) =>
        new UserResponseDto({
          id: user.getId().toString(),
          name: user.getName(),
          email: user.getEmail(),
          password: user.getPassword(),
          sectorId: user.getSectorId().toString(),
          role: user.getRole(),
          createdAt: user.getCreatedAt(),
        }),
    );
  }

  @Get('id/:id')
  @ApiOperation({ summary: 'Buscar usuário por ID' })
  @ApiParam({
    name: 'id',
    description: 'Identificador único do usuário (UUID)',
    example: 'a1b2c3d4-e5f6-7890-1234-56789abcdef0',
  })
  @ApiOkResponse({
    description: 'Usuário encontrado com sucesso',
    type: UserResponseDto,
  })
  @ApiNotFoundResponse({
    description: 'Usuário não encontrado',
  })
  async getUserById(@Param('id') id: string): Promise<UserResponseDto> {
    const user = await this.userService.getUserById(id);

    if (!user) {
      throw new NotFoundException('User not found');
    }

    return new UserResponseDto({
      id: user.getId().toString(),
      name: user.getName(),
      email: user.getEmail(),
      password: user.getPassword(),
      sectorId: user.getSectorId(),
      role: user.getRole(),
      createdAt: user.getCreatedAt(),
    });
  }

  @Get('email/:email')
  @ApiOperation({ summary: 'Buscar usuário por Email' })
  @ApiParam({
    name: 'email',
    description: 'Identificador único do usuário (Email)',
    example: 'exemplo@gmail.com',
  })
  @ApiOkResponse({
    description: 'Usuário encontrado com sucesso',
    type: UserResponseDto,
  })
  @ApiNotFoundResponse({
    description: 'Usuário não encontrado',
  })
  async getUserByEmail(
    @Param('email') email: string,
  ): Promise<UserResponseDto> {
    const user = await this.userService.getUserByEmail(email);
    if (!user) {
      throw new NotFoundException('Usuário não encontrado');
    }

    return new UserResponseDto({
      id: user.getId().toString(),
      name: user.getName(),
      email: user.getEmail(),
      password: user.getPassword(),
      sectorId: user.getSectorId(),
      role: user.getRole(),
      createdAt: user.getCreatedAt(),
    });
  }

  @Post()
  @ApiOperation({ summary: 'Criar novo usuário' })
  @ApiBody({ type: CreateUserDto })
  @ApiResponse({
    status: 201,
    description: 'Usuário criado com sucesso',
    type: UserResponseDto,
  })
  @ApiResponse({
    status: 400,
    description: 'Dados inválidos enviados na requisição',
  })
  async create(@Body() createUserDto: CreateUserDto): Promise<UserResponseDto> {
    const user = await this.userService.registerUser(createUserDto);

    return new UserResponseDto({
      id: user.getId().toString(),
      name: user.getName(),
      email: user.getEmail(),
      password: user.getPassword(),
      sectorId: user.getSectorId(),
      role: user.getRole(),
      createdAt: user.getCreatedAt(),
    });
  }

  @Patch(':id')
  @HttpCode(200)
  @ApiOperation({ summary: 'Atualizar dados do usuário' })
  @ApiParam({
    name: 'id',
    description: 'Identificador único do usuário (UUID)',
  })
  @ApiBody({ type: UpdateUserDto })
  @ApiOkResponse({
    description: 'Usuário atualizado com sucesso',
    type: UserResponseDto,
  })
  @ApiNotFoundResponse({
    description: 'Usuário não encontrado',
  })
  async update(
    @Param('id') id: string,
    @Body() updateUserDto: UpdateUserDto,
  ): Promise<UserResponseDto> {
    const user = await this.userService.updateUser(id, updateUserDto);

    if (!user) {
      throw new NotFoundException('User not found');
    }

    return new UserResponseDto({
      id: user.getId().toString(),
      name: user.getName(),
      email: user.getEmail(),
      password: user.getPassword(),
      sectorId: user.getSectorId(),
      role: user.getRole(),
      createdAt: user.getCreatedAt(),
    });
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT) // Retorna 204 (Sucesso sem conteúdo)
  @ApiOperation({ summary: 'Remove um usuário do sistema' })
  @ApiResponse({
    status: 204,
    description: 'Usuário removido com sucesso.',
  })
  @ApiResponse({
    status: 404,
    description: 'Usuário não encontrado.',
  })
  @ApiResponse({
    status: 409,
    description:
      'Conflito: Usuário tem registros vinculados e não pode ser apagado.',
  })
  async remove(@Param('id') id: string) {
    return this.userService.deleteUser(id);
  }
}
