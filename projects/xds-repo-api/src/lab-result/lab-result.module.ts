import { Module } from '@nestjs/common';
import { LabResultService } from './lab-result.service';
import { LabResultController } from './lab-result.controller';

@Module({
  providers: [LabResultService],
  controllers: [LabResultController]
})
export class LabResultModule {}
