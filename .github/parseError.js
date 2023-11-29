const fs = require("fs");

// Read JSON data from input file
const data = JSON.parse(fs.readFileSync("./.github/stepOutput.txt", "utf8"));

let markdown = "| componentType | fileName | lineNumber | problem |\n| --- | --- | --- | --- |\n";

data.result.details.componentFailures.forEach((failure) => {
    if (!failure.success) {
        markdown += `| ${failure.componentType} | ${failure.fileName} | ${failure.lineNumber} | ${failure.problem} |\n`;
    }
});

// Write Markdown table to output file
fs.writeFileSync("./.github/stepOutput.md", markdown);
