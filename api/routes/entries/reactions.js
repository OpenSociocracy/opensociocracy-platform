import fastifyPlugin from "fastify-plugin";
import { verifySession } from "supertokens-node/recipe/session/framework/fastify/index.js";

async function entryEntryCreateRoutes(server, options) {
  server.get(
    "/entries/:logbookEntryUid/reactions",
    {
      preHandler: verifySession(),
      schema: {
        description: "Get a logbook entry's reactions",
        tags: ["entries"],
        summary: "Get a logbook entry's top-level reactions.",
        response: {
          200: {
            description: "Success Response",
            type: "object",
            properties: {
              reactions: { type: "array" },
            },
          },
        },
      },
    },
    async (request, reply) => {
      const memberUid = request.session.getUserId();

      const logbookEntryUid = request.params.logbookEntryUid;

      const result = await server.reactionService.getLogbookEntryReactions(memberUid, logbookEntryUid);

      return {reactions: result };
    }
  );

  server.post(
    "/entries/:logbookEntryUid/reactions",
    {
      preHandler: verifySession(),
      schema: {
        description: "Create a new logbook entry reaction",
        tags: ["logbooks"],
        summary: "Reaction on a logbook entry",
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
              reactionUid: { type: "string" },
              reactionNuggetUid: { type: "string" },
              createdAt: { type: "string" }
            },
          },
        },
      },
    },
    async (req, reply) => {
      const memberUid = req.session.getUserId();

      const logbookEntryUid = req.params.logbookEntryUid;

      let result;

      result = await server.logbookEntryService.createLogbookEntryReaction(memberUid, logbookEntryUid, metaData);

      return result;
    }
  );
 
}

export default fastifyPlugin(entryEntryCreateRoutes);