import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { LabResult } from './lab-result.schema';
import { CreateLabResultDto } from './dto/create-lab-result.dto';

@Injectable()
export class LabResultService {
  constructor(@InjectModel(LabResult.name) private labResultModel: Model<LabResult>) {}

  async create(createLabResultDto: CreateLabResultDto): Promise<LabResult> {
    // Create lab result and connect with lab order
    
    const labResult = new this.labResultModel(createLabResultDto);
    return labResult.save();
  }

  async findByLabOrderId(labOrderId: string): Promise<LabResult | null> {
    return this.labResultModel.findOne({ labOrderId }).exec();
  }

  async findAllByFacilityId(facilityId: string): Promise<LabResult[]> {
      return this.labResultModel.find({ facilityId }).exec();
  }

  async parseLabResultDocument(xmlPayload: any): Promise<any> {
  

  }

  async parseLabResultRequest(xmlPayload: any): Promise<any> {
    
  }
}