import { Test, TestingModule } from '@nestjs/testing';
import { LabResultController } from './lab-result.controller';

describe('LabResultController', () => {
  let controller: LabResultController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [LabResultController],
    }).compile();

    controller = module.get<LabResultController>(LabResultController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
