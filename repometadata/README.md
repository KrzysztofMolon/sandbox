There are a few repometadata entries associated with repos that do not
exist. In such cases there is no repo for the scraper to scrape to find
updates to repometadata. Instead, we check them into this directory and
maintain them by hand.

Please do not add new entries here lightly. It is _HIGHLY_ preferred for
repometadata entries to live in the repo that they describe and for
the scraper to handle these in an automated fashion.

See https://godoc.infra.corp.arista.io/pkg/barney.ci/repometadata/model/#RepoMetadata
for a definition of the model used in these curl requests.

Cluster-external clients are no longer authorized to PUT or POST
to repometadata service. In order for updates to this repometadata dataset
to be written, an admin needs to use kubectl port-forward and
execute the deploy script by hand.
