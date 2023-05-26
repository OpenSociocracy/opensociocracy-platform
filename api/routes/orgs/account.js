import fastifyPlugin from "fastify-plugin";
import { verifySession } from "supertokens-node/recipe/session/framework/fastify/index.js";

async function orgAccountsRoutes(server, options) {
  server.get("/orgs/account/:accountUid",
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
}

export default fastifyPlugin(orgAccountsRoutes);