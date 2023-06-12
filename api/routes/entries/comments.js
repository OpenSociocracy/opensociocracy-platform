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
            type: "object",
            properties: {
              comments: { type: "array" },
            },
          },
        },
      },
    },
    async (request, reply) => {
      const memberUid = request.session.getUserId();

      const logbookEntryUid = request.params.logbookEntryUid;

      const result = await server.commentService.getLogbookEntryComments(memberUid, logbookEntryUid);

      return {comments: result };
    }
  );

  server.post(
    "/entries/:logbookEntryUid/comments",
    {
      preHandler: verifySession(),
      schema: {
        description: "Create a new logbook entry comment",
        tags: ["logbooks"],
        summary: "Comment on a logbook entry",
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
              commentUid: { type: "string" },
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

      let metaData = {};
      metaData.note = req.body.note ? req.body.note : null;

      // If there is nugget data, we need to create the nugget first.
      if(req.body.nugget)  {

        // Use the logbookUid to get the proper org_id
        result = await server.nuggetService.createNuggetWithLogbookEntryComment(memberUid, logbookEntryUid, metaData, req.body.nugget);

      } else {
        result = await server.commentService.createComment(memberUid, logbookEntryUid, metaData);
      }

      return result;
    }
  );
 
}

export default fastifyPlugin(entryEntryCreateRoutes);