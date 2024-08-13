import { Test, TestingModule } from '@nestjs/testing';
import { LabResultService } from './lab-result.service';

describe('LabResultService', () => {
  let service: LabResultService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [LabResultService],
    }).compile();

    service = module.get<LabResultService>(LabResultService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
