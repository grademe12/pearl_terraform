# Pearl Factory IoT Infrastructure v2.0

Terraform-managed IoT monitoring infrastructure with AWS cloud backup integration.

## 📋 Overview

This branch extends the base Terraform infrastructure with AWS integration, adding real-time data streaming to S3 via Kinesis for long-term storage and analytics.

## 🏗️ Architecture

```
Local Infrastructure (Debian Mini PC)
├── Mosquitto (MQTT Broker)
├── InfluxDB (2 Buckets: MQTT + OPC-UA)
├── Telegraf (Multi-protocol collector)
├── Grafana (Visualization)
└── → AWS Kinesis → Firehose → S3

Edge Devices (Raspberry Pi)
├── MQTT Publishers
└── OPC-UA Gateway (192.168.45.205:4840)
```

## 🚀 What's New in This Branch

### AWS Integration
- **Kinesis Data Stream**: Real-time data ingestion
- **Kinesis Firehose**: Batch processing to S3
- **S3 Bucket**: Long-term data archival with GZIP compression
- **CloudWatch Logging**: Firehose delivery monitoring

### Dual Bucket Support
- `sensors`: MQTT sensor data
- `plc_data`: OPC-UA data (created via null_resource)

## 📁 Key Files

```
├── main.tf          # Docker containers + local infrastructure
├── aws.tf           # AWS resources (Kinesis, S3, IAM)
├── variables.tf     # Including AWS credentials
└── conf/
    └── telegraf.conf.tpl  # Multi-output configuration
```

## 🔧 Configuration

### Required Variables
```hcl
# AWS Credentials
aws_access_key = "your-access-key"
aws_secret_key = "your-secret-key"

# Dual Buckets
influx_mqtt_bucket  = "sensors"
influx_opcua_bucket = "plc_data"
```

### Data Flow
1. **Local Collection**: Telegraf collects from MQTT and OPC-UA
2. **Dual Storage**: 
   - InfluxDB (local real-time queries)
   - Kinesis → S3 (cloud backup)
3. **Compression**: 5MB or 5-minute batches, GZIP compressed

## 🚀 Deployment

```bash
# Initialize providers
terraform init

# Plan deployment
terraform plan

# Apply configuration
terraform apply -auto-approve

# Verify S3 data
aws s3 ls s3://bucket-pearl-woosupar/ --recursive
```

## 📊 AWS Resources Created

| Resource | Purpose | Configuration |
|----------|---------|---------------|
| Kinesis Stream | Data ingestion | 1 shard, on-demand |
| Firehose | S3 delivery | 5MB/300s buffer |
| S3 Bucket | Data lake | GZIP compressed |
| IAM Role | Firehose permissions | Kinesis read, S3 write |

## 🔍 Monitoring

### Local Metrics
- Grafana: http://localhost:3001
- InfluxDB: http://localhost:8087

### AWS Monitoring
```bash
# Check Kinesis metrics
aws kinesis describe-stream --stream-name kinesis

## 🛠️ Troubleshooting

### Telegraf Not Sending to Kinesis
```bash
docker logs telegraf-terra
# Check AWS credentials
```

### S3 Files Not Appearing
- Check Firehose buffering settings (5 minutes delay)
- Verify IAM permissions

## 📝 Notes

- OPC-UA endpoint hardcoded to `192.168.45.205:4840`
- AWS region set to `ap-northeast-2` (Seoul)
- S3 bucket name must be globally unique

## 🔄 Next Steps

- [ ] Add S3 lifecycle policies for cost optimization
- [ ] Implement AWS Glue for ETL processing
- [ ] Set up Athena for S3 queries
- [ ] Add CloudWatch alarms

---

For base infrastructure documentation, see [main branch README](https://github.com/grademe12/pearl_terraform).

## This README written by Claude.ai
