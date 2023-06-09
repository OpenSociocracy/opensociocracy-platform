import fp from "fastify-plugin";

const OrgService = (postgres) => {
  console.log("OrgService", postgres);

  const getAccountOrgs = async (memberUid, accountUid) => {
    const client = await postgres.connect();

    try {
      const {
        rows,
      } = await client.query(
        ` SELECT *
        FROM get_account_orgs($1, $2)`,
        [memberUid, accountUid]
      );

      // Note: avoid doing expensive computation here, this will block releasing the client
      return rows;
    } finally {
      // Release the client immediately after query resolves, or upon error
      client.release();
    }
  };

  const createOrg = async (memberUid, accountUid, orgData) => {
    const client = await postgres.connect();

    let query;
    let values;

    query = `SELECT "orgId", "orgUid" , "createdAt" , name , "logbookId", "logbookUid" 
        FROM create_org(
          $1, $2, $3, $4
      )`;

    values = [memberUid, accountUid, orgData.name, orgData.note];

    try {
      const result = await client.query(query, values);

      const newData = result.rows[0];

      // Note: avoid doing expensive computation here, this will block releasing the client
      return {
        orgUid: newData.orgUid,
        createdAt: newData.createdAt,
        name: orgData.name,
        logbookUid: newData.logbookUid
      };
    } finally {
      // Release the client immediately after query resolves, or upon error
      client.release();
    }
  };

  return { getAccountOrgs, createOrg };
};

export default fp((server, options, next) => {
  server.decorate("orgService", OrgService(server.pg));
  next();
});
