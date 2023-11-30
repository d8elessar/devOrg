const fs = require("fs");

// Read JSON data from input file
const data = JSON.parse(fs.readFileSync("./.github/stepOutput.txt", "utf8"));

let markdown = "The deployment validation result is: \n";

if (data.result && data.result.details && data.result.details.componentFailures) {
    let lines = 0;
    markdown += "| componentType | fileName | lineNumber | problem |\n| --- | --- | --- | --- |\n";

    data.result.details.componentFailures.forEach((failure) => {
        if (!failure.success && lines < 20) {
            let problem = failure.problem.replace(/(\r\n|\n|\r)/gm, " ");
            let lineNumber = failure.lineNumber ? failure.lineNumber : "N/A";
            markdown += `| ${failure.componentType} | ${failure.fileName} | ${lineNumber} | ${problem} |\n`;

            lines++;

            if (lines >= 20) {
                markdown += "(Error list truncated to the first 20 errors.)";
            }
        }
    });
} else {
    markdown += data.message;
}

// Write Markdown table to output file
fs.writeFileSync("./.github/stepOutput.md", markdown);
