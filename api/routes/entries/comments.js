import fastifyPlugin from "fastify-plugin";
import { verifySession } from "supertokens-node/recipe/session/framework/fastify/index.js";

async function entryEntryCreateRoutes(server, options) {
  server.get(
    "/entries/:logbookEntryUid/comments",
    {
      preHandler: verifySession(),
      schema: {
        description: "Get a logbook entry's comments",
        tags: ["entries"],
        summary: "Get a logbook entry's top-level comments.",
        response: {
          200: {
            description: "Success Response",
            type: "array",
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

      const result = await server.commentService.getLogbookEntryComments(memberUid, logbookEntryUid);
console.log('RESULT', result)
      return result;
    }
  );
 
}

export default fastifyPlugin(entryEntryCreateRoutes);