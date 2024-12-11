module.exports = {
  async up(db, client) {
    console.log("Baseline migration applied. No changes made to the database.");
  },

  async down(db, client) {
    console.log("Baseline migration rolled back. No changes reverted.");
  },
};
