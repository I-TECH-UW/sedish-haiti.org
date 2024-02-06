db = db.getSiblingDB("dsub");
db.subscriptions.drop();

db.subscriptions.save( {
    _id: "55d70d39-a116-4ede-891c-c83944551232",
    url : "https://openhimcore.sedish.live/xds-order-notification",
    terminateAt :null,
    facilityQuery : null
});
