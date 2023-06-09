import fp from "fastify-plugin";

const LogbookEntryService = (postgres) => {
  console.log("LogbookEntryService", postgres);

  const getLogbookEntry = async (memberUid, logbookEntryUid) => {
    const client = await postgres.connect();

    try {
      const {
        rows,
      } = await client.query(
        ` SELECT *
        FROM get_logbook_entry($1, $2)`,
        [memberUid, logbookEntryUid]
      );

      // Note: avoid doing expensive computation here, this will block releasing the client
      return rows[0];
    } finally {
      // Release the client immediately after query resolves, or upon error
      client.release();
    }
  }; 

  const updateLogbookEntry = async (memberUid, logbookEntryUid, entryData) => {
    const client = await postgres.connect();

    let query;
    let values;

    query = `SELECT "entryId", "logbookEntryUid" , "createdAt" , name , "logbookId", "logbookUid" 
        FROM create_entry(
          $1, $2, $3, $4
      )`;

    values = [memberUid, logbookEntryUid, entryData.name, entryData.note];

    try {
      const result = await client.query(query, values);

      const newData = result.rows[0];

      // Note: avoid doing expensive computation here, this will block releasing the client
      return {
        updatedAt: result.updatedAt,
        Uid: result.logbookUid
      };
    } finally {
      // Release the client immediately after query resolves, or upon error
      client.release();
    }
  };

  return { getLogbookEntry, updateLogbookEntry };
};

export default fp((server, options, next) => {
  server.decorate("logbookEntryService", LogbookEntryService(server.pg));
  next();
});
