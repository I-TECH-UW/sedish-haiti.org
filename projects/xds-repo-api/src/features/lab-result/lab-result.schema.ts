import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

@Schema({ timestamps: true })
export class LabResult extends Document {
  @Prop({ required: true })
  facilityId: string;

  @Prop({ required: true, unique: true })
  labOrderId: string;

  @Prop({ required: true, unique: true })
  documentId: string;

  @Prop({ required: true })
  documentContents: string;

  @Prop({ required: true })
  hl7Contents: string;
}

export const LabResultSchema = SchemaFactory.createForClass(LabResult);