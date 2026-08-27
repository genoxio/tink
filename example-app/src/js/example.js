import { Tink } from 'tink';

window.testEcho = () => {
    const inputValue = document.getElementById("echoInput").value;
    Tink.echo({ value: inputValue })
}
