import fastifyPlugin from "fastify-plugin";
import { verifySession } from "supertokens-node/recipe/session/framework/fastify/index.js";

async function entryEntryCreateRoutes(server, options) {
  server.get(
    "/comments/:commentUid",
    {
      preHandler: verifySession(),
      schema: {
        description: "Get a comment",
        tags: ["entries"],
        summary: "Get a single comment",
        response: {
          200: {
            description: "Success Response",
            type: "object",
            properties: {
              commentUid: { type: "string" },
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

      const commentUid = request.params.commentUid;

      const result = await server.commentService.getComment(memberUid, commentUid);

      return result;
    }
  );
  server.patch(
    "/comments/:commentUid",
    {
      preHandler: verifySession(),
      schema: {
        description: "Update a comment",
        tags: ["entries"],
        summary: "Update a comment",
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
              commentUid: { type: "string" },
              updatedAt: { type: "string" },
            },
          },
        },
      },
    },
    async (request, reply) => {
      const memberUid = request.session.getUserId();

      const commentUid = request.params.commentUid;

      const result = await server.commentService.patchComment(memberUid, commentUid, request.body);

      console.log('MYREESULT', result)

      return result;
    }
  );
}

export default fastifyPlugin(entryEntryCreateRoutes);