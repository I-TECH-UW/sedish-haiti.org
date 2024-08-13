import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { LabResult } from './schemas/lab-result.schema';
import { CreateLabResultDto } from './dto/create-lab-result.dto';

@Injectable()
export class LabResultService {
  constructor(@InjectModel(LabResult.name) private labResultModel: Model<LabResult>) {}

  async create(createLabResultDto: CreateLabResultDto): Promise<LabResult> {
    const labResult = new this.labResultModel(createLabResultDto);
    return labResult.save();
  }

  async findByLabOrderId(labOrderId: string): Promise<LabResult> {
    return this.labResultModel.findOne({ labOrderId }).exec();
  }
}