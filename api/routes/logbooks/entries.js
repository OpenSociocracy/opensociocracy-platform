import fastifyPlugin from "fastify-plugin";
import { verifySession } from "supertokens-node/recipe/session/framework/fastify/index.js";

async function logbookEntriesRoutes(server, options) {
  server.get(
    "/logbooks/:logbookUid/entries",
    {
      preHandler: verifySession(),
      schema: {
        description: "Get entries for a logbook",
        tags: ["logbooks"],
        summary: "Get a logbook's entries.",
        response: {
          200: {
            description: "Success Response",
            type: "object",
            properties: {
              logbookEntries: { type: "array" },
            },
          },
        },
      },
    },
    async (req, reply) => {
      const memberUid = req.session.getUserId();

      const logbookUid = req.params.logbookUid;

      const result = await server.logbookService.getLogbookEntries(memberUid, logbookUid);

      console.log('ROUTER RESULT', result)

      return result;
    }
  );
  server.post(
    "/logbooks/:logbookUid/entries",
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
              createdAt: { type: "string" }
            },
          },
        },
      },
    },
    async (req, reply) => {
      const memberUid = req.session.getUserId();

      const logbookUid = req.params.logbookUid;

      let result;

      let metaData = {};
      metaData.note = req.body.note ? req.body.note : null;

      // If there is nugget data, we need to create the nugget first.
      if(req.body.nugget)  {

        // Use the logbookUid to get the proper org_id
        result = await server.nuggetService.createNuggetWithLogbookEntry(memberUid, logbookUid, metaData, req.body.nugget);

      } else {
        result = await server.logbookService.createLogbookEntry(memberUid, logbookUid, metaData);
      }

      return result;
    }
  );

}

export default fastifyPlugin(logbookEntriesRoutes);