import Fastify from "fastify";
import { fileURLToPath } from 'url'
import { dirname, join } from 'path'

import config from "./plugins/config.js";
import postgres from "./plugins/postgres.js";
import auth from "./plugins/auth.js";
import swagger from "./plugins/swagger.js";
// import indexRoutes from "./routes/index.js";

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)

import autoLoad from '@fastify/autoload'

export default async function appFramework() {
  const fastify = Fastify({ logger: true });
  fastify.register(config);
  fastify.register(postgres);
  fastify.register(auth);
  fastify.register(swagger);
  // fastify.register(indexRoutes);

  fastify.register(autoLoad, {
    dir: join(__dirname, 'routes')
  })


  await fastify.ready();

  return fastify;
}
