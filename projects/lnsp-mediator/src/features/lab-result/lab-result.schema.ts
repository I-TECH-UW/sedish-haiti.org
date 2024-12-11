import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument } from 'mongoose';

export type LabResultDocument = HydratedDocument<LabResult>;

@Schema({ timestamps: true })
export class LabResult {
  @Prop({ required: true, index: true })
  facilityId: string;

  @Prop({ required: true, unique: false, index: true })
  labOrderId: string;

  @Prop({ required: true })
  patientId: string;

  @Prop({ required: true })
  alternateVisitId: string;

  @Prop({ required: true, unique: true, index: true })
  documentId: string;

  @Prop({ required: true })
  documentContents: string;

  @Prop({ required: true })
  hl7Contents: string;

  @Prop({ required: true, default: 1, index: true })
  version: number;
}

export const LabResultSchema = SchemaFactory.createForClass(LabResult);

LabResultSchema.index({ labOrderId: 1, version: 1 }, { unique: true });
