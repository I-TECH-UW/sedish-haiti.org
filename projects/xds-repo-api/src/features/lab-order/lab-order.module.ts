import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { LabOrderService } from './lab-order.service';
import { LabOrderController } from './lab-order.controller';
import { LabOrder, LabOrderSchema } from './lab-order.schema';
import { LabOrderDAO } from './lab-order.dao';

@Module({
  imports: [
    MongooseModule.forFeature([{ name: LabOrder.name, schema: LabOrderSchema }]),
  ],
  providers: [LabOrderDAO, LabOrderService],
  controllers: [LabOrderController]
})
export class LabOrderModule {}
