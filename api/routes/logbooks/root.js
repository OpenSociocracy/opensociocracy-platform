import fastifyPlugin from "fastify-plugin";
import { verifySession } from "supertokens-node/recipe/session/framework/fastify/index.js";

async function logbookRoutes(server, options) {
  server.get(
    "/logbooks/:logbookUid",
    {
      preHandler: verifySession(),
      schema: {
        description: "Get a logbook",
        tags: ["logbooks"],
        summary: "Get a logbook.",
        response: {
          200: {
            description: "Success Response",
            type: "object",
            properties: {
              logbookEntryUid: { type: "string" },
              createdAt: { type: "string" },
             },
          },
        },
      },
    },
    async (req, reply) => {
      const memberUid = req.session.getUserId();

      const logbookUid = req.params.logbookUid;

      const result = await server.logbookService.getLogbook(memberUid, logbookUid);

      return result;
    }
  );
  server.post(
    "/logbooks/:logbookUid",
    {
      preHandler: verifySession(),
      schema: {
        description: "Create a new logbook entry",
        tags: ["logbooks"],
        summary: "Add a new entry to the logbook",
        body: {
          type: "object",
          properties: {
            name: {
              type: "string",
              description: "The name for the logbook",
              },
          },
        },
        response: {
          200: {
            description: "Success Response",
            type: "object",
            properties: {
              logbookEntryUid: { type: "string" },
              createdAt: { type: "string" },
            },
          },
        },
      },
    },
    async (req, reply) => {
      const memberUid = req.session.getUserId();

      const result = await server.logbookService.createLogbook(memberUid, req.body);

      return result;
    }
  );
}

export default fastifyPlugin(logbookRoutes);