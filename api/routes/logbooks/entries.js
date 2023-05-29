import fastifyPlugin from "fastify-plugin";
import { verifySession } from "supertokens-node/recipe/session/framework/fastify/index.js";

async function logbookEntryRoutes(server, options) {
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
              createdAt: { type: "string" },
              nuggetUid: { type: "string" }
            },
          },
        },
      },
    },
    async (req, reply) => {
      const memberUid = req.session.getUserId();

      const logbookUid = req.params.logbookUid;

      let data = req.body.note ;

      // If there is nugget data, we need to create the nugget first.
      if(req.body.nugget)  {

        // Use the logbookUid to get the proper org_id
        const nuggetUid = await server.nuggetService.createNuggetForLogbook(memberUid, logbookUid, req.body.nugget);

        data = {...data, nuggetUid: nuggetUid }

      } else {
        result = await server.logbookService.createLogbookEntry(memberUid, logbookUid, data);
      }

      return result;
    }
  );

}

export default fastifyPlugin(logbookEntryRoutes);