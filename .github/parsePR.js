const fs = require("fs");
const readline = require("readline");

async function extractTests() {
    //by default we specify that all tests should run
    let testsFile = __dirname + "/testsToRun.txt";
    await fs.promises.writeFile(testsFile, "all");

    const lines = readline.createInterface({
        input: fs.createReadStream(__dirname + "/pr_body.txt"),
        crlfDelay: Infinity
    });

    for await (const line of lines) {
        //special delimeter for apex tests
        if (line.includes("Apex::[") && line.includes("]::Apex")) {
            const start = "Apex::[";
            const end = "]::Apex";
            const startIndex = line.indexOf(start) + start.length;
            const endIndex = line.indexOf(end, startIndex);

            let tests = line.substring(startIndex, endIndex);
            await fs.promises.writeFile(testsFile, tests);
            await fs.promises.appendFile(testsFile, "\n");
        }
    }
}

extractTests();