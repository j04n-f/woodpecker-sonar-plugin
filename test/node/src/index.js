function hello(name) {
    console.log("Hello, " + name + "!");
    // This is a test comment
    var unused = "This variable is not used"; // This should trigger a warning
}

function unusedFunction() {
    var unusedVar = "This variable is not used"; // This should trigger a warning
    return "This function is never called";
}
  
hello("World");