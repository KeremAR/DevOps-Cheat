# AWS Storage Services

## Table of Content

- [Your goals](#your-goals)
- [Storage Services](#storage-services)
- [Elastic Block Storage (EBS)](#elastic-block-storage-ebs)
- [Elastic File System (EFS)](#elastic-file-system-efs)
- [Amazon FSx](#amazon-fsx)
- [Simple Storage Service (S3)](#simple-storage-service-s3)
- [Storage Services comparison](#storage-services-comparison)
- [Examples](#examples)
- [Self-check](#self-check)
- [Hands-on Labs](#hands-on-labs)
- [More details](#more-details)

## Your goals

- Understand what AWS Elastic Block Storage is used for, know it’s volume types

- Explain EBS encryption, multi-attach, migration, monitoring and snapshotting, lifecycle manager

- Understand AWS EFS and its storage classes 

- Know AWS EFS/EFx features and use-cases

- Know what AWS S3 is, its tiers, what bucket and object are  

- Explain S3 replication, website hosting, ACL, versioning

- Understand S3 Security

## Storage Services

AWS provides the folloiwing storage services:

**EBS** (Elastic Block Store) - it is a block-level storage service offered by AWS that provides highly available, low-latency block-level storage volumes for use with EC2 instances. EBS volumes are designed for use with a single EC2 instance, and they can be attached and detached as needed. [More information](#elastic-block-storage-ebs)

**EFS** (Elastic File System) - it is a fully-managed, highly scalable file storage service that provides a simple and scalable file system for use with EC2 instances. EFS is designed to support multiple EC2 instances simultaneously, making it ideal for use cases where multiple instances need to access a shared file system. [More information](#elastic-file-system-efs)

**FSx**  -provides you with the native compatibility of third-party file systems with feature sets for workloads such as Windows-based storage, high-performance computing (HPC), machine learning, and electronic design automation (EDA). [More information](#amazon-fsx)

**S3** (Simple Storage Service) - it is a highly scalable, durable, and secure object storage service offered by AWS. S3 allows users to store and retrieve any amount of data from anywhere on the web and provides industry-leading scalability, data availability, security, and performance. It can be used for a wide range of use cases, including data lakes, backup and archive, and content distribution. [More information](#simple-storage-service-s3)

This services could be categorized by [Block](https://aws.amazon.com/what-is/block-storage/), [File](https://aws.amazon.com/what-is/cloud-file-storage/) and [Object](https://aws.amazon.com/what-is/object-storage/) storage type.

<br>

![](images/main-qimg-5f3b66e058df8c4addc876556757d276.png)

<br>

## Elastic Block Storage (EBS)

<img src="images/aws-ec2-smaller-partitioned-root-volume.png" width="400">

Amazon Elastic Block Store (EBS) is an easy to use, high-performance, block-storage service designed for use with Amazon Elastic Compute Cloud (EC2) for both throughput and transaction intensive workloads at any scale. A broad range of workloads, such as relational and non-relational databases, enterprise applications, containerized applications, big data analytics engines, file systems, and media workflows are widely deployed on Amazon EBS.

You can choose from six different volume types to balance optimal price and performance. You can achieve single-digit-millisecond latency for high-performance database workloads such as SAP HANA or gigabyte per second throughput for large, sequential workloads such as Hadoop. You can change volume types, tune performance, or increase volume size without disrupting your critical applications, so you have cost-effective storage when you need it.

Designed for mission-critical systems, EBS volumes are replicated within an Availability Zone (AZ) and can easily scale to petabytes of data. Also, you can use EBS Snapshots with automated lifecycle policies to back up your volumes in Amazon S3, while ensuring geographic protection of your data and business continuity.

For more information, see [EBS](ebs.md) module.

<br>


## Elastic File System (EFS)

<img src="images/efs-1.png" width="600">

**Amazon EFS** is an AWS file sharing service that lets you manage file shares, like those used on traditional networks, and mount them on cloud or on-premises machines using the **NFSv4 protocol**.

It is a scalable, cloud-based file system for Linux-based applications and workloads that can be used in combination with AWS cloud services and on-premise resources.

For more information, see [EFS](efs.md) module.

<br>


## Amazon FSx

Amazon FSx provides fully managed third-party file systems.

Amazon FSx provides you with the native compatibility of third-party file systems with feature sets for workloads such as Windows-based storage, high-performance computing (HPC), machine learning, and electronic design automation (EDA).

You don’t have to worry about managing file servers and storage, as Amazon FSx automates the time-consuming administration tasks such as hardware provisioning, software configuration, patching, and backups.

Amazon FSx integrates the file systems with cloud-native AWS services, making them even more useful for a broader set of workloads.

![](images/fsx-logo.png)

For more information, see [Amazone FSx](fsx.md) module.

<br>


## Simple Storage Service (S3)

<img src="images/s3-3.png" width="200">

**Amazon Simple Storage Service**, widely known as **Amazon S3**, is a highly scalable, fast, and durable solution for object-level storage of any data type. Unlike the operating systems we are all used to, Amazon S3 does not store files in a file system, instead it stores files as objects. Object Storage allows users to upload files, videos, and documents like you were to upload files, videos, and documents to popular cloud storage products like Dropbox and Google Drive. This makes Amazon S3 very flexible and platform agnostic.

For more information, see [S3](s3.md) module.

<br>


## Storage Services comparison

|                       | S3                                                                                                                                                                                                             | EBS                                                                                                                                                                                                                                                                    | EFS                                                                                                                                                                                                                                                                                    | FSx                                                                                                                         |
|-----------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------|
| **Used for**          | provides access to reliable, fast, and inexpensive data storage infrastructure. Examples: data lake (data analytics, Back up and restore critical data, archiving data, storage for cloud-native applications) | provides block level storage volumes for use with EC2 instances. Examples:  high-performance and high-availability block storage for mission-critical applications, databases storage, Easily resize clusters for big data analytics engines, such as Hadoop and Spark | provides scalable file storage for use with Amazon EC2. Examples: Share code and other files in a secure, organized way, Persist and share data from your AWS containers and serverless applications, Simplify persistent storage for modern content management system (CMS) workloads | is similar to EFS but provides support for popular commercial and open-source file systems. Examples: please see EFS column |
| **Used with**         | Wide used object store service in AWS. For instance: RDS, API Gateway, Step Functions, etc.                                                                                                                    | EC2                                                                                                                                                                                                                                                                    | EC2 linux-based systems with support NFSv4.1 <br/>can be integrated in serverless solution using access point                                                                                                                                                                          | EC2 instances which support specific commercial and open-source file systems                                                |
| **Configuration**     | - S3 Standard for general-purpose storage of frequently accessed data <br/>- S3 Standard_IA for long-lived, but less frequently accessed data <br/>- S3 Glacier for long-term archive                          | SSD-based volumes: <br/>- General Purpose Volumes gp2, gp3 <br/>- Provisioned IOPS Volume io1, io2, io2 <br/>Block Express HDD-based volumes: <br/>- Throughput Optimized HDD volumes st1 <br/>- Cold HDD Volumes sc1                                                  | - Standard access <br/>- One Zone Access <br/>- Infrequent Access                                                                                                                                                                                                                      | Depends from file system: Lustre, ONTAP, OpenZFS, Windows File System                                                       |
| **Pricing**           | Pay for using                                                                                                                                                                                                  | Pay for provisioned capacity                                                                                                                                                                                                                                           | Pay for using                                                                                                                                                                                                                                                                          | Pay for using                                                                                                               |
| **Storage capacity**  | Unlimited                                                                                                                                                                                                      | Limited, depends from volume type (max 16TB or 64TB)                                                                                                                                                                                                                   | Unlimited                                                                                                                                                                                                                                                                              | Depends from file system (max for wfs - 65,536 GiB)                                                                         |
| **Durability**        | 99.999999999%                                                                                                                                                                                                  | 99.8 - 99.999% depends from volume type                                                                                                                                                                                                                                | 99.999999999%                                                                                                                                                                                                                                                                          | Depends from file system (unspecified, 99.99%)                                                                              |
| **Availability**      | Depends from class 99.5 - 99.99% <br/> Multi AZ                                                                                                                                                                | 99.999% <br/> Single AZ                                                                                                                                                                                                                                                | 99.99% <br/> Multi AZ                                                                                                                                                                                                                                                                  | Depends from file system <br/> Multi AZ                                                                                     |
| **Accessibility**     | Public/Private                                                                                                                                                                                                 | Private (from an EC2 instance)                                                                                                                                                                                                                                         | Private: EC2, integration with AWS services using access point                                                                                                                                                                                                                         | Private                                                                                                                     |

<br>


## Self check:

1. Between block, file, object, which AWS services are related to each type?
2. What's the difference between EBS and EC2 Instance store?
3. If you need to have a folder, that will be used across a number of instance, what service will you use?
4. How can you replicate an EBS volume?
5. You have a static pages you want to expose to the Internet, what will you use for that case?
6. What are buckets in S3?
7. What does S3 replication do? What is it for?
8. What are versions in S3? What does it mean to delete an object in S3 when versioning is enabled?
9. How is it possible to optimize cost of S3 resources?
10. How nested file hierarchies are represented in S3?
11. What does S3 store inside its objects?
12. Why S3 is better than a physically maintained file server?
13. How many ways to allow access to S3 bucket do you know?
14. Is it possible attach EBS volume to a few instances simultaneously?
15. What is the use scenario for each Amazon FSx file system type?

## Hands-on Labs:
  [Get the hands-on experience with basic and advanced labs](./hands-on-labs.md)

## More details

### Recommended Trainings:

- [AWS Certified Solutions Architect - Associate (SAA-C02): 2 Storage Design](https://learn.epam.com/detailsPage?id=2a69c48d-24e4-4f5d-b89c-e08d0d82ef5d&source=EXTERNAL_COURSE)

## Optional: [Materials for AWS Certification Exam](./certification_storage.md)
