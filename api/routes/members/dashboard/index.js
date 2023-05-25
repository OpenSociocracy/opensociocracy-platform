'use strict'
import fastifyPlugin from "fastify-plugin";
import { verifySession } from "supertokens-node/recipe/session/framework/fastify/index.js";

async function indexRoutes(server, options) {
  server.get("/members/dashboard",  {
    preHandler: verifySession(),

  },
  async (request, reply) => {
    return {
     root: 'bhgbuue',
    };
  });
}

export default fastifyPlugin(indexRoutes);