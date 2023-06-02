#!/bin/bash
openssl aes-256-cbc -d -in 2-entropy -out 2-decrypt
cmp 2.txt 2-decrypt
