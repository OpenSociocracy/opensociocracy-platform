import Fastify from "fastify";

import config from "./plugins/config.js";
import postgres from "./plugins/postgres.js";
import auth from "./plugins/auth.js";
import swagger from "./plugins/swagger.js";
import indexRoutes from "./routes/index.js";

export default async function appFramework() {
  const fastify = Fastify({ logger: true });
  fastify.register(config);
  fastify.register(postgres);
  fastify.register(auth);
  fastify.register(swagger);
  fastify.register(indexRoutes);

  await fastify.ready();

  return fastify;
}
