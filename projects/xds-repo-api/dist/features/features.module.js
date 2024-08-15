"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.FeaturesModule = void 0;
const common_1 = require("@nestjs/common");
const lab_result_module_1 = require("./lab-result/lab-result.module");
const lab_order_module_1 = require("./lab-order/lab-order.module");
const subscription_module_1 = require("./subscription/subscription.module");
let FeaturesModule = class FeaturesModule {
};
exports.FeaturesModule = FeaturesModule;
exports.FeaturesModule = FeaturesModule = __decorate([
    (0, common_1.Module)({
        imports: [lab_result_module_1.LabResultModule, lab_order_module_1.LabOrderModule, subscription_module_1.SubscriptionModule],
    })
], FeaturesModule);
//# sourceMappingURL=features.module.js.map