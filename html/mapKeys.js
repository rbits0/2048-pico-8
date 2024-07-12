const keyMappings = {
    "w": 38, // Up
    "a": 39, // Left
    "s": 40, // Down
    "d": 41, // Right
    " ": 90, // Z (O)
    "Shift": 88, // X
    "Backspace": 88, // X
};

function onKeyUp(event) {
    const keyCode = keyMappings[event.key];
    if (keyCode == undefined) {
        return;
    }
    
    document.dispatchEvent(new KeyboardEvent(
        'keyup',
        {keyCode: keyCode},
    ));
}

function onKeyDown(event) {
    const keyCode = keyMappings[event.key];
    if (keyCode == undefined) {
        return;
    }
    
   document.dispatchEvent(new KeyboardEvent(
        'keydown',
        {keyCode: keyCode},
    ));
}


function addListeners() {
    document.addEventListener("keyup", onKeyUp);
    document.addEventListener("keydown", onKeyDown);

    console.log("Controls added");
}


(() => {
    document.addEventListener("DOMContentLoaded", addListeners);
})();