import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { DAO } from '../../core/database/database.dao';
import { LabResult, LabResultDocument } from './lab-result.schema';

@Injectable()
export class LabResultDAO extends DAO<LabResultDocument> {
  constructor(@InjectModel(LabResult.name) model: Model<LabResultDocument>) {
    super(model);
  }

  async findByFacilityId(facilityId: string) {
    return this.model.find({facilityId});
  }
}