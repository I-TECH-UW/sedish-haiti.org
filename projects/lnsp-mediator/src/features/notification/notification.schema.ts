import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument } from 'mongoose';

export type NotificationDocument = HydratedDocument<Notification>;

@Schema({ timestamps: true })
export class Notification {
  @Prop({ required: true })
  targetUrl: string;

  @Prop({ required: true })
  documentId: string;

  @Prop({ required: true, default: false })
  delivered: boolean;

  @Prop({ required: true, default: false })
  dmq: boolean;

  @Prop({ required: true, default: 0 })
  retries: number;

  @Prop({ required: true, nullable: true, default: null })
  lastRetryAt: Date;
}

export const NotificationSchema = SchemaFactory.createForClass(Notification);
