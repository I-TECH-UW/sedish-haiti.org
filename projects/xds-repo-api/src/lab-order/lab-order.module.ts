import { Module } from '@nestjs/common';
import { LabOrderService } from './lab-order.service';
import { LabOrderController } from './lab-order.controller';

@Module({
  providers: [LabOrderService],
  controllers: [LabOrderController]
})
export class LabOrderModule {}
