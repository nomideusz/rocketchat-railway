# Deploy and Host Rocket.Chat on Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/rocketchat-workspace?referralCode=sLjDXb&utm_medium=integration&utm_source=button&utm_campaign=rocketchat-workspace)

[Rocket.Chat](https://rocket.chat/) is the open-source team chat platform and self-hosted Slack alternative: public and private channels, direct messages, threads, file sharing, audio and video calls, an omnichannel inbox for customer conversations, and integrations through webhooks, bots and a REST API. This template runs Rocket.Chat 8.9.0 (LTS) on the official image with MongoDB 8.0 as a replica set that sets itself up, and creates your admin account on first boot, so there is no setup wizard to race through.

## About Hosting Rocket.Chat

The stack is two services: Rocket.Chat and MongoDB.

- **Upstream's own image, pinned.** Rocket.Chat runs from the official `rocketchat/rocket.chat:8.9.0` image, unmodified. MongoDB 8.0 is the version Rocket.Chat 8.9 is built and tested against.
- **A replica set that sets itself up.** Rocket.Chat needs MongoDB running as a replica set for its real-time change streams. Here MongoDB initiates a single-node replica set on first boot, creates the root user, and comes back as primary after every restart and redeploy. No `rs.initiate()` by hand, no keyfile to manage.
- **Admin ready, wizard skipped.** The first boot creates the admin account from the `ADMIN_*` variables with a generated password, and marks the setup wizard as done. Nobody else can claim the workspace.
- **Files stored in MongoDB.** Uploads go to GridFS in the same database, so one volume holds all your data.
- **Private database.** MongoDB has auth on, a generated password, and is only reachable on Railway's private network.

## Common Use Cases

- Team chat for a company, community or open-source project that wants to own its messages
- A Slack or Microsoft Teams replacement without per-seat pricing
- Customer support through the omnichannel inbox (live chat widget, email, WhatsApp and other channels)
- Alerts and ChatOps from CI, monitoring and n8n or other automation tools via incoming webhooks

## Dependencies for Rocket.Chat Hosting

- MongoDB 8.0 as a single-node replica set (included, private network only)

### Deployment Dependencies

- [Rocket.Chat documentation](https://docs.rocket.chat/)
- [Rocket.Chat environment variables](https://docs.rocket.chat/docs/deployment-environment-variables)
- [Template source on GitHub](https://github.com/nomideusz/rocketchat-railway)

### Implementation Details

**Sign in** at the Rocket.Chat service's Railway domain as `admin` with the `ADMIN_PASS` value from the Rocket.Chat service's Variables tab. The first boot creates the database, so give it a couple of minutes. Change the password afterwards in My Account; the `ADMIN_*` variables are only read while no admin exists.

**Inviting people.** Go to Administration → Workspace → Users to add accounts, or open registration under Settings → Accounts → Registration. Railway only allows outbound SMTP on the Pro plan; to send invitation and password-reset email, configure SMTP under Settings → Email → SMTP.

**Mobile apps and push notifications.** The official mobile and desktop apps connect to your Railway URL. Push notifications go through Rocket.Chat Cloud, so register the workspace under Administration → Workspace → Registration (or paste a token into `REG_TOKEN`). The free Starter plan covers small teams.

**Memory.** About 1 GB at idle: roughly 850 MB for Rocket.Chat and 150 MB for MongoDB. Deploy on Hobby or above.

**Backups.** Everything, uploads included, lives in MongoDB: enable Railway's volume backups on the MongoDB volume.

**Connecting to MongoDB yourself.** The replica set member is registered as `127.0.0.1:27017`, so tools outside the MongoDB container must connect with `directConnection=true`, as `MONGO_URL` does. Keep it that way if you edit the URL.

**Custom domain.** Add it in the Rocket.Chat service's Settings → Networking, then set `ROOT_URL` to `https://your.domain` and redeploy. Rocket.Chat uses it for links, OAuth callbacks and the mobile apps.

**Upgrades.** Change the image tag on the Rocket.Chat service to a newer release; database migrations run on boot. Check Rocket.Chat's release notes for the MongoDB versions each release supports before jumping major versions.

## Why Deploy Rocket.Chat on Railway?

Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying Rocket.Chat on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
