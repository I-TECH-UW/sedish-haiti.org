"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.LabOrderModule = void 0;
const common_1 = require("@nestjs/common");
const mongoose_1 = require("@nestjs/mongoose");
const lab_order_service_1 = require("./lab-order.service");
const lab_order_controller_1 = require("./lab-order.controller");
const lab_order_schema_1 = require("./lab-order.schema");
const lab_order_dao_1 = require("./lab-order.dao");
let LabOrderModule = class LabOrderModule {
};
exports.LabOrderModule = LabOrderModule;
exports.LabOrderModule = LabOrderModule = __decorate([
    (0, common_1.Module)({
        imports: [
            mongoose_1.MongooseModule.forFeature([{ name: lab_order_schema_1.LabOrder.name, schema: lab_order_schema_1.LabOrderSchema }]),
        ],
        providers: [lab_order_dao_1.LabOrderDAO, lab_order_service_1.LabOrderService],
        controllers: [lab_order_controller_1.LabOrderController]
    })
], LabOrderModule);
//# sourceMappingURL=lab-order.module.js.map