urifile=/tmp/report.uri
orterun --allow-run-as-root -np 1 --ompi-server file:${urifile} dmg create --size=10G

