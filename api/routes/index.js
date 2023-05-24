import fastifyPlugin from "fastify-plugin";
import { verifySession } from "supertokens-node/recipe/session/framework/fastify/index.js";

async function indexRoutes(server, options) {
  server.get("/", async (request, reply) => {
    return {
      hello: "hello world",
    };
  });
  server.get(
    "/member/accounts",
    {
      preHandler: verifySession(),
      schema: {
        description: "Returns accounts the member can access",
        tags: ["member"],
        response: {
          200: {
            description: "Success Response",
            type: "object",
            properties: {
              accounts: { type: "array" },
            },
          },
        },
      },
    },
    async (request, reply) => {
      let memberUid = request.session.getUserId();

      const accounts = []

      return {
        accounts: accounts,
      };
    }
  );
}

export default fastifyPlugin(indexRoutes);
