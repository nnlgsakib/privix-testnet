./neth  server --chain testnet.json --libp2p 0.0.0.0:10001 --nat 0.0.0.0 --jsonrpc 0.0.0.0:8545 --seal  --data-dir=node1 --grpc-address 0.0.0.0:20001


./neth server --chain testnet.json --libp2p 0.0.0.0:10002 --nat 0.0.0.0 --jsonrpc 0.0.0.0:8545 --seal  --data-dir=node2 --grpc-address 0.0.0.0:20002

 ./neth server --chain testnet.json --libp2p 0.0.0.0:10003 --nat 0.0.0.0 --jsonrpc 0.0.0.0:8545 --seal  --data-dir=node3 --grpc-address 0.0.0.0:20003

./neth server --chain testnet.json --libp2p 0.0.0.0:10004 --nat 0.0.0.0 --jsonrpc 0.0.0.0:8545 --seal  --data-dir=node4 --grpc-address 0.0.0.0:20004