import { Controller, Delete, Get, Param, Query, Req } from '@nestjs/common';
import { AssignmentService } from '../application/assignment.service';
import { AssignmentResponseDto } from '../dto/assignment-response.dto';
import { BypassBlock } from '../infrastructure/decorators/bypass-block.decorator';
import { Roles } from '../../../modules/auth/infrastructure/decorators/roles.decorator';

@Controller('assignments')
export class AssignmentController {
  constructor(private readonly assignmentService: AssignmentService) {}

  @Get()
  @Roles('SUPERVISOR', 'ADMIN')
  async findAll(): Promise<AssignmentResponseDto[]> {
    const assignments = await this.assignmentService.listAssignments();
    return assignments.map((assignment) =>
      AssignmentResponseDto.fromDomain(assignment),
    );
  }

  @Get('mine')
  @BypassBlock()
  async findMine(
    @Req() req: any,
    @Query('status') status?: string,
  ): Promise<AssignmentResponseDto[]> {
    const assignments = await this.assignmentService.listMyAssignments(
      req.user.userId,
      status,
    );
    return assignments.map((a) => AssignmentResponseDto.fromDomain(a));
  }

  @Get(':id')
  async findById(@Param('id') id: string): Promise<AssignmentResponseDto> {
    const assignment = await this.assignmentService.getAssigmentDetails(id);
    return AssignmentResponseDto.fromDomain(assignment);
  }

  // @Post() — criação interna: assignments são gerados automaticamente pelo NotificationService
  // @Delete — mantido para administração

  @Delete(':id')
  async delete(@Param('id') id: string): Promise<void> {
    await this.assignmentService.deleteAssignment(id);
  }
}
