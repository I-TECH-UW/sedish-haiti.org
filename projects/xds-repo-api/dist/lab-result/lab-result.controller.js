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
exports.LabResultController = void 0;
const common_1 = require("@nestjs/common");
const lab_result_service_1 = require("./lab-result.service");
const parser = new XMLParser();
let LabResultController = class LabResultController {
    constructor(labResultService) {
        this.labResultService = labResultService;
    }
    async create(xmlPayload) {
        const parsedData = fastXmlParser.parse(xmlPayload);
        const createLabResultDto = {
            facilityId: parsedData.facilityId,
            labOrderId: parsedData.labOrderId,
            documentId: parsedData.documentId,
            documentContents: parsedData.documentContents,
        };
        return this.labResultService.create(createLabResultDto);
    }
    findAll(xmlPayload) {
        const parsedData = fastXmlParser.parse(xmlPayload);
        return this.labResultService.findAllByFacilityId(parsedData.labOrderId);
    }
};
exports.LabResultController = LabResultController;
__decorate([
    (0, common_1.Post)(),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], LabResultController.prototype, "create", null);
__decorate([
    (0, common_1.Post)('dsub'),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], LabResultController.prototype, "findAll", null);
exports.LabResultController = LabResultController = __decorate([
    (0, common_1.Controller)('lab-results'),
    __metadata("design:paramtypes", [lab_result_service_1.LabResultService])
], LabResultController);
//# sourceMappingURL=lab-result.controller.js.map