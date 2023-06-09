import fastifyPlugin from "fastify-plugin";
import { verifySession } from "supertokens-node/recipe/session/framework/fastify/index.js";

async function orgCreateRoutes(server, options) {
  server.post(
    "/orgs",
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
    async (req, reply) => {
      let userId = req.session.getUserId();

      const result = await server.orgService.createOrg(req.body, userId);

      return result;
    }
  );
  server.get("/orgs",
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

    const orgs = await server.orgService.getMemberOrgs(memberUid);

    return {
      orgs: orgs,
    };
  });
}

export default fastifyPlugin(orgCreateRoutes);