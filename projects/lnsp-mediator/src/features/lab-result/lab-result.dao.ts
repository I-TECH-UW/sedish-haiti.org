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

  async findByFacilityId(
    facilityId: string,
    sinceDate: Date,
  ) {
    const query = this.model
      .find({ facilityId })
      .sort({ createdAt: -1 })
      .where('createdAt').gte(sinceDate);

    // TODO: Figure out why can't filter by Date
    // if (afterDateTime) {
    //   query.where('createdAt').gte(afterDateTime);
    // }

    return query.exec();
  }
}
