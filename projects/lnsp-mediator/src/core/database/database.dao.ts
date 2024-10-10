import {
  Model,
  FilterQuery,
  UpdateQuery,
  QueryOptions,
  SaveOptions,
} from 'mongoose';

export abstract class DAO<T> {
  constructor(protected readonly model: Model<T>) {}

  async create(doc: Partial<T>, options?: SaveOptions) {
    const createdDoc = new this.model(doc);
    return createdDoc.save(options);
  }

  async find(filter: FilterQuery<T> = {}, options?: QueryOptions) {
    return this.model.find(filter, null, options).lean().exec();
  }

  async findOne(filter: FilterQuery<T>, options?: QueryOptions) {
    return this.model.findOne(filter, null, options).lean().exec();
  }

  async updateOne(
    filter: FilterQuery<T>,
    update: UpdateQuery<T>,
    options?: QueryOptions,
  ) {
    return this.model
      .findOneAndUpdate(filter, update, {
        new: true,
        ...options,
      })
      .exec();
  }

  async deleteOne(filter: FilterQuery<T>, options?: QueryOptions) {
    return this.model.findOneAndDelete(filter, options).exec();
  }
}
