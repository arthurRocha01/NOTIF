import { Test, TestingModule } from '@nestjs/testing';
import { AssigmentInterationController } from './assigment-interation.controller';

describe('AssigmentInterationController', () => {
  let controller: AssigmentInterationController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [AssigmentInterationController],
    }).compile();

    controller = module.get<AssigmentInterationController>(AssigmentInterationController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
