import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { LabOrder } from './schemas/lab-order.schema';
import { CreateLabOrderDto } from './dto/create-lab-order.dto';

@Injectable()
export class LabOrderService {
  constructor(@InjectModel(LabOrder.name) private labOrderModel: Model<LabOrder>) {}

  async create(createLabOrderDto: CreateLabOrderDto): Promise<LabOrder> {
    const labOrder = new this.labOrderModel(createLabOrderDto);
    return labOrder.save();
  }

  async findById(id: string): Promise<LabOrder> {
    return this.labOrderModel.findById(id).exec();
  }
}
