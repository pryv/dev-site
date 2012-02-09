This is a Gollum wiki folder (https://github.com/github/gollum).

Edit via regular Git commits in order to keep track of user changes (for the moment there is no authentication setup on the web interface).

Notes regarding Gollum setup:
  * Gollum needs the Git repo to have at least one commit (it crashes on an empty repo): https://github.com/github/gollum/issues/32
  * I (sgoumaz) had to manually install the latest master for gem Grit as it was crashing Gollum with a file corruption issue: https://github.com/github/gollum/issues/147