import fp from "fastify-plugin";

const ReactionService = (postgres) => {
  console.log("ReactionService", postgres);

  const getReaction = async (memberUid, reactionUid) => {
    const client = await postgres.connect();

    try {
      const {
        rows,
      } = await client.query(
        ` SELECT *
        FROM get_reaction($1, $2)`,
        [memberUid, reactionUid]
      );

      // Note: avoid doing expensive computation here, this will block releasing the client
      return rows[0];
    } finally {
      // Release the client immediately after query resolves, or upon error
      client.release();
    }
  }; 

  const getLogbookEntryReactions = async (memberUid, logbookEntryUid) => {
    const client = await postgres.connect();

    try {
      const {
        rows,
      } = await client.query(
        ` SELECT *
        FROM get_logbook_entry_reactions($1, $2)`,
        [memberUid, logbookEntryUid]
      );

      // Note: avoid doing expensive computation here, this will block releasing the client
      return rows;
    } finally {
      // Release the client immediately after query resolves, or upon error
      client.release();
    }
  }; 

  const patchReaction = async (memberUid, reactionUid, entryData) => {
    const client = await postgres.connect();

    const query = `SELECT "reactionUid" , "updatedAt" 
        FROM patch_reaction(
          $1, $2, $3, $4, $5, $6, $7, $8
      )`;

    const note = entryData.note ? entryData.note : null;
    const publicTitle = entryData.publicTitle ? entryData.publicTitle : null;
    const internalName = entryData.internalName ? entryData.internalName : null;
    const blocks = entryData.blocks ? JSON.stringify(entryData.blocks) : null;
    const pubAt = entryData.pubAt ? entryData.pubAt : null;
    const unPubAt = entryData.unPubAt ? entryData.unPubAt : null;

    const values = [memberUid, reactionUid, note, publicTitle, internalName, blocks, pubAt, unPubAt];

    try {
      const result = await client.query(query, values);

      // Note: avoid doing expensive computation here, this will block releasing the client
      return result.rows[0];
    } finally {
      // Release the client immediately after query resolves, or upon error
      client.release();
    }
  };

  return { getReaction, getLogbookEntryReactions, patchReaction };
};

export default fp((server, options, next) => {
  server.decorate("reactionService", ReactionService(server.pg));
  next();
});
