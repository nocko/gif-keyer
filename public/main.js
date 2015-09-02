(function () {
    'use strict';
    var button = document.getElementById('submitButton');
    var phrase = document.getElementById('phrase');
    var wpm = document.getElementById('wpm');

    button.addEventListener("click", function () {
	if (!phrase.value) {
	    var pg = document.getElementById('phraseGroup');
	    var es = document.getElementById('errorStatus');
	    pg.classList.add('has-error');
	    es.textContent='Please enter a phrase to animate';
	    return;
	}
	var loc = "/"+phrase.value+".gif";
	if (wpm.value) {
	    loc += "?wpm="+wpm.value;
	}
	document.location = loc;
    });
}());
