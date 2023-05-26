import fastifyPlugin from "fastify-plugin";
import { verifySession } from "supertokens-node/recipe/session/framework/fastify/index.js";

async function accountsRoutes(server, options) {
  server.get("/accounts",
  {
    preHandler: verifySession(),
    schema: {
      description:
        "Get authenticated member accounts",
      tags: ["accounts"],
      summary: "Get all accounts for the authenticated member",
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

    const accounts = await server.accountService.getMemberAccounts(memberUid);

    return {
      accounts: accounts,
    };
  });

  server.post(
    "/accounts",
    {
      preHandler: verifySession(),
      schema: {
        description: "Create a new account",
        tags: ["accounts"],
        summary: "Add a new account to the database",
        body: {
          type: "object",
          properties: {
            name: {
              type: "string",
              description: "The name for the account",
            },
          },
        },
        response: {
          200: {
            description: "Success Response",
            type: "object",
            properties: {
              uid: { type: "string" },
              name: { type: "string" },
              createdAt: { type: "string" }
            },
          },
        },
      },
    },
    async (req, reply) => {
      let userId = req.session.getUserId();

      const result = await server.accountService.createAccount(req.body, userId);

      return result;
    }
  );
}

export default fastifyPlugin(accountsRoutes);