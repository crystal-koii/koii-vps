# koii-vps


scp -i ~/.ssh/AWS-Koii-orbitdb-testingKey.pem setupServer.sh docker-compose.yaml .env-local ubuntu@ec2-54-205-23-28.compute-1.amazonaws.com:/home/ubuntu/koii-vps

chmod +x setupServer.sh
./setupServer.sh
