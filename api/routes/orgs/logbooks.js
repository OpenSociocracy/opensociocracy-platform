import fastifyPlugin from "fastify-plugin";
import { verifySession } from "supertokens-node/recipe/session/framework/fastify/index.js";

async function logbookOrganizationsRoutes(server, options) {
  server.get("/org/:orgUid/logbooks",
  {
    preHandler: verifySession(),
    schema: {
      description:
        "Get Logbooks for an Organization",
      tags: ["logbooks"],
      summary: "Get all logbooks for a given org",
      response: {
        200: {
          description: "Success Response",
          type: "object",
          properties: {
            logbooks: { type: "array" },
          },
        },
      },
    },
  },
  async (request, reply) => {
    let memberUid = request.session.getUserId();

    const orgUid = request.params.orgUid;

    const logbooks = await server.logbookService.getOrgLogbooks(memberUid, orgUid);

    return {
      logbooks: logbooks,
    };
  });
}

export default fastifyPlugin(logbookOrganizationsRoutes);