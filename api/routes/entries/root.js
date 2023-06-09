import fastifyPlugin from "fastify-plugin";
import { verifySession } from "supertokens-node/recipe/session/framework/fastify/index.js";

async function entryEntryCreateRoutes(server, options) {
  server.get(
    "/entries/:logbookEntryUid",
    {
      preHandler: verifySession(),
      schema: {
        description: "Get a logbook entry",
        tags: ["entries"],
        summary: "Get a single logbook entry.",
        response: {
          200: {
            description: "Success Response",
            type: "object",
            properties: {
              logbookEntryUid: { type: "string" },
              createdAt: { type: "string" },
              updatedAt: { type: "string" },
              note: { type: "string" },
              pubAt: { type: "string" },
              unPubAt: { type: "string" },
              publicTitle: { type: "string" },
              internalName: { type: "string" },
              blocks: { type: "array" },
              nuggetType: { type: "string" }
            },
          },
        },
      },
    },
    async (request, reply) => {
      const memberUid = request.session.getUserId();

      const logbookEntryUid = request.params.logbookEntryUid;

      const result = await server.logbookEntryService.getLogbookEntry(memberUid, logbookEntryUid);

      return result;
    }
  );
  server.put(
    "/entries/:logbookEntryUid",
    {
      preHandler: verifySession(),
      schema: {
        description: "Update a logbook entry",
        tags: ["entries"],
        summary: "Add a new entry to the logbook",
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
    async (request, reply) => {
      const memberUid = request.session.getUserId();

      const logbookEntryUid = request.params.logbookEntryUid;

      const result = await server.entryService.updateEntry(memberUid, logbookEntryUid, request.body);

      return result;
    }
  );
}

export default fastifyPlugin(entryEntryCreateRoutes);