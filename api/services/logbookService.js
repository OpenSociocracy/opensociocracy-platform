import fp from "fastify-plugin";

const LogbookService = (postgres) => {
  console.log("LogbookService", postgres);

  const getOrgLogbooks = async (memberUid, orgUid) => {
    const client = await postgres.connect();

    try {
      const {
        rows,
      } = await client.query(
        ` SELECT *
        FROM get_org_logbooks($1, $2)`,
        [memberUid, orgUid]
      );

      // Note: avoid doing expensive computation here, this will block releasing the client
      return rows;
    } finally {
      // Release the client immediately after query resolves, or upon error
      client.release();
    }
  };

  const createLogbook = async (logbookData, memberUid) => {
    const client = await postgres.connect();

    let query;
    let values;

    query = `SELECT "logbookId", "logbookUid" , "createdAt" , name , "logbookId", "logbookUid" 
        FROM create_logbook(
          $1, $2, $3, $4
      )`;

    values = [logbookData.name, logbookData.note, memberUid, logbookData.orgUid];

    try {
      const result = await client.query(query, values);

      const newData = result.rows[0];

      // Note: avoid doing expensive computation here, this will block releasing the client
      return {
        logbookUid: newData.logbookUid,
        createdAt: newData.createdAt,
        name: logbookData.name,
        logbookUid: newData.logbookUid
      };
    } finally {
      // Release the client immediately after query resolves, or upon error
      client.release();
    }
  };

  return { getOrgLogbooks, createLogbook };
};

export default fp((server, options, next) => {
  server.decorate("logbookService", LogbookService(server.pg));
  next();
});
