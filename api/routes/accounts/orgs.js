import fastifyPlugin from "fastify-plugin";
import { verifySession } from "supertokens-node/recipe/session/framework/fastify/index.js";

async function accountOrgsRoutes(server, options) {
  server.get("/accounts/:accountUid/orgs",
  {
    preHandler: verifySession(),
    schema: {
      description:
        "Get Organizations for an Account",
      tags: ["orgs"],
      summary: "Get all organizations for a given account",
      response: {
        200: {
          description: "Success Response",
          type: "object",
          properties: {
            orgs: { type: "array" },
          },
        },
      },
    },
  },
  async (request, reply) => {
    let memberUid = request.session.getUserId();

    const accountUid = request.params.accountUid;

    const orgs = await server.orgService.getAccountOrgs(memberUid, accountUid);

    return {
      orgs: orgs,
    };
  });

  server.post(
    "/accounts/:accountUid/orgs",
    {
      preHandler: verifySession(),
      schema: {
        description: "Create a new org",
        tags: ["orgs"],
        summary: "Add a new org to the database",
        body: {
          type: "object",
          properties: {
            name: {
              type: "string",
              description: "The name for the org",
              },
          },
        },
        response: {
          200: {
            description: "Success Response",
            type: "object",
            properties: {
              orgUid: { type: "string" },
              name: { type: "string" },
              createdAt: { type: "string" },
              logbookUid: { type: "string" }
            },
          },
        },
      },
    },
    async (request, reply) => {
      const memberUid = request.session.getUserId();
      
      const accountUid= request.params.accountUid;

      const result = await server.orgService.createOrg(memberUid, accountUid, request.body );

      return result;
    }
  );
}

export default fastifyPlugin(accountOrgsRoutes);