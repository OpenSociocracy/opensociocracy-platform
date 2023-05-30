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

	const pubAt = nuggetData.pubAt ? nuggetData.pubAt : null;
	const unPubAt = nuggetData.unPubAt ? nuggetData.unPubAt : null;  
	const publicTitle = nuggetData.publicTitle ? nuggetData.publicTitle : null;
	const internalName = nuggetData.internalName ? nuggetData.internalName : null;
	const blocks = nuggetData.blocks ? JSON.stringify(nuggetData.blocks) : null;
	const nuggetType = nuggetData.nuggetType ? nuggetData.nuggetType : null;

    query = `SELECT * 
        FROM create_logbook_nugget(
          $1, $2, $3, $4, $5, $6, $7, $8
      )`;

    values = [memberUid, logbookUid, pubAt, unPubAt, publicTitle, internalName, blocks, nuggetType];
    

    try {
      const result = await client.query(query, values);

      const newData = result.rows[0];

      console.log('NEW DATA', newData);

      // Note: avoid doing expensive computation here, this will block releasing the client
      return {
        nuggetId: newData.id,
        nuggetUid: newData.uid,
        createdAt: newData.createdAt
      };
    } finally {
      // Release the client immediately after query resolves, or upon error
      client.release();
    }
  };

  const createNuggetWithLogbookEntry = async (memberUid, logbookUid, metaData, nuggetData) => {
    const client = await postgres.connect();

    let query;
    let values;

	const pubAt = nuggetData.pubAt ? nuggetData.pubAt : null;
	const unPubAt = nuggetData.unPubAt ? nuggetData.unPubAt : null;  
	const publicTitle = nuggetData.publicTitle ? nuggetData.publicTitle : null;
	const internalName = nuggetData.internalName ? nuggetData.internalName : null;
	const blocks = nuggetData.blocks ? JSON.stringify(nuggetData.blocks) : null;
	const nuggetType = nuggetData.nuggetType ? nuggetData.nuggetType : null;
  const note = metaData.note ? metaData : null;

    query = `SELECT * 
        FROM create_logbook_entry_nugget(
          $1, $2, $3, $4, $5, $6, $7, $8, $9
      )`;

    values = [memberUid, logbookUid, pubAt, unPubAt, publicTitle, internalName, blocks, nuggetType, note];
    

    try {
      const result = await client.query(query, values);

      const newData = result.rows[0];

      console.log('NEW DATA', newData);

      // Note: avoid doing expensive computation here, this will block releasing the client
      return {
        nuggetId: newData.nuggetId,
        nuggetUid: newData.nuggetUid,
        logbookEntryId: newData.logbookEntryId,
        logbookEntryUid: newData.logbookEntryUid,
        createdAt: newData.createdAt
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

  return { createNuggetForLogbook, createNuggetWithLogbookEntry };
};

export default fp((server, options, next) => {
  server.decorate("nuggetService", NuggetService(server.pg));
  next();
});
