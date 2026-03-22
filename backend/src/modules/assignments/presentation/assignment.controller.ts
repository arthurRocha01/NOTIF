import { Body, Controller, Delete, Get, Param, Post } from '@nestjs/common';
import { AssignmentService } from '../application/assignment.service';
import { AssignmentResponseDto } from '../dto/assignment-response.dto';
import { CreateAssignmentDto } from '../dto/create-assignment.dto';

@Controller('assignments')
export class AssignmentController {
  constructor(private readonly assignmentService: AssignmentService) {}

  @Get()
  async findAll(): Promise<AssignmentResponseDto[]> {
    const assignments = await this.assignmentService.listAssignments();
    return assignments.map((assignment) =>
      AssignmentResponseDto.fromDomain(assignment),
    );
  }

  @Get(':id')
  async findById(@Param('id') id: string): Promise<AssignmentResponseDto> {
    const assignment = await this.assignmentService.getAssigmentDetails(id);
    return AssignmentResponseDto.fromDomain(assignment);
  }

  @Get('user/:userId')
  async findByUserId(
    @Param('userId') userId: string,
  ): Promise<AssignmentResponseDto[]> {
    const assignments =
      await this.assignmentService.listPeddingDeliveries(userId);
    return assignments.map((assigment) =>
      AssignmentResponseDto.fromDomain(assigment),
    );
  }

  @Post()
  async create(
    @Body() dto: CreateAssignmentDto,
  ): Promise<AssignmentResponseDto> {
    console.log(dto);
    const assignment = await this.assignmentService.createAssignment(dto);
    return AssignmentResponseDto.fromDomain(assignment);
  }

  @Delete(':id')
  async delete(@Param('id') id: string): Promise<void> {
    await this.assignmentService.deleteAssignment(id);
  }
}
