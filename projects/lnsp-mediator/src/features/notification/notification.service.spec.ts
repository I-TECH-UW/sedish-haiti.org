import { Test, TestingModule } from '@nestjs/testing';
import { NotificationServiceService } from './notification.service';

describe('NotificationServiceService', () => {
  let service: NotificationServiceService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [NotificationServiceService],
    }).compile();

    service = module.get<NotificationServiceService>(
      NotificationServiceService,
    );
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
