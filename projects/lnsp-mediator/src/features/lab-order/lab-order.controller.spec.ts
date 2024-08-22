import { Test, TestingModule } from '@nestjs/testing';
import { LabOrderController } from './lab-order.controller';

describe('LabOrderController', () => {
  let controller: LabOrderController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [LabOrderController],
    }).compile();

    controller = module.get<LabOrderController>(LabOrderController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
