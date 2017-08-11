var Observable = require("FuseJS/Observable");

var things = Observable();

var refreshClicked = function() {
	things.clear();
};

module.exports = {
	things: things,
	refreshClicked: refreshClicked
};
