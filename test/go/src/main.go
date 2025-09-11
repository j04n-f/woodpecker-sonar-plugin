package main

// UnusedFunction demonstrates a code smell for SonarQube analysis
func UnusedFunction() string {
	unusedVar := "This variable is not used" // This should trigger a warning
	return "This function is never called"
}

func main() {
	name := "World"
}

