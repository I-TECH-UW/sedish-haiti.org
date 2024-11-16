import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { DAO } from '../../core/database/database.dao';
import { Notification, NotificationDocument } from './notification.schema';

@Injectable()
export class NotificationDAO extends DAO<NotificationDocument> {
  constructor(@InjectModel(Notification.name) model: Model<NotificationDocument>) {
    super(model);
  }

  async findUndelivered() {
    return this.model.find({ delivered: false }).exec();
  }

  async findDMQ() {
    return this.model.find({ dmq: true }).exec();
  }
}
