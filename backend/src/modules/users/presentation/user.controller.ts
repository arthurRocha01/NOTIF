import { Controller, Get } from '@nestjs/common';
import { ApiOkResponse, ApiTags } from '@nestjs/swagger';
import { UserService } from '../application/user.service';
import { UserResponseDto } from '../dto/user-response.dto';

@ApiTags('Users')
@Controller('users')
export class UserController {
  constructor(private readonly userService: UserService) {}

  @Get()
  @ApiOkResponse({
    description: 'Lista de usuários',
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
          sectorId: user.getSectorId()?.toString() ?? null,
          role: user.getRole(),
          createdAt: user.getCreatedAt(),
        }),
    );
  }
}
