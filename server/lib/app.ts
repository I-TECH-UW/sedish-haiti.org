import express, {Request, Response} from 'express';
import bodyParser from 'body-parser';
import prerequisites from './prerequisites';
import medUtils from 'openhim-mediator-utils';
import _ from 'lodash';
import fs from 'fs';
import logger from './winston';
import config from './config';

// Loads OpenHIM mediator config
const mediatorConfig = require(`${__dirname}/../config/mediator`);

import userRouter from './routes/user';
import fhirRoutes from './routes/fhir';
import ipsRoutes from './routes/ips';
import configRoutes from './routes/config';

process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0';

let authorized = false;

/**
 * @returns {express.app}
 */
function appRoutes() {
  const app = express();
  // app.set('trust proxy', true);

  app.use(bodyParser.json({
    limit: '10Mb',
    type: ['application/fhir+json', 'application/json+fhir', 'application/json']
  }));

  // app.use('/crux', express.static(`${__dirname}/../gui`));

  // app.use(jwtValidator);

  // app.use('/user', userRouter);
  app.use('/fhir', fhirRoutes);
  app.use('/ips', ipsRoutes);
  // app.use('/config', configRoutes);

  app.get('/', (req: Request, res: Response) => {
    return res.status(200).send(req.url);
  });

  return app;
}

/**
 * start - starts the mediator
 *
 * @param  {Function} callback a node style callback that is called once the
 * server is started
 */

// tmpConfig seems to be a temporary storage for a config file that gets grabbed from 
// OpenHIM - not sure why it was not in .gitignore
 function reloadConfig(data: JSON, callback: Function) {
  const tmpFile = `${__dirname}/../config/tmpConfig.json`;
  fs.writeFile(tmpFile, JSON.stringify(data), err => {
    if (err) {
      throw err;
    }
    config.file(tmpFile);
    return callback();
  });
}

export function start(callback: Function) {
  // Run as OpenHIM Mediator - We only need this approach
  logger.info('Running client registry as a mediator');
  medUtils.registerMediator(config.get('mediator:api'), mediatorConfig, (err: Error) => {
    if (err) {
      logger.error('Failed to register this mediator, check your config');
      logger.error(err.stack);
      process.exit(1);
    }
    config.set('mediator:api:urn', mediatorConfig.urn);
    medUtils.fetchConfig(config.get('mediator:api'), (err: Error, newConfig: JSON) => {
      if (err) {
        logger.info('Failed to fetch initial config');
        logger.info(err.stack);
        process.exit(1);
      }

      // Loads app config based on the required environment
      // const env = process.env.NODE_ENV || 'development';
      const configFile = require(`${__dirname}/../config/config_shr_template`);

      // Merges configs?
      const updatedConfig: JSON = Object.assign(configFile, newConfig);
      reloadConfig(updatedConfig, () => {
        config.set('mediator:api:urn', mediatorConfig.urn);
        logger.info('Received initial config:', newConfig);
        logger.info('Successfully registered mediator!');
        
        // Check prereqs (not needed for now)
        prerequisites.init((err: Error) => {
          if (err) {
            process.exit();
          }
        });

        const app = appRoutes();

        // Start up server on 3000 (default)
        const server = app.listen(config.get('app:port'), () => {

          // Activate heartbeat for OpenHIM mediator
          const configEmitter = medUtils.activateHeartbeat(config.get('mediator:api'));

          // Updates config based on what's sent from the server
          configEmitter.on('config', (newConfig: JSON) => {
            logger.info('Received updated config:', newConfig);
            const updatedConfig = Object.assign(configFile, newConfig);
            reloadConfig(updatedConfig, () => {
              prerequisites.init((err: Error) => {
                if (err) {
                  process.exit();
                }
              });
              config.set('mediator:api:urn', mediatorConfig.urn);
            });
          });
          callback(server);
        });
      });
    });
  });
  
}

// exports.start = start;

if (!module.parent) {
  // if this script is run directly, start the server
  start(() =>
    logger.info(`Server is running and listening on port: ${config.get('app:port')}`)
  );
}