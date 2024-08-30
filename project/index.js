import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3";

const s3Client = new S3Client();

export const handler = async (event) => {
    try {
        const result = await fetch('https://nlnbamdnyc-a.akamaihd.net/fs/nba/feeds_s2019/stats/2019/boxscore/0021900821.js'); // TODO: export param
        // console.log('result is: 👉️', result);
        const processedResult = result.substring('var g_boxscore='.length);
        const processedResultJson = JSON.parse(processedResult);
        console.log('data.duration:' + processedResultJson.duration);

        const params = {
            Key: 'boxscore.json',
            Bucket: 'tf-hint-demo-data', // TODO: export param
            Body: processedResult,
            ContentType: 'application/json',
        };

        try {
            const command = new PutObjectCommand(params);
            const stored = await s3Client.send(command);
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
