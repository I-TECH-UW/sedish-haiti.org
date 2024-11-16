import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument, Schema as MongooseSchema, Types } from 'mongoose';

export type NotificationDocument = HydratedDocument<Notification>;

@Schema({ timestamps: true })
export class Notification {
  @Prop({ type: MongooseSchema.Types.ObjectId, default: () => new Types.ObjectId() })
  _id: Types.ObjectId;

  @Prop({ required: true })
  targetUrl: string;

  @Prop({ required: true })
  documentId: string;

  @Prop({ required: true, default: false, index: true })
  delivered: boolean;

  @Prop({ required: true, default: false, index: true })
  dmq: boolean;

  @Prop({ required: true, default: 0, index: true })
  retries: number;

  @Prop({ required: true, nullable: true })
  lastRetryAt: Date;
}

export const NotificationSchema = SchemaFactory.createForClass(Notification);
