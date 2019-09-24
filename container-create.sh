urifile=/tmp/report.uri
orterun -allow-run-as-root -np 1 --ompi-server file:${urifile} \
daos container create --svc 0 --pool 69a77a65-4d06-41c7-b897-18a208c28d68 \
--type POSIX --chunk_size 4K
