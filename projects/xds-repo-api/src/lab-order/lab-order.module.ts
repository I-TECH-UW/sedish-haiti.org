import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { LabOrderService } from './lab-order.service';
import { LabOrderController } from './lab-order.controller';
import { LabOrder, LabOrderSchema } from './lab-order.schema';

@Module({
  imports: [
    MongooseModule.forFeature([{ name: LabOrder.name, schema: LabOrderSchema }]),
  ],
  providers: [LabOrderService],
  controllers: [LabOrderController]
})
export class LabOrderModule {}
