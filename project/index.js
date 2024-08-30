import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3";

const s3Client = new S3Client();

export const handler = async (event) => {
    const {
        bucket: bucketName = 'tf-hint-demo-data',
        key = 'boxscore.json',
        feedUrl = 'https://nlnbamdnyc-a.akamaihd.net/fs/nba/feeds_s2019/stats/2019/boxscore/0021900821.js'
    } = event.body ? JSON.parse(event.body) : {};

    try {
        const response = await fetch(feedUrl);
        if (!response.ok) {
            console.log('response status: 👉️', response.statusText);
            return {
                statusCode: 500,
                body: JSON.stringify({ message: "Fetch failed", error: 'status code ' + response.statusText }),
            };
        }
        const result = await response.text();
        // console.log('result is: 👉️', result);
        const processedResult = result.substring('var g_boxscore='.length);
        const processedResultJson = JSON.parse(processedResult);
        console.log('data.duration:' + processedResultJson.duration);

        const uploadParams = {
            Key: key,
            Bucket: bucketName,
            Body: processedResult,
            ContentType: 'application/json',
        };

        try {
            const data = await s3Client.send(new PutObjectCommand(uploadParams));
            console.log("Successfully uploaded data to", bucketName, "/", key);
            return {
                statusCode: 200,
                body: JSON.stringify({ message: "Upload successful", data }),
            };
        }
        catch (err) {
            console.error("Error", err);
            return {
                statusCode: 500,
                body: JSON.stringify({ message: "Upload failed", error: err.message }),
            };
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
