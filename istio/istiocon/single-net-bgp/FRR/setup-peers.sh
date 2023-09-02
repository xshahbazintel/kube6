

# clu4 peers
while IFS= read -r node; do
  # get the IP address of the node using docker inspect
  ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$node")
  # append the IP address to the array
  ips_clu4+=("$ip")
done < <(kind get nodes --name clu4)

# print the array elements
echo "${ips_clu4[@]}"

export PEERS="${ips_clu4[@]}"
export LOCAL_AS=65100
export REMOTE_AS=64503