declare module 'nodehl7' {
  class Hl7lib {
    constructor(config: any);

    parseFile(path: string, callback: (err: any, message: any) => void): void;

    parse(
      messageContent: string,
      ID: string,
      callback: (err: any, message: any) => void,
    ): void;
  }

  export = Hl7lib;
}
