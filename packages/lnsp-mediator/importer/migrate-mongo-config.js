const path = require('path');

// Resolve environment variables
const MONGO_URL = process.env.MONGO_URL || "mongodb://lnsp-mongo-1:27017/nest";
const MONGO_USERNAME = process.env.MONGO_USERNAME || null;
const MONGO_PASSWORD = process.env.MONGO_PASSWORD || null;

// Mongo options
const mongoOptions = { useNewUrlParser: true, useUnifiedTopology: true };
if (MONGO_USERNAME && MONGO_PASSWORD) {
  mongoOptions.auth = {
    username: MONGO_USERNAME,
    password: MONGO_PASSWORD,
  };
}

// Force migration directory resolution relative to the current working directory
const cwd = process.cwd();
const migrationsDir = path.isAbsolute(cwd) ? path.resolve(cwd, 'migrations') : path.resolve(__dirname, './migrations');
const changelogCollectionName = "changelog";

console.log("MONGO_URL:", MONGO_URL);
console.log("migrationsDir:", migrationsDir);


module.exports = {
  mongodb: {
    url: MONGO_URL,
    options: mongoOptions,
  },
  moduleSystem: 'commonjs',
  migrationsDir: migrationsDir,
  changelogCollectionName:changelogCollectionName,
};
