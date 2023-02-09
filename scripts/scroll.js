stop();

let direction = 1;
let step = 1;
let maxTop = 450;
let maxBottom = 550;

let pid = setInterval( () => {
    const body = document.documentElement
    body.scrollBy(0, step * direction)

    if (direction > 0 && body.scrollTop > body.scrollHeight - body.clientHeight - maxBottom) {
        direction = -2;
    }
    if (direction < 0 && body.scrollTop < maxTop) {
        direction = 1;
    }
}, 20)
let stop = () => clearInterval(pid)