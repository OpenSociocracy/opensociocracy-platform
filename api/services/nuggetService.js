import fp from "fastify-plugin";

const NuggetService = (postgres) => {

  const getOrgNuggets = async (memberUid, orgUid) => {
    const client = await postgres.connect();

    try {
      const {
        rows,
      } = await client.query(
        ` SELECT *
        FROM get_org_nuggets($1, $2)`,
        [memberUid, orgUid]
      );

      // Note: avoid doing expensive computation here, this will block releasing the client
      return rows;
    } finally {
      // Release the client immediately after query resolves, or upon error
      client.release();
    }
  };

  const createNuggetForLogbook = async (memberUid, logbookUid, nuggetData) => {
    const client = await postgres.connect();

    let query;
    let values;

    // @TODO Validate nuggets by type before hitting database.

    query = `SELECT "nuggetId", "nuggetUid" , "createdAt" 
        FROM create_logbook_nugget(
          $1, $2, $3
      )`;

    values = [memberUid, logbookUid, nuggetData];

    try {
      const result = await client.query(query, values);

      const newData = result.rows[0];

      // Note: avoid doing expensive computation here, this will block releasing the client
      return {
        nuggetUid: newData.nuggetUid,
        createdAt: newData.createdAt
      };
    } finally {
      // Release the client immediately after query resolves, or upon error
      client.release();
    }
  };

  const createNuggetEntry = async (memberUid, nuggetUid, nuggetEntryData) => {
    const client = await postgres.connect();

    let query;
    let values;

    query = `SELECT "nuggetEntryId", "nuggetEntryUid" , "createdAt"
        FROM create_nugget_entry(
          $1, $2, $3, $4
      )`;

    const nuggetUid = nuggetEntryData.nuggetUid ? nuggetEntryData.nuggetUid : null;
    const note = nuggetEntryData.note ? nuggetEntryData.note : null;
    values = [memberUid, nuggetUid, nuggetUid, note];

    try {
      const result = await client.query(query, values);

      const newData = result.rows[0];

      // Note: avoid doing expensive computation here, this will block releasing the client
      return {
        nuggetUid: newData.nuggetUid,
        createdAt: newData.createdAt,
        name: nuggetEntryData.name,
        nuggetUid: newData.nuggetUid
      };
    } finally {
      // Release the client immediately after query resolves, or upon error
      client.release();
    }
  };

  const getNuggetEntries = async (memberUid, nuggetUid) => {
    const client = await postgres.connect();

    try {
      const {
        rows,
      } = await client.query(
        ` SELECT *
        FROM get_nugget_entries($1, $2)`,
        [memberUid, nuggetUid]
      );

      console.log('SERVICE RESULT', rows)

      // Note: avoid doing expensive computation here, this will block releasing the client
      return { nuggetEntries: rows };
    } finally {
      // Release the client immediately after query resolves, or upon error
      client.release();
    }
  }

  return { getOrgNuggets, createNugget, createNuggetEntry, getNuggetEntries };
};

export default fp((server, options, next) => {
  server.decorate("nuggetService", NuggetService(server.pg));
  next();
});