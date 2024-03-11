({
	clickAdd : function(component, event, helper) {
		alert('hh');
        
        navigator.mediaDevices.getDisplayMedia({
            audio: true,
            video: true
            }).then(stream => {
            //context = new (window.AudioContext || window.webkitAudioContext)();
            //microphone = context.createMediaStreamSource(stream);
            console.log('Got MediaStream:', stream);
            const tracks = stream.getTracks();
            console.log(tracks);
            
            const recorder = new MediaRecorder(stream);
            recorder.start();
            
            const buffer = [];
            
            recorder.addEventListener('dataavailable',(event) => {
            	buffer.push(event.data);
            	console.log('buffer push called');
        	})
        
        	recorder.addEventListener('stop',() => {
                const blob = new Blob(buffer,{
            		type:'video/mp4'
            	})
        
        		const a = document.createElement('a');
        		a.href = URL.createObjectURL(blob);
        		a.download = "recording.mp4";
        		a.click();
        
        		console.log('stop called');
        	})
    
    		document.getElementById("stopScreenRecord").addEventListener("click", myFunction);

                function myFunction() {
                  recorder.stop();
                }
            
        });
        
        console.log('fin');
	},
        
        audioRecord : function(component, event, helper) {
            navigator.mediaDevices.getUserMedia({
                audio: true,
                video: false
                }).then(stream => {

                console.log('Got MediaStream:', stream);
                alert('hh');
                const tracks = stream.getTracks();
                console.log(tracks);
                
                const recorder = new MediaRecorder(stream);
                recorder.start();
                
                const buffer = [];
                
                recorder.addEventListener('dataavailable',(event) => {
                    buffer.push(event.data);
                    console.log('buffer push called');
                })
            
                recorder.addEventListener('stop',() => {
                  console.log('Buffer: ' + buffer);
                  console.log('Buffer size: ' + buffer.size());
                    const blob = new Blob(buffer,{
                        type:'audio/ogg'
                    })
            
                    const a = document.createElement('a');
                    a.href = URL.createObjectURL(blob);
                    a.download = "recording.mp3";
                    a.click();
            
                    console.log('stop called');
            		alert('stop');
                })
                
                document.getElementById("stopAudioRecord").addEventListener("click", myFunction);

                function myFunction() {
                  recorder.stop();
                }
                
            });
        }
})