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

  async findByFacilityId(facilityId: string, sinceDate: Date) {
    const query = this.model
      .find({ facilityId })
      .where({ createdAt: { $gte: sinceDate } })
      .sort({ createdAt: -1 });

    return query.exec();
  }
}
