db = db.getSiblingDB('admin');

// Create application user
db.createUser({
  user: "${NESTJS_DB_USER}",
  pwd: "${NESTJS_DB_PASSWORD}",
  roles: [
    { role: "readWrite", db: "${NESTJS_DB_NAME}" }
  ]
});

db = db.getSiblingDB('${NESTJS_DB_NAME}');

// Ensure the user has the correct roles in the target database
db.createUser({
  user: "${NESTJS_DB_USER}",
  pwd: "${NESTJS_DB_PASSWORD}",
  roles: [
    { role: "readWrite", db: "${NESTJS_DB_NAME}" }
  ]
});