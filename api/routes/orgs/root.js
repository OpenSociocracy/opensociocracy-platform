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
              uid: { type: "string" },
              name: { type: "string" },
              createdAt: { type: "string" }
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
}

export default fastifyPlugin(orgCreateRoutes);