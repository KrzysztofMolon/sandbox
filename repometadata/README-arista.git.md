Arista.git has a special arrangement that evolved organically. This README is not
meant to document how these repos _should_ be managed, but rather to document
how these repos _are_ managed. The `deploy-all.sh` automation has a hack injected
herein to preserve this arrangement.

There are several aliases for arista.git which
are intentionally not related in an obsoleted tree. This is because RITS will update
all the repomap entries associated with an obsolete tree in unison. While the arista
developers want for exactly one repomap entry to be updated in their RITS MUT. They
specify that repomap entry with a `Reponame` trailer.

Additionally, BTM will use the repometadata query endpoint to resolve a changelist
to a reponame. This endpoint orders results by last update time (most recently
updated first). Since we want RITS to default to using the arista.git alias, we
need to bump its updateTime after we manually push any of the cv-arista aliases.
