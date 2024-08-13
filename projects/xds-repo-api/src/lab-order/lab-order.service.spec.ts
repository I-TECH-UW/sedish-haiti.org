import { Test, TestingModule } from '@nestjs/testing';
import { LabOrderService } from './lab-order.service';

describe('LabOrderService', () => {
  let service: LabOrderService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [LabOrderService],
    }).compile();

    service = module.get<LabOrderService>(LabOrderService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
