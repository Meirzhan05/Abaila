// JavaScript
require('dotenv').config()
const { S3Client, PutObjectCommand } = require('@aws-sdk/client-s3')
const crypto = require('crypto')
const { promisify } = require('util')
const { getSignedUrl } = require('@aws-sdk/s3-request-presigner')

const randomBytes = promisify(crypto.randomBytes)
const s3 = new S3Client({
    region: process.env.AWS_REGION,
    credentials: {
        accessKeyId: process.env.AWS_ACCESS_KEY_ID,
        secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY
    },
    signatureVersion: 'v4'
})

async function generateUploadS3URL(contentType = 'image/jpeg') {
  const rawBytes = await randomBytes(16)
  const key = rawBytes.toString('hex')

  const command = new PutObjectCommand({
    Bucket: process.env.S3_BUCKET_NAME,
    Key: key,
    // ACL: 'public-read'
    ContentType: contentType
  })

  const uploadURL = await getSignedUrl(s3, command, { expiresIn: 60 })
  return { uploadURL, key }
}

module.exports = generateUploadS3URL