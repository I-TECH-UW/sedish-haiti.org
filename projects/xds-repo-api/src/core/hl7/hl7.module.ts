import { Module, Global, DynamicModule } from '@nestjs/common';
import Hl7lib from 'nodehl7';
import { Hl7Service } from './hl7.service';

@Global()
@Module({
  providers: [Hl7Service],
  exports: [Hl7Service],
})
export class Hl7Module {
  static forRoot(config: any): DynamicModule {
    const hl7Provider = {
      provide: 'HL7_PARSER',
      useFactory: () => new Hl7lib(config),
    };

    return {
      module: Hl7Module,
      providers: [hl7Provider, Hl7Service],
      exports: [Hl7Service],
    };
  }
}
