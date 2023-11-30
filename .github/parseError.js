const fs = require("fs");

// Read JSON data from input file
const data = JSON.parse(fs.readFileSync("./.github/stepOutput.txt", "utf8"));

let markdown = "\n| componentType | fileName | lineNumber | problem |\n| --- | --- | --- | --- |\n";

data.result.details.componentFailures.forEach((failure) => {
    if (!failure.success) {
        let problem = failure.problem.replace(/(\r\n|\n|\r)/gm, " ");
        let lineNumber = failure.lineNumber ? failure.lineNumber : "N/A";
        markdown += `| ${failure.componentType} | ${failure.fileName} | ${lineNumber} | ${problem} |\n`;
    }
});

// Write Markdown table to output file
fs.writeFileSync("./.github/stepOutput.md", markdown);
