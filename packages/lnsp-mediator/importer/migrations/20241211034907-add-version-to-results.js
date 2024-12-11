module.exports = {
  async up(db, client) {
    console.log("Adding default version field to results collection...");

    // Update all documents that do not have a `version` field
    const result = await db.collection('results').updateMany(
      { version: { $exists: false } }, // Find documents without a `version` field
      { $set: { version: 1 } }         // Add the `version` field with default value 1
    );

    console.log(`Updated ${result.modifiedCount} documents with default version.`);
  },

  async down(db, client) {
    console.log("Removing version field from results collection...");

    // Remove the `version` field from all documents
    const result = await db.collection('results').updateMany(
      {},                              // Apply to all documents
      { $unset: { version: "" } }      // Remove the `version` field
    );

    console.log(`Removed version field from ${result.modifiedCount} documents.`);
  },
};
