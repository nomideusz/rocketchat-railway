// Runs against the local mongod. Uses the localhost exception on first boot (no users yet).
const U = process.env.MONGO_INITDB_ROOT_USERNAME, P = process.env.MONGO_INITDB_ROOT_PASSWORD;
const RS = process.env.RS_NAME, HOST = process.env.RS_HOST;
const admin = db.getSiblingDB("admin");
const waitPrimary = () => { for (let i = 0; i < 120 && !db.hello().isWritablePrimary; i++) sleep(500); };

let authed = false;
try { authed = admin.auth(U, P).ok === 1; } catch (e) { /* no user yet, or wrong password */ }

if (!authed) {
  try {
    rs.initiate({ _id: RS, members: [{ _id: 0, host: HOST }] });
    print(`replica set ${RS} initiated as ${HOST}`);
  } catch (e) {
    if (e.codeName !== "AlreadyInitialized") {
      if (e.codeName === "Unauthorized") throw new Error("root user exists but MONGO_INITDB_ROOT_PASSWORD does not match it");
      throw e;
    }
  }
  waitPrimary();
  admin.createUser({ user: U, pwd: P, roles: ["root"] });
  admin.auth(U, P);
  print(`root user ${U} created`);
}

waitPrimary();
print(`replica set ${RS} ready, primary=${db.hello().isWritablePrimary}`);
