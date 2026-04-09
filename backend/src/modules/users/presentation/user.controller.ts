import {
  Body,
  Controller,
  Get,
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
  ApiNoContentResponse,
  ApiConflictResponse,
  ApiBadRequestResponse,
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
  async findAll(): Promise<UserResponseDto[]> {
    const users = await this.userService.listUsers();
    return users.map((user) => UserResponseDto.fromDomain(user));
  }

  @Get(':id')
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
  async findById(@Param('id') id: string): Promise<UserResponseDto> {
    const user = await this.userService.getUserById(id);
    return UserResponseDto.fromDomain(user);
  }

  @Get('by-email/:email')
  @ApiOperation({ summary: 'Buscar usuário por e-mail' })
  @ApiParam({
    name: 'email',
    description: 'Endereço de e-mail do usuário',
    example: 'exemplo@empresa.com',
  })
  @ApiOkResponse({
    description: 'Usuário encontrado com sucesso',
    type: UserResponseDto,
  })
  @ApiNotFoundResponse({
    description: 'Usuário não encontrado',
  })
  async findByEmail(@Param('email') email: string): Promise<UserResponseDto> {
    const user = await this.userService.getUserByEmail(email);
    return UserResponseDto.fromDomain(user);
  }

  @Post()
  @ApiOperation({ summary: 'Criar novo usuário' })
  @ApiBody({ type: CreateUserDto })
  @ApiResponse({
    status: 201,
    description: 'Usuário criado com sucesso',
    type: UserResponseDto,
  })
  @ApiBadRequestResponse({
    description: 'Dados inválidos enviados na requisição',
  })
  @ApiConflictResponse({
    description: 'Conflito: e-mail já cadastrado',
  })
  async create(@Body() createUserDto: CreateUserDto): Promise<UserResponseDto> {
    const user = await this.userService.createUser(createUserDto);
    return UserResponseDto.fromDomain(user);
  }

  @Patch(':id')
  @HttpCode(HttpStatus.OK)
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
  @ApiBadRequestResponse({
    description: 'Dados inválidos enviados na requisição',
  })
  async update(
    @Param('id') id: string,
    @Body() updateUserDto: UpdateUserDto,
  ): Promise<UserResponseDto> {
    const user = await this.userService.updateUser(id, updateUserDto);
    return UserResponseDto.fromDomain(user);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Remover usuário' })
  @ApiParam({
    name: 'id',
    description: 'Identificador único do usuário (UUID)',
  })
  @ApiNoContentResponse({
    description: 'Usuário removido com sucesso',
  })
  @ApiNotFoundResponse({
    description: 'Usuário não encontrado',
  })
  @ApiConflictResponse({
    description:
      'Conflito: usuário possui registros vinculados e não pode ser removido',
  })
  async remove(@Param('id') id: string): Promise<void> {
    await this.userService.deleteUser(id);
  }
}
