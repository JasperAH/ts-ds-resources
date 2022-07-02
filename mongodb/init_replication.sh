#!/bin/bash
mongo <<EOF
var config = {
    "_id": "repset",
    "version": 1,
    "members": [
        {
            "_id": 1,
            "host": "mongodbnode0:27017",
            "priority": 3
        },
        {
            "_id": 2,
            "host": "mongodbnode1:27017",
            "priority": 2
        },
        {
            "_id": 3,
            "host": "mongodbnode2:27017",
            "priority": 1
        }
    ]
};
rs.initiate(config, { force: true });
rs.status();
EOF
