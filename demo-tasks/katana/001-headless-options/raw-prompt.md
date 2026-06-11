katana's -headless-options / -ho flag is ignored since v1.4.0 — e.g. running
`katana -headless -ho "--proxy-server=http://127.0.0.1:18080"` and chrome never uses
the proxy, traffic bypasses it completely. this worked fine in 1.3.x, looks like a
regression from the headless rewrite. please fix so headless chrome actually gets the
user's custom flags again.
