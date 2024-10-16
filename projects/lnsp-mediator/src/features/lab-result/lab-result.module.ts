import { Module } from '@nestjs/common';
import { LabResultService } from './lab-result.service';
import { LabResultController } from './lab-result.controller';
import { MongooseModule } from '@nestjs/mongoose';
import { LabResult, LabResultSchema } from './lab-result.schema';
import { LabResultDAO } from './lab-result.dao';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: LabResult.name, schema: LabResultSchema },
    ]),
  ],
  providers: [LabResultDAO, LabResultService],
  controllers: [LabResultController],
  exports: [LabResultService, LabResultDAO],
})
export class LabResultModule {}
