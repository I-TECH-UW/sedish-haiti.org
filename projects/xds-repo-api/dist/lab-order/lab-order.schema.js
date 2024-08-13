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
exports.LabOrder = void 0;
const mongoose = require("mongoose");
const mongoose_1 = require("@nestjs/mongoose");
const lab_result_schema_1 = require("../lab-result/lab-result.schema");
let LabOrder = class LabOrder {
};
exports.LabOrder = LabOrder;
__decorate([
    (0, mongoose_1.Prop)({ required: true }),
    __metadata("design:type", String)
], LabOrder.prototype, "documentId", void 0);
__decorate([
    (0, mongoose_1.Prop)({ required: true }),
    __metadata("design:type", String)
], LabOrder.prototype, "labOrderId", void 0);
__decorate([
    (0, mongoose_1.Prop)({ required: true }),
    __metadata("design:type", String)
], LabOrder.prototype, "facilityId", void 0);
__decorate([
    (0, mongoose_1.Prop)({ required: true }),
    __metadata("design:type", String)
], LabOrder.prototype, "documentContents", void 0);
__decorate([
    (0, mongoose_1.Prop)(),
    __metadata("design:type", Date)
], LabOrder.prototype, "submittedAt", void 0);
__decorate([
    (0, mongoose_1.Prop)(),
    __metadata("design:type", Date)
], LabOrder.prototype, "retrievedAt", void 0);
__decorate([
    (0, mongoose_1.Prop)(),
    __metadata("design:type", Date)
], LabOrder.prototype, "resultedAt", void 0);
__decorate([
    (0, mongoose_1.Prop)({ ref: 'LabResult', type: mongoose.Schema.Types.ObjectId }),
    __metadata("design:type", lab_result_schema_1.LabResult)
], LabOrder.prototype, "result", void 0);
exports.LabOrder = LabOrder = __decorate([
    (0, mongoose_1.Schema)()
], LabOrder);
//# sourceMappingURL=lab-order.schema.js.map