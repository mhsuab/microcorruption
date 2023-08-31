// get all the instructions from the asm box
diasm = Array.from(document.getElementById('asmbox').childNodes).map((c) => c.getElementsByTagName('pre')[0].innerText)