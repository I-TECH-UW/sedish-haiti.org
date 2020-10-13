const nconf = require('nconf');
const env = process.env.NODE_ENV || 'development';
let decisionRulesFile;

nconf.argv()
  .env()
  .file(`${__dirname}/../config/config_shr_template.json`)
module.exports = nconf;