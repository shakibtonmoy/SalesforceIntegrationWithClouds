import { LightningElement, track } from 'lwc';
    import insertFile from "@salesforce/apex/RecordingController.insertFiles";
    import uploadAudio from "@salesforce/apex/RecordingController.uploadAudioFile";

    const types = [

    'video/webm',

    'audio/webm',

    'audio/ogg;codecs=opus',

    'audio/mp4',

    'video/webm;codecs=vp8',

    'video/webm;codecs=daala',

    'video/webm;codecs=h264',

    'audio/webm;codecs=opus',

    'video/webm;codecs=vp8,opus',

    'video/mp4',

    'video/mpeg'

    ];

    export default class MarcoTest extends LightningElement {

    currentStream = null;

    @track logs = [];

    // recordedChunks = [];
    // mediaRecorder;
    mediaRecorder;

    get isListening() {

    return this.currentStream !== null;

    }

    start() {
        try {
            this.logs.push('Pushed the button start');
            this.logs.push('Navigator platform: ' + navigator.platform);
            this.logs.push(
            'Navigator mediadevices: ' +
                JSON.stringify(navigator.mediaDevices, null, 2)
            );
            navigator.mediaDevices
            .enumerateDevices()
            .then((devices) => {
            this.logs.push('Devices: ' + JSON.stringify(devices));
            });
            setTimeout(() => {
                for (const mimeType of types) {
                    this.logs.push(
                    'Trying to get the stream for ' +
                        mimeType +
                        ' support: ' +
                        MediaRecorder.isTypeSupported(mimeType)
                    );
                }
            }, 1000);
            navigator.mediaDevices
            .getUserMedia({ audio: true, video: false })
            .then((stream) => {
                alert('Starting the recording');
                this.logs.push('Starting the recording');  // WE NEVER REACH THIS LINE ON ANDROID
                console.log('Recording started: ', stream);
                this.stream = stream;
                // I want to display the stream in a video element
                const video = this.template.querySelector('video');
                video.srcObject = stream;
                video.play();
                const audio = this.template.querySelector('audio');
                audio.srcObject = stream;
                // audio.play();
                this.logs.push('We should be live');


                const recordedChunks = [];

                this.mediaRecorder = new MediaRecorder(stream);
                this.mediaRecorder.start();
                this.mediaRecorder.ondataavailable = function (e) {
                    alert('Data Available');
                    console.log('Data available');
                    if (e.data.size > 0) {
                        console.log('Recorded chunks available');
                        recordedChunks.push(e.data);
                    }
                };

                this.mediaRecorder.onstop = function (e) {
                    console.log('Stop called');
                    alert('Stop Called');
                    console.log('Recorded Chunks: ' + recordedChunks);
                    stream.getTracks()
                        .forEach(track => track.stop())
                    const blob = new Blob(recordedChunks, {
                        type:'audio/mp3'
                    });
                    alert('Downloading file');

                    console.log('Blob - ', blob);

                    let base64String;
                    let reader = new FileReader();
                    reader.readAsDataURL(blob);
                    reader.onloadend = function () {
                        base64String = reader.result;
                        let file = base64String.substring(base64String.indexOf(',') + 1);
                        console.log('FILE: ', file);

                        console.log('Base64 before calling apex: ', base64String);
                        insertFile({ file:  file })
                        .then(result => {
                            // Handle success response
                            console.log('File uploaded successfully: ' + result);
                        })
                        .catch(error => {
                            // Handle error response
                            console.error('Error uploading file: ' + error);
                        });
                    } 
                };
            })
            .catch((err) => {
                this.logs.push('Error: ', JSON.stringify(err));
                this.logs.push(
                'err: ' + JSON.stringify(err, Object.getOwnPropertyNames(err), 2)
                );
                // How to make sure the error is displayed
                this.logs.push('err: ' + JSON.stringify(err?.message));
                this.logs.push('err: ' + JSON.stringify(err?.stack));
                this.logs.push();
            });
        } catch (err) {

            this.logs.push('Error global: ', JSON.stringify(err));

            this.logs.push(

            'error: ' + JSON.stringify(err, Object.getOwnPropertyNames(err), 2)

            );

            this.logs.push('err: ' + JSON.stringify(err.message));

            this.logs.push('err: ' + JSON.stringify(err.stack));

        }
    }
    end() {
        this.logs.push('Pushed the button end');
        console.log('Ending the recording');
        this.mediaRecorder.stop();
    }


    startVideo() {
        try {
            this.logs.push('Pushed the button start');
            this.logs.push('Navigator platform: ' + navigator.platform);
            this.logs.push(
            'Navigator mediadevices: ' +
                JSON.stringify(navigator.mediaDevices, null, 2)
            );
            navigator.mediaDevices
            .enumerateDevices()
            .then((devices) => {
            this.logs.push('Devices: ' + JSON.stringify(devices));
            });
            setTimeout(() => {
                for (const mimeType of types) {
                    this.logs.push(
                    'Trying to get the stream for ' +
                        mimeType +
                        ' support: ' +
                        MediaRecorder.isTypeSupported(mimeType)
                    );
                }
            }, 1000);
            navigator.mediaDevices
            .getUserMedia({ video: { cursor: "motion" }, audio: { 'echoCancellation': true } })
            .then((stream) => {
                alert('Starting the recording');
                this.logs.push('Starting the recording');  // WE NEVER REACH THIS LINE ON ANDROID
                console.log('Recording started: ', stream);
                this.stream = stream;
                // I want to display the stream in a video element
                const video = this.template.querySelector('video');
                video.srcObject = stream;
                video.play();
                const audio = this.template.querySelector('audio');
                audio.srcObject = stream;
                // audio.play();
                this.logs.push('We should be live');


                const recordedChunks = [];

                this.mediaRecorder = new MediaRecorder(stream);
                this.mediaRecorder.start();
                this.mediaRecorder.ondataavailable = function (e) {
                    alert('Data Available');
                    console.log('Data available');
                    if (e.data.size > 0) {
                        console.log('Recorded chunks available');
                        recordedChunks.push(e.data);
                    }
                };

                this.mediaRecorder.onstop = function (e) {
                    console.log('Stop called');
                    alert('Stop Called');
                    console.log('Recorded Chunks: ' + recordedChunks);
                    stream.getTracks()
                        .forEach(track => track.stop())
                    const blob = new Blob(recordedChunks, {
                        type:'audio/mp3'
                    });
                    alert('Downloading file');

                    console.log('Blob - ', blob);

                    let base64String;
                    let reader = new FileReader();
                    reader.readAsDataURL(blob);
                    reader.onloadend = function () {
                        base64String = reader.result;
                        let file = base64String.substring(base64String.indexOf(',') + 1);
                        console.log('FILE: ', file);

                        console.log('Base64 before calling apex: ', base64String);
                        insertFile({ file:  file })
                        .then(result => {
                            // Handle success response
                            console.log('File uploaded successfully: ' + result);
                        })
                        .catch(error => {
                            // Handle error response
                            console.error('Error uploading file: ' + error);
                        });
                    } 
                };
            })
            .catch((err) => {
                this.logs.push('Error: ', JSON.stringify(err));
                this.logs.push(
                'err: ' + JSON.stringify(err, Object.getOwnPropertyNames(err), 2)
                );
                // How to make sure the error is displayed
                this.logs.push('err: ' + JSON.stringify(err?.message));
                this.logs.push('err: ' + JSON.stringify(err?.stack));
                this.logs.push();
            });
        } catch (err) {

            this.logs.push('Error global: ', JSON.stringify(err));

            this.logs.push(

            'error: ' + JSON.stringify(err, Object.getOwnPropertyNames(err), 2)

            );

            this.logs.push('err: ' + JSON.stringify(err.message));

            this.logs.push('err: ' + JSON.stringify(err.stack));

        }
    }

    get displayedLogs() {
        return this.logs.join('\n');
    }

    blobToBase64(blob) {
        return new Promise((resolve, _) => {
            const reader = new FileReader();
            reader.onloadend = () => resolve(reader.result);
            reader.readAsDataURL(blob);
        });
    }


    uploadFile(fileName, blobData) {
        // Convert Blob data to base64 string
        const reader = new FileReader();
        reader.onloadend = () => {
            const base64Data = reader.blobData.split(',')[1];
            console.log('base64Data: ', base64Data);
            
            // Call Apex method to upload the file
            uploadAudio({ fileName: fileName, base64Data: base64Data })
                .then(result => {
                    // Handle success response
                    console.log('File uploaded successfully: ' + result);
                })
                .catch(error => {
                    // Handle error response
                    console.error('Error uploading file: ' + error);
                });
        };
        reader.readAsDataURL(blobData);
    }
    

}