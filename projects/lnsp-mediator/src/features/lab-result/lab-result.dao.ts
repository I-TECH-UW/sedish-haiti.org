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

  async findByLabOrderId(labOrderId: string): Promise<LabResultDocument | null> {
    return this.model.findOne({ labOrderId }).sort({ version: -1 }).exec();
  }

  async findByFacilityId(facilityId: string, sinceDate: Date) {
    return this.model.aggregate([
      {
        $match: {
          facilityId: facilityId,
          createdAt: { $gte: sinceDate },
        },
      },
      {
        $sort: { version: -1, createdAt: -1 },
      },
      {
        $group: {
          _id: "$labOrderId",
          doc: { $first: "$$ROOT" },
        },
      },
      {
        $replaceRoot: { newRoot: "$doc" },
      },
      {
        $sort: { createdAt: -1 },
      },
    ]).exec();
  }
}
