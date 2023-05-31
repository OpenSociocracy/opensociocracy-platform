import fastifyPlugin from "fastify-plugin";
import { verifySession } from "supertokens-node/recipe/session/framework/fastify/index.js";

async function logbookEntryRoutes(server, options) {

  server.get(
    "/logbooks/:logbookUid/nuggets/:nuggetUid",
    {
      preHandler: verifySession(),
      schema: {
        description: "Get a logbook nugget",
        tags: ["logbooks"],
        summary: "Get a given nugget related to a logbook",
        response: {
          200: {
            description: "Success Response",
            type: "object",
            properties: {
              nugget: { 
                type: "object",
                properties: {
                    nuggetUid: {
                        type: "string"
                    },
                    createdAt: {
                        type: "string"
                    },
                    updatedAt: {
                        type: "string"
                    },
                    pubAt: {
                        type: "string"
                    },
                    unPubAt: {
                        type: "string"
                    },
                    publicTitle: {
                        type: "string"
                    },
                    internalName: {
                        type: "string"
                    },
                    blocks: {
                        type: "array"
                    },
                    nuggetType: {
                        type: "string"
                    },
                    orgUid: {
                        type: "string"
                    },
                    accountUid: {
                        type: "string"
                    },
                }
              },
            },
          },
        },
      },
    },
    async (req, reply) => {
      const memberUid = req.session.getUserId();

      const logbookUid = req.params.logbookUid;

      const nuggetUid = req.params.nuggetUid;

      const result = await server.nuggetService.getLogbookNugget(memberUid, logbookUid, nuggetUid);
      console.log('ROUTER ', result)

      return result;
    }
  );
  server.put(
    "/logbooks/:logbookUid/nuggets/:nuggetUid",
    {
      preHandler: verifySession(),
      schema: {
        description: "Replace nugget data",
        tags: ["logbooks"],
        summary: "Replace nugget data",
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
              updatedAt: { type: "string" },
              nuggetUid: { type: "string" }
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

  server.patch(
    "/logbooks/:logbookUid/nuggets/:nuggetUid",
    {
      preHandler: verifySession(),
      schema: {
        description: "Patch nugget data",
        tags: ["logbooks"],
        summary: "Update provided fields of the nugget",
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
              updatedAt: { type: "string" },
              nuggetUid: { type: "string" }
            },
          },
        },
      },
    },
    async (req, reply) => {
      const memberUid = req.session.getUserId();

      const nuggetUid = req.params.nuggetUid;

      let result = await server.nuggetService.patchNugget(memberUid, nuggetUid, req.body.nugget);

      return result;
    }
  );

}

export default fastifyPlugin(logbookEntryRoutes);