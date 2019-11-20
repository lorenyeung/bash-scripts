#!/bin/bash
# this script directly inserts into the nodes table to generate alot of entries, fast

repo=npm-local
i=$(psql -t -h 0.0.0.0 -U artifactory artifactory -c 'SELECT node_id FROM public.nodes order by node_id desc limit 1;')
while true; do
	time=$(date +%s)
	let "i=i+1"
	psql -h 0.0.0.0 -U artifactory artifactory -c 'insert into nodes (node_id, node_type, repo, node_path, node_name, depth, created, created_by, modified, modified_by, updated, bin_length, sha1_actual, md5_actual, sha256) values ('\'$i\'',1,'\'$repo\'','\'large\'','\'file-$time-$RANDOM\'',2,'\'$time\'','\'admin\'','\'$time\'','\'admin\'','\'$time\'',1207,'\'565a96df090d2de762a5cf2c04ccd30bf553bacb\'','\'00c323aa148c2ca18f5e23ebbe9f7f1a\'','\'6b8c4611b8476fd5a9a96281b82e4002c2be7a4f38c01c219548f2f8a6bf3aab\'')' &
done

