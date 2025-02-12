#!/bin/sh

echo "Starting ZAP in daemon mode..."
chmod +x /zap/zap.sh
/zap/zap.sh -daemon -host 0.0.0.0 -port 8080 &

echo "Waiting for ZAP to start..."
sleep 30
while ! curl -s http://localhost:8080; do sleep 5; done

echo "Running Spider Scan..."
curl "http://localhost:8080/JSON/spider/action/scan/?url=http://juice-shop-scp-444136992.ap-northeast-2.elb.amazonaws.com&maxChildren=5"

sleep 30

echo "Running Active Scan..."
curl "http://localhost:8080/JSON/ascan/action/scan/?url=http://juice-shop-scp-444136992.ap-northeast-2.elb.amazonaws.com"

sleep 30

echo "Generating ZAP Report..."
curl "http://localhost:8080/OTHER/core/other/htmlreport/" > /zap/zap_report.html

echo "Uploading report to S3..."
aws s3 cp /zap/zap_report.html s3://dast-owasp-zap/zap_report.html

echo "Scan completed. Exiting..."
exit 0
