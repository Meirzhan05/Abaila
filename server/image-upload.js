const { S3Client, PutObjectCommand, GetObjectCommand } = require('@aws-sdk/client-s3')
const { getSignedUrl } = require('@aws-sdk/s3-request-presigner')
const { randomBytes } = require('crypto')

const s3 = new S3Client({
    region: process.env.AWS_REGION,
    credentials: {
        accessKeyId: process.env.AWS_ACCESS_KEY_ID,
        secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY
    },
    signatureVersion: 'v4'
})

async function getPreSignedURL(key) {
  const command = new GetObjectCommand({
    Bucket: process.env.S3_BUCKET_NAME,
    Key: key
  })
  return await getSignedUrl(s3, command, { expiresIn: 60 });
}

async function generateKey(filename) {
  const rawBytes = await randomBytes(16);
  const hex = rawBytes.toString("hex");
  return `media/${hex}-${filename}`;
}

async function generateUploadS3URL(filename, contentType = 'image/jpeg') {
  const key = await generateKey(filename) // Add await here

  const command = new PutObjectCommand({
    Bucket: process.env.S3_BUCKET_NAME,
    Key: key,
    ContentType: contentType
  })

  const uploadURL = await getSignedUrl(s3, command, { expiresIn: 60 })

  return { uploadURL, key }
}

module.exports = { generateUploadS3URL, getPreSignedURL }