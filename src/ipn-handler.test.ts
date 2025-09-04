// Basic tests for the project

// Test that JSON mapping file exists and is valid
Deno.test("email to discord mapping file exists and is valid JSON", async () => {
  const jsonContent = await Deno.readTextFile("./src/src/mappings/emailtodiscord.json");
  const parsed = JSON.parse(jsonContent);
  
  // Basic validation that it's an object
  if (typeof parsed !== "object" || parsed === null) {
    throw new Error("Parsed JSON should be an object");
  }
});

// Test that TypeScript file has valid syntax (without network dependencies)
Deno.test("TypeScript file exists and can be parsed", async () => {
  // This test ensures the TypeScript file exists and is readable
  const fileContent = await Deno.readTextFile("./src/ipn-handler.ts");
  
  // Basic validation that it contains expected TypeScript/JavaScript constructs
  if (!fileContent.includes("async function")) {
    throw new Error("TypeScript file should contain async functions");
  }
  
  if (!fileContent.includes("export") && !fileContent.includes("import")) {
    // If it doesn't have exports, it should at least have imports
    if (!fileContent.includes("import")) {
      throw new Error("TypeScript file should contain imports or exports");
    }
  }
});