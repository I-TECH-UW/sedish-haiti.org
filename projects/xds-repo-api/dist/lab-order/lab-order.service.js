"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.LabOrderService = void 0;
const common_1 = require("@nestjs/common");
const mongoose_1 = require("@nestjs/mongoose");
const mongoose_2 = require("mongoose");
const lab_order_schema_1 = require("./lab-order.schema");
let LabOrderService = class LabOrderService {
    constructor(labOrderModel) {
        this.labOrderModel = labOrderModel;
    }
    async create(createLabOrderDto) {
        const labOrder = new this.labOrderModel(createLabOrderDto);
        return labOrder.save();
    }
    async findById(id) {
        let result = this.labOrderModel.findById(id).exec();
        if (!result || result == null) {
            throw new Error('Lab Order not found');
        }
        return result;
    }
    async parseLabOrderDocument(xmlPayload) {
        return {
            documentId: xmlPayload.documentId,
            labOrderId: xmlPayload.labOrderId,
            facilityId: xmlPayload.facilityId,
            documentContents: xmlPayload.documentContents,
        };
    }
    async parseLabOrderRequest(xmlPayload) {
    }
};
exports.LabOrderService = LabOrderService;
exports.LabOrderService = LabOrderService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, mongoose_1.InjectModel)(lab_order_schema_1.LabOrder.name)),
    __metadata("design:paramtypes", [mongoose_2.Model])
], LabOrderService);
//# sourceMappingURL=lab-order.service.js.map