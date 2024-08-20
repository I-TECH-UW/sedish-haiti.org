import { Test, TestingModule } from '@nestjs/testing';
import { Hl7Service } from './hl7.service';

describe('Hl7Service', () => {
  let service: Hl7Service;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [Hl7Service],
    }).compile();

    service = module.get<Hl7Service>(Hl7Service);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
