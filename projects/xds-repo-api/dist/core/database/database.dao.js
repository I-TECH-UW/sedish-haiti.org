"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.DAO = void 0;
class DAO {
    constructor(model) {
        this.model = model;
    }
    async create(doc, options) {
        const createdDoc = new this.model(doc);
        return createdDoc.save(options);
    }
    async find(filter = {}, options) {
        return this.model.find(filter, null, options).lean();
    }
    async findOne(filter, options) {
        return this.model.findOne(filter, null, options).lean();
    }
    async updateOne(filter, update, options) {
        return this.model.findOneAndUpdate(filter, update, { new: true, ...options });
    }
    async deleteOne(filter, options) {
        return this.model.findOneAndDelete(filter, options);
    }
}
exports.DAO = DAO;
//# sourceMappingURL=database.dao.js.map