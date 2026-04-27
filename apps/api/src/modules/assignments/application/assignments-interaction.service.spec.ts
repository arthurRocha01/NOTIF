import { Test, TestingModule } from '@nestjs/testing';
import { AssignmentsInteractionService } from './assignments-interaction.service';

describe('AssignmentsInteractionService', () => {
  let service: AssignmentsInteractionService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [AssignmentsInteractionService],
    }).compile();

    service = module.get<AssignmentsInteractionService>(AssignmentsInteractionService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
