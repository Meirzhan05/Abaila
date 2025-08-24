require('dotenv').config()
const express = require('express')
const app = express()
const bcrypt = require('bcrypt')
const jwt = require('jsonwebtoken')
const mongoose = require('mongoose')
const User = require('./models/User')
const validator = require('validator')
const Alert = require('./models/Alert')
const { generateUploadS3URL, getPreSignedURL } = require('./image-upload')
const { getSignedUrl } = require('@aws-sdk/s3-request-presigner')
app.use(express.json())



app.get('/profile', authenticateToken, async (req, res) => {
    const user = await User.findById(req.user.userId)
    if (user == null) return res.status(404).send("User not found");
    return res.status(200).send({
        username: user.username,
        email: user.email
    })
})

app.put('/profile/update', authenticateToken, async (req, res) => {
    // console.log("Updating user profile")

    // check if email or username exist already
    const existingUser = await User.findOne({
        $or: [
          { email: req.body.email },
          { username: req.body.username }
        ],
        _id: { $ne: req.user.userId }
      });

    if (existingUser) return res.status(409).json({ message: 'Email or username already in use' });


    const user = await User.findById(req.user.userId)
    if (user == null) return res.status(404).send("User not found");
    user.email = req.body.email
    user.username = req.body.username
    await user.save()
    res.status(200).send({ message: "Profile updated" })
})


app.post('/token', async (req, res) => {
    const { refreshToken } = req.body
    // console.log("Refresh Token", refreshToken)
    if (!refreshToken) return res.status(401).send('Refresh token required');
    const user = await User.findOne({ refreshToken: refreshToken })
    // console.log(user)
    if (!user) return res.status(403).send("Invalid refresh token");

    jwt.verify(refreshToken, process.env.REFRESH_TOKEN_SECRET, async (err, decoded) => {
        if (err) return res.status(403).send('Invalid refresh token');
        if (!user || user.refreshToken !== refreshToken) {
            return res.status(403).send("Invalid refresh token");
        }
        const accessToken = generateAccessToken(user);
        res.json({ accessToken })
    })
})

app.delete('/logout', async (req, res) => {
    const { refreshToken } = req.body
    const user = await User.findOne({ refreshToken: refreshToken })
    if (!user) return res.status(204)
    user.refreshToken = null
    await user.save()
    return res.status(204)

});


app.post('/register', async (req, res) => {
    try {
        if (!validator.isEmail(req.body.email)) {
            return res.status(400).send({message: "Invalid email format"})
        }
        const existingUser = await User.findOne({
            $or: [
                {email: req.body.email},
                {username: req.body.username}
            ]
        })
        if (existingUser) {
            return res.status(400).send({message: "User already exists"}) 
        }

        const salt = await bcrypt.genSalt()
        const hashedPassword = await bcrypt.hash(req.body.password, salt)
        const user = new User({username: req.body.username, email: req.body.email, password: hashedPassword})

        const accessToken = generateAccessToken(user)
        const refreshToken = jwt.sign(
            { userId: user._id },
            process.env.REFRESH_TOKEN_SECRET
        );
        user.refreshToken = refreshToken
        await user.save()

        return res.status(200).send({
            message: 'Login successful',
            accessToken: accessToken,
            refreshToken: refreshToken
        })
    } catch (err) {
        console.log(err)
        res.status(500).send()
    }
})

app.post('/login', async (req, res) => {
    try {
        // console.log("Logging in")
        const data = {email: req.body.email, password: req.body.password}
        const user = await User.findOne({email: data.email})
        // console.log("Found user: ", user)
        if (!user) {
            return res.status(404).send('User not found')
        }

        if (await bcrypt.compare(data.password, user.password)) {
            const accessToken = generateAccessToken(user)
            const refreshToken = jwt.sign({email: user.email, username: user.username}, process.env.REFRESH_TOKEN_SECRET)
            user.refreshToken = refreshToken
            await user.save()
            return res.status(200).send({
                message: 'Login successful',
                accessToken: accessToken,
                refreshToken: refreshToken
            })
        }
        return res.status(404).send('Either username or passwords are incorrect')
    } catch {
        print("Error")
        return res.status(500).send()
    }
})


app.post('/alerts/create', authenticateToken, async (req, res) => {
    try {
        const data = {title: req.body.title, description: req.body.description, type: req.body.type, location: req.body.location, media: req.body.media}
        data.createdBy = req.user.userId 
        const alert = new Alert(data)
        await alert.save()
        return res.status(201).json({ message: "Alert created" });

    } catch (error) {

        console.log(error)

        return res.status(500).send()
    }
}) 

app.get('/media/getSignedUrl', authenticateToken, async (req, res) => {
    let result = []
    let keys
    try {
        keys = JSON.parse(req.query.keys)
    } catch (parseError) {
        return res.status(400).json({ error: 'Invalid JSON format for keys parameter' })
    }
    for (const key of keys) {
        const url = await getPreSignedURL(key)
        result.push(url)
    }
    return res.status(200).json(result)
}) 

app.get('/alerts/get', authenticateToken, async (req, res) => {
    try {
        const alerts = await Alert.find({ createdBy: req.user.userId })
        .populate('createdBy', 'username') // only username from User
        .lean()

        const result = alerts.map(({ createdBy, ...rest }) => ({
            ...rest,
            createdBy: createdBy.username, // string for client
        }))
        console.log("Fetching alerts ...", result)

        return res.status(200).json(result)
    } catch (error) {
        console.log(error)
        return res.status(500).send()
    }
})


app.put('/media/presigned-url', async (req, res) => {
    try {
      const contentType = req.query.contentType || 'image/jpeg'
      const { uploadURL, key } = await generateUploadS3URL(contentType)
      return res.status(200).json({ uploadURL, key })
    } catch (e) {
      console.error('Presign error', e)
      return res.status(500).json({ message: 'Failed to create upload URL' })
    }
})


function generateAccessToken(user) {
    return jwt.sign({ userId: user._id }, process.env.ACCESS_TOKEN_SECRET, {
        expiresIn: '15m'
    })
}

function authenticateToken(req, res, next) {
    const authHeader = req.headers['authorization']
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({ message: 'Invalid authorization header format' });
    }
    const token = authHeader && authHeader.split(' ')[1];

    if (token == null) return res.status(401).json({ message: 'No token provided' });
    
    jwt.verify(token, process.env.ACCESS_TOKEN_SECRET, (err, user) => {
        if (err) {
            console.error('JWT verification failed:', err.message);
            return res.status(403).json({ message: 'Invalid or expired token' });
        }
        req.user = user;
        next();
    });
    
}

mongoose.connect(process.env.MONGO_URI)
.then(() => console.log("✅ MongoDB connected"))
.catch(err => console.error("❌ MongoDB connection error:", err))

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Server listening on port ${PORT}`);
});