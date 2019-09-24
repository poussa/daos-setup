urifile=/tmp/report.uri

orterun -allow-run-as-root -np 1 --ompi-server file:${urifile} \
daos pool query --svc 0 --pool 74bb2d2c-ba7c-42e5-8734-4dfedcbbcb8e

orterun -allow-run-as-root -np 1 --ompi-server file:${urifile} \
daos pool query --svc 0 --pool 69a77a65-4d06-41c7-b897-18a208c28d68
