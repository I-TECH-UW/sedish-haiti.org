import * as mongoose from 'mongoose';

import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument } from 'mongoose';

import { LabResult } from '../lab-result/lab-result.schema';

export type LabOrderDocument = HydratedDocument<LabOrder>;

@Schema()
export class LabOrder {
  @Prop({ required: true })
  documentId: string;

  @Prop({ required: true })
  labOrderId: string;

  @Prop({ required: true })
  facilityId: string;

  @Prop({ required: true })
  documentContents: string;

  @Prop()
  submittedAt: Date;

  @Prop()
  retrievedAt: Date;

  @Prop()
  resultedAt: Date;

  @Prop({ ref: 'LabResult', type: mongoose.Schema.Types.ObjectId })
  result: LabResult;
}