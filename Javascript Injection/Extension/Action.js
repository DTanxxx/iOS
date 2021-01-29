var Action = function() {};

Action.prototype = {

run: function(parameters) {
    // this is called before extension is run
    parameters.completionFunction({"URL" : document.URL, "title" : document.title });
    // this means "tell iOS the JavaScript has finished preprocessing, and give this data dictionary to the extension"
},
    
finalize: function(parameters) {
    // this is called after extension is run
    var customJavaScript = parameters["customJavaScript"];
    eval(customJavaScript);
}
    
};

var ExtensionPreprocessingJS = new Action

