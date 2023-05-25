import fastifyPlugin from "fastify-plugin";
import { verifySession } from "supertokens-node/recipe/session/framework/fastify/index.js";

async function healthRoutes(server, options) {
  server.get("/health", async (request, reply) => {
    return {
      warning: "V1 - UNAUTHORIZED ACCESS PROHIBITED",
    };
  });
}

export default fastifyPlugin(healthRoutes);