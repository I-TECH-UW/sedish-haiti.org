import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument } from 'mongoose';

export type LabResultDocument = HydratedDocument<LabResult>;

@Schema({ timestamps: true })
export class LabResult {
  @Prop({ required: true })
  facilityId: string;

  @Prop({ required: true, unique: true })
  labOrderId: string;

  @Prop({ required: true })
  patientId: string;

  @Prop({ required: true })
  alternateVisitId: string;

  @Prop({ required: true, unique: true })
  documentId: string;

  @Prop({ required: true })
  documentContents: string;

  @Prop({ required: true })
  hl7Contents: string;
}

export const LabResultSchema = SchemaFactory.createForClass(LabResult);
