import fastifyPlugin from "fastify-plugin";
import { verifySession } from "supertokens-node/recipe/session/framework/fastify/index.js";

async function healthRoutes(server, options) {
  server.get("/health", async (request, reply) => {
    return {
      status: "OK",
    };
  });
}

export default fastifyPlugin(healthRoutes);