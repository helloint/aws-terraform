const https = require('https');
const AWS = require('aws-sdk');
const s3 = new AWS.S3();

exports.handler = async (event) => {
    try {
        const result = await getRequest('https://nlnbamdnyc-a.akamaihd.net/fs/nba/feeds_s2019/stats/2019/boxscore/0021900821.js'); // TODO: export param
        // console.log('result is: 👉️', result);
        const processedResult = result.substring('var g_boxscore='.length);
        const processedResultJson = JSON.parse(processedResult);
        console.log('data.duration:' + processedResultJson.duration);

        var params = {
            Body: processedResult,
            Bucket: 'tf-wnba-data', // TODO: export param
            Key: 'boxscore.json',
            ContentType: 'application/json',
        };

        try {
            const stored = await s3.upload(params).promise()
            console.log(stored);
        }
        catch (err) {
            console.log(err)
        }
    }
    catch (error) {
        console.log('Error is: 👉️', error);
        return {
            statusCode: 400,
            body: error.message,
        };
    }
};

function getRequest(url) {
    return new Promise((resolve, reject) => {
        const req = https.get(url, res => {
            let rawData = '';

            res.on('data', chunk => {
                rawData += chunk;
            });

            res.on('end', () => {
                try {
                    resolve(rawData);
                }
                catch (err) {
                    reject(new Error(err));
                }
            });
        });

        req.on('error', err => {
            reject(new Error(err));
        });
    });
}
