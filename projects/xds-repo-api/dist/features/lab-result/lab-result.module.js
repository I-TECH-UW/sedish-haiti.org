"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.LabResultModule = void 0;
const common_1 = require("@nestjs/common");
const lab_result_service_1 = require("./lab-result.service");
const lab_result_controller_1 = require("./lab-result.controller");
const mongoose_1 = require("@nestjs/mongoose");
const lab_result_schema_1 = require("./lab-result.schema");
let LabResultModule = class LabResultModule {
};
exports.LabResultModule = LabResultModule;
exports.LabResultModule = LabResultModule = __decorate([
    (0, common_1.Module)({
        imports: [mongoose_1.MongooseModule.forFeature([{ name: lab_result_schema_1.LabResult.name, schema: lab_result_schema_1.LabResultSchema }])],
        providers: [lab_result_service_1.LabResultService],
        controllers: [lab_result_controller_1.LabResultController]
    })
], LabResultModule);
//# sourceMappingURL=lab-result.module.js.map