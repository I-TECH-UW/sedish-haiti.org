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
exports.LabOrderController = void 0;
const common_1 = require("@nestjs/common");
const lab_order_service_1 = require("./lab-order.service");
let LabOrderController = class LabOrderController {
    constructor(labOrderService) {
        this.labOrderService = labOrderService;
    }
    async create(xmlPayload) {
        let parsedData = this.labOrderService.parseLabOrderDocument(xmlPayload);
        const createLabOrderDto = {
            documentId: parsedData.documentId,
            labOrderId: parsedData.labOrderId,
            facilityId: parsedData.facilityId,
            documentContents: parsedData.documentContents,
        };
        return this.labOrderService.create(createLabOrderDto);
    }
    getLabOrderById(xmlPayload) {
        return this.labOrderService.findById(xmlPayload.labOrderId);
    }
};
exports.LabOrderController = LabOrderController;
__decorate([
    (0, common_1.Post)('create'),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], LabOrderController.prototype, "create", null);
__decorate([
    (0, common_1.Post)('getByID'),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], LabOrderController.prototype, "getLabOrderById", null);
exports.LabOrderController = LabOrderController = __decorate([
    (0, common_1.Controller)('lab-orders'),
    __metadata("design:paramtypes", [lab_order_service_1.LabOrderService])
], LabOrderController);
//# sourceMappingURL=lab-order.controller.js.map