import fastifyPlugin from "fastify-plugin";
import { verifySession } from "supertokens-node/recipe/session/framework/fastify/index.js";

async function entryEntryCreateRoutes(server, options) {
  server.get(
    "/entries/:entryUid",
    {
      preHandler: verifySession(),
      schema: {
        description: "Get a entry",
        tags: ["entries"],
        summary: "Get a entry.",
        response: {
          200: {
            description: "Success Response",
            type: "object",
            properties: {
              entryEntryUid: { type: "string" },
              createdAt: { type: "string" },
              nuggetUid: { type: "string" }
            },
          },
        },
      },
    },
    async (req, reply) => {
      const memberUid = req.session.getUserId();

      const entryUid = req.params.entryUid;

      const result = await server.entryService.getEntry(memberUid, entryUid);

      return result;
    }
  );
  server.post(
    "/entries/:entryUid",
    {
      preHandler: verifySession(),
      schema: {
        description: "Create a new entry entry",
        tags: ["entries"],
        summary: "Add a new entry to the entry",
        body: {
          type: "object",
          properties: {
            name: {
              type: "string",
              description: "The name for the entry",
              },
          },
        },
        response: {
          200: {
            description: "Success Response",
            type: "object",
            properties: {
              entryEntryUid: { type: "string" },
              createdAt: { type: "string" },
              nuggetUid: { type: "string" }
            },
          },
        },
      },
    },
    async (req, reply) => {
      const memberUid = req.session.getUserId();

      const result = await server.entryService.createEntry(memberUid, req.body);

      return result;
    }
  );
}

export default fastifyPlugin(entryEntryCreateRoutes);