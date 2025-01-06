// Request access to the user's camera
navigator.mediaDevices.getUserMedia({ video: true })
    .then((stream) => {
        // Set the video element's source to the camera stream
        const video = document.getElementById('camera');
        video.srcObject = stream;
    })
    .catch((error) => {
        console.error("Error accessing the camera: ", error);
    });
