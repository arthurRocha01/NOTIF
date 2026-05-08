import {
  Controller,
  Delete,
  Get,
  Param,
  ParseUUIDPipe,
  Query,
  Req,
} from '@nestjs/common';
import { AssignmentService } from '../application/assignment.service';
import { AssignmentResponseDto } from '../dto/assignment-response.dto';
import { AlertResponseDto } from '../dto/alert-response.dto';
import { BypassBlock } from '../infrastructure/decorators/bypass-block.decorator';
import { Roles } from '../../../modules/auth/infrastructure/decorators/roles.decorator';
import type { AuthenticatedRequest } from '../../../modules/auth/domain/authenticated-request.interface';

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
    @Req() req: AuthenticatedRequest,
    @Query('status') status?: string,
  ): Promise<AlertResponseDto[]> {
    const rows = await this.assignmentService.listMyAlerts(
      req.user.userId,
      status,
    );
    return rows.map(({ assignment, notification }) =>
      AlertResponseDto.fromDomain(assignment, notification),
    );
  }

  @Get('inbox-summary')
  @BypassBlock()
  async inboxSummary(@Req() req: AuthenticatedRequest) {
    return this.assignmentService.getInboxSummary(req.user.userId);
  }

  @Get(':id')
  async findById(@Param('id') id: string): Promise<AssignmentResponseDto> {
    const assignment = await this.assignmentService.getAssignmentDetails(id);
    return AssignmentResponseDto.fromDomain(assignment);
  }

  @Delete(':id')
  async delete(@Param('id', ParseUUIDPipe) id: string): Promise<void> {
    await this.assignmentService.deleteAssignment(id);
  }
}
