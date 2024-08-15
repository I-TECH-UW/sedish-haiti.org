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
Object.defineProperty(exports, "__esModule", { value: true });
exports.LabOrderService = void 0;
const common_1 = require("@nestjs/common");
const lab_order_schema_1 = require("./lab-order.schema");
const lab_order_dao_1 = require("./lab-order.dao");
let LabOrderService = class LabOrderService {
    constructor(labOrderDAO) {
        this.labOrderDAO = labOrderDAO;
    }
    async create(labOrder) {
        return this.labOrderDAO.create(labOrder);
    }
    async findById(documentId) {
        return this.labOrderDAO.findByDocumentId(documentId);
    }
    parseLabOrderDocument(xmlPayload) {
        const newLabOrder = new lab_order_schema_1.LabOrder();
        newLabOrder.documentId = xmlPayload.documentId;
        newLabOrder.labOrderId = xmlPayload.labOrderId;
        newLabOrder.facilityId = xmlPayload.facilityId;
        newLabOrder.documentContents = xmlPayload.documentContents;
        return newLabOrder;
    }
    async parseLabOrderRequest(xmlPayload) {
    }
};
exports.LabOrderService = LabOrderService;
exports.LabOrderService = LabOrderService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [lab_order_dao_1.LabOrderDAO])
], LabOrderService);
//# sourceMappingURL=lab-order.service.js.map